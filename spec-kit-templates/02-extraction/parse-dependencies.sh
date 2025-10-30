#!/bin/bash

# Parse Task Dependencies and Create Dependency Graph
# This script analyzes task dependencies and validates dependency chains

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TASKS_FILE="${ROOT_DIR}/extracted-tasks.csv"
OUTPUT_DIR="${ROOT_DIR}/dependency-analysis"
DEPENDENCY_GRAPH="${OUTPUT_DIR}/dependency-graph.csv"
DEPENDENCY_REPORT="${OUTPUT_DIR}/dependency-report.md"
CIRCULAR_DEPS="${OUTPUT_DIR}/circular-dependencies.txt"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if file exists
check_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        log_info "Please run extract-tasks.sh first to generate the tasks file."
        exit 1
    fi
}

# Function to normalize task ID
normalize_task_id() {
    local task_id="$1"
    # Remove quotes and whitespace
    echo "$task_id" | sed 's/^"//; s/"$//; s/^[[:space:]]*//; s/[[:space:]]*$//'
}

# Function to parse dependencies from string
parse_dependencies() {
    local deps_string="$1"
    
    # Remove quotes and normalize
    deps_string=$(echo "$deps_string" | sed 's/^"//; s/"$//; s/^[[:space:]]*//; s/[[:space:]]*$//')
    
    # Handle "None" or empty dependencies
    if [[ "$deps_string" == "None" ]] || [[ "$deps_string" == "none" ]] || [[ -z "$deps_string" ]]; then
        return 0
    fi
    
    # Split by comma and extract task IDs
    echo "$deps_string" | tr ',' '\n' | while read -r dep; do
        # Extract task ID pattern (T followed by digits)
        if [[ "$dep" =~ T[0-9]+ ]]; then
            echo "${BASH_REMATCH[0]}"
        fi
    done
}

# Function to build dependency graph
build_dependency_graph() {
    local input_file="$1"
    local output_file="$2"
    
    log_info "Building dependency graph..."
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Initialize graph file with header
    echo "task_id,depends_on,dependency_type" > "$output_file"
    
    local total_dependencies=0
    
    # Skip header and process each task
    tail -n +2 "$input_file" | while IFS=, read -r task_id title component dependencies effort priority epic description spec_name file_path; do
        task_id=$(normalize_task_id "$task_id")
        
        # Parse dependencies for this task
        local deps
        deps=$(parse_dependencies "$dependencies")
        
        if [[ -n "$deps" ]]; then
            while read -r dep; do
                if [[ -n "$dep" ]]; then
                    echo "\"$task_id\",\"$dep\",\"blocks\"" >> "$output_file"
                    total_dependencies=$((total_dependencies + 1))
                fi
            done <<< "$deps"
        fi
    done
    
    log_success "Dependency graph created with $total_dependencies dependencies"
}

# Function to validate dependencies
validate_dependencies() {
    local tasks_file="$1"
    local graph_file="$2"
    
    log_info "Validating dependencies..."
    
    # Create list of all valid task IDs
    local valid_tasks_file="/tmp/valid_tasks.txt"
    tail -n +2 "$tasks_file" | cut -d',' -f1 | sed 's/^"//; s/"$//' > "$valid_tasks_file"
    
    local invalid_count=0
    local missing_dependencies=()
    
    # Check each dependency
    if [[ -f "$graph_file" ]] && [[ $(wc -l < "$graph_file") -gt 1 ]]; then
        tail -n +2 "$graph_file" | while IFS=, read -r task_id depends_on dependency_type; do
            task_id=$(normalize_task_id "$task_id")
            depends_on=$(normalize_task_id "$depends_on")
            
            # Check if the task being depended on exists
            if ! grep -q "^$depends_on$" "$valid_tasks_file"; then
                log_warning "Task $task_id depends on non-existent task: $depends_on"
                echo "$task_id -> $depends_on (MISSING)" >> "/tmp/invalid_deps.txt"
                invalid_count=$((invalid_count + 1))
            fi
        done
    fi
    
    if [[ $invalid_count -gt 0 ]]; then
        log_warning "Found $invalid_count invalid dependencies"
        if [[ -f "/tmp/invalid_deps.txt" ]]; then
            log_info "Invalid dependencies:"
            cat "/tmp/invalid_deps.txt"
        fi
    else
        log_success "All dependencies are valid"
    fi
    
    # Cleanup
    rm -f "$valid_tasks_file" "/tmp/invalid_deps.txt"
}

# Function to detect circular dependencies using DFS
detect_circular_dependencies() {
    local graph_file="$1"
    local output_file="$2"
    
    log_info "Detecting circular dependencies..."
    
    # Create adjacency list representation
    local adj_list_file="/tmp/adjacency_list.txt"
    
    if [[ -f "$graph_file" ]] && [[ $(wc -l < "$graph_file") -gt 1 ]]; then
        tail -n +2 "$graph_file" | while IFS=, read -r task_id depends_on dependency_type; do
            task_id=$(normalize_task_id "$task_id")
            depends_on=$(normalize_task_id "$depends_on")
            echo "$depends_on $task_id" >> "$adj_list_file"
        done
    else
        touch "$adj_list_file"
    fi
    
    # Python script to detect cycles using DFS
    python3 << 'EOF' > "$output_file"
import sys
from collections import defaultdict

def detect_cycles(graph):
    """Detect cycles in directed graph using DFS"""
    WHITE, GRAY, BLACK = 0, 1, 2
    color = defaultdict(lambda: WHITE)
    cycles = []
    
    def dfs(node, path):
        if color[node] == GRAY:
            # Found a cycle - extract the cycle
            cycle_start = path.index(node)
            cycle = path[cycle_start:] + [node]
            cycles.append(cycle)
            return True
        elif color[node] == BLACK:
            return False
        
        color[node] = GRAY
        path.append(node)
        
        for neighbor in graph[node]:
            if dfs(neighbor, path):
                pass  # Continue to find all cycles
        
        path.pop()
        color[node] = BLACK
        return False
    
    # Run DFS from each unvisited node
    for node in graph:
        if color[node] == WHITE:
            dfs(node, [])
    
    return cycles

# Read adjacency list
graph = defaultdict(list)
try:
    with open('/tmp/adjacency_list.txt', 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                parts = line.split()
                if len(parts) == 2:
                    from_node, to_node = parts
                    graph[from_node].append(to_node)
except FileNotFoundError:
    pass

# Detect cycles
cycles = detect_cycles(graph)

if cycles:
    print(f"Found {len(cycles)} circular dependency chain(s):")
    print()
    for i, cycle in enumerate(cycles, 1):
        print(f"Cycle {i}: {' -> '.join(cycle)}")
        print()
else:
    print("No circular dependencies detected.")
    print()

# Print dependency statistics
total_nodes = len(set(list(graph.keys()) + [node for neighbors in graph.values() for node in neighbors]))
total_edges = sum(len(neighbors) for neighbors in graph.values())
print(f"Dependency Graph Statistics:")
print(f"- Total tasks with dependencies: {len(graph)}")
print(f"- Total dependency relationships: {total_edges}")
print(f"- Tasks involved in dependencies: {total_nodes}")
EOF
    
    # Check if any circular dependencies were found
    if grep -q "circular dependency chain" "$output_file"; then
        log_error "Circular dependencies detected! Check $output_file for details."
        return 1
    else
        log_success "No circular dependencies found"
        return 0
    fi
    
    # Cleanup
    rm -f "$adj_list_file"
}

# Function to analyze dependency levels
analyze_dependency_levels() {
    local graph_file="$1"
    
    log_info "Analyzing dependency levels..."
    
    # Python script to calculate dependency levels
    python3 << 'EOF'
import sys
from collections import defaultdict, deque

# Read adjacency list
graph = defaultdict(list)
in_degree = defaultdict(int)
all_nodes = set()

try:
    with open('/tmp/adjacency_list.txt', 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                parts = line.split()
                if len(parts) == 2:
                    from_node, to_node = parts
                    graph[from_node].append(to_node)
                    in_degree[to_node] += 1
                    all_nodes.add(from_node)
                    all_nodes.add(to_node)
except FileNotFoundError:
    print("No dependencies to analyze.")
    sys.exit(0)

# Topological sort to determine levels
levels = {}
queue = deque()

# Find all nodes with no incoming edges (level 0)
for node in all_nodes:
    if in_degree[node] == 0:
        queue.append(node)
        levels[node] = 0

# Process nodes level by level
while queue:
    current = queue.popleft()
    current_level = levels[current]
    
    for neighbor in graph[current]:
        in_degree[neighbor] -= 1
        if in_degree[neighbor] == 0:
            queue.append(neighbor)
            levels[neighbor] = current_level + 1

# Output results
print("Task Dependency Levels:")
print("(Level 0 = no dependencies, higher levels depend on lower levels)")
print()

max_level = max(levels.values()) if levels else 0
for level in range(max_level + 1):
    tasks_at_level = [task for task, task_level in levels.items() if task_level == level]
    if tasks_at_level:
        print(f"Level {level}: {', '.join(sorted(tasks_at_level))}")

print()
print(f"Maximum dependency depth: {max_level}")
print(f"Tasks that can start immediately (Level 0): {len([t for t, l in levels.items() if l == 0])}")
EOF
}

# Function to generate dependency report
generate_dependency_report() {
    local tasks_file="$1"
    local graph_file="$2"
    local circular_file="$3"
    local report_file="$4"
    
    log_info "Generating dependency analysis report..."
    
    cat > "$report_file" << EOF
# Task Dependency Analysis Report

Generated: $(date)

## Overview

This report analyzes task dependencies extracted from the project specifications.

## Summary Statistics

EOF
    
    # Calculate statistics
    local total_tasks
    total_tasks=$(($(wc -l < "$tasks_file") - 1))
    
    local total_dependencies=0
    if [[ -f "$graph_file" ]] && [[ $(wc -l < "$graph_file") -gt 1 ]]; then
        total_dependencies=$(($(wc -l < "$graph_file") - 1))
    fi
    
    local tasks_with_deps
    tasks_with_deps=$(tail -n +2 "$tasks_file" | cut -d',' -f4 | grep -v '\"None\"' | grep -v '\"\"' | wc -l)
    
    cat >> "$report_file" << EOF
- **Total Tasks**: $total_tasks
- **Tasks with Dependencies**: $tasks_with_deps
- **Total Dependency Relationships**: $total_dependencies
- **Average Dependencies per Task**: $(echo "scale=2; $total_dependencies / $total_tasks" | bc -l 2>/dev/null || echo "N/A")

EOF
    
    # Add circular dependency analysis
    if [[ -f "$circular_file" ]]; then
        echo "## Circular Dependency Analysis" >> "$report_file"
        echo "" >> "$report_file"
        echo '```' >> "$report_file"
        cat "$circular_file" >> "$report_file"
        echo '```' >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    # Add dependency levels
    echo "## Dependency Levels" >> "$report_file"
    echo "" >> "$report_file"
    echo '```' >> "$report_file"
    analyze_dependency_levels "$graph_file" >> "$report_file"
    echo '```' >> "$report_file"
    echo "" >> "$report_file"
    
    # Add tasks with most dependencies
    echo "## Tasks with Most Dependencies" >> "$report_file"
    echo "" >> "$report_file"
    if [[ -f "$graph_file" ]] && [[ $(wc -l < "$graph_file") -gt 1 ]]; then
        tail -n +2 "$graph_file" | cut -d',' -f1 | sed 's/^"//; s/"$//' | sort | uniq -c | sort -nr | head -10 | while read -r count task; do
            echo "- **$task**: $count dependencies" >> "$report_file"
        done
    else
        echo "No dependency data available." >> "$report_file"
    fi
    
    echo "" >> "$report_file"
    
    # Add critical path information
    echo "## Critical Path Analysis" >> "$report_file"
    echo "" >> "$report_file"
    echo "Tasks on the critical path (highest dependency levels) should be prioritized:" >> "$report_file"
    echo "" >> "$report_file"
    
    # Simple critical path identification
    if [[ -f "$graph_file" ]] && [[ $(wc -l < "$graph_file") -gt 1 ]]; then
        echo "Run this command for detailed critical path analysis:" >> "$report_file"
        echo '```bash' >> "$report_file"
        echo "./02-extraction/parse-dependencies.sh --critical-path" >> "$report_file"
        echo '```' >> "$report_file"
    fi
    
    echo "" >> "$report_file"
    echo "---" >> "$report_file"
    echo "*Generated by spec-kit dependency analyzer*" >> "$report_file"
}

# Main function
main() {
    log_info "Starting dependency analysis..."
    
    # Check if tasks file exists
    check_file "$TASKS_FILE"
    
    # Build dependency graph
    build_dependency_graph "$TASKS_FILE" "$DEPENDENCY_GRAPH"
    
    # Validate dependencies
    validate_dependencies "$TASKS_FILE" "$DEPENDENCY_GRAPH"
    
    # Detect circular dependencies
    if ! detect_circular_dependencies "$DEPENDENCY_GRAPH" "$CIRCULAR_DEPS"; then
        log_error "Circular dependencies found! Please fix before proceeding."
    fi
    
    # Generate comprehensive report
    generate_dependency_report "$TASKS_FILE" "$DEPENDENCY_GRAPH" "$CIRCULAR_DEPS" "$DEPENDENCY_REPORT"
    
    # Summary
    echo ""
    log_success "Dependency analysis completed!"
    log_info "Output files:"
    echo "  - Dependency graph: $DEPENDENCY_GRAPH"
    echo "  - Circular dependencies: $CIRCULAR_DEPS"
    echo "  - Analysis report: $DEPENDENCY_REPORT"
    
    echo ""
    log_info "Next steps:"
    echo "  1. Review dependency report: $DEPENDENCY_REPORT"
    echo "  2. Fix any circular dependencies if found"
    echo "  3. Consider task scheduling based on dependency levels"
    echo "  4. Proceed with GitHub issue creation"
}

# Help function
show_help() {
    echo "Parse Task Dependencies and Create Dependency Graph"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -t, --tasks         Specify tasks file (default: ../extracted-tasks.csv)"
    echo "  -o, --output-dir    Specify output directory (default: ../dependency-analysis)"
    echo "  --critical-path     Show critical path analysis only"
    echo ""
    echo "This script analyzes task dependencies and generates:"
    echo "  - Dependency graph (CSV format)"
    echo "  - Circular dependency detection"
    echo "  - Dependency level analysis"
    echo "  - Comprehensive analysis report"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -t|--tasks)
            TASKS_FILE="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            DEPENDENCY_GRAPH="${OUTPUT_DIR}/dependency-graph.csv"
            DEPENDENCY_REPORT="${OUTPUT_DIR}/dependency-report.md"
            CIRCULAR_DEPS="${OUTPUT_DIR}/circular-dependencies.txt"
            shift 2
            ;;
        --critical-path)
            # Just show critical path analysis
            check_file "$TASKS_FILE"
            analyze_dependency_levels "/tmp/adjacency_list.txt"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main "$@"