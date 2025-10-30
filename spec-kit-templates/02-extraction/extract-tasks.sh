#!/bin/bash

# Extract Tasks from Specification Files
# This script parses tasks.md files and generates CSV data for GitHub issue creation

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SPECS_DIR="${ROOT_DIR}/../specs"
OUTPUT_FILE="${ROOT_DIR}/extracted-tasks.csv"
TEMP_FILE="/tmp/tasks-extraction.tmp"

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

# Function to extract task information from a line
extract_task_info() {
    local line="$1"
    local file_path="$2"
    local spec_name="$3"
    
    # Extract task ID and title from line like "### T001: Task Title"
    if [[ $line =~ ^###[[:space:]]+([T][0-9]+):[[:space:]]*(.+)$ ]]; then
        local task_id="${BASH_REMATCH[1]}"
        local task_title="${BASH_REMATCH[2]}"
        
        echo "$task_id|$task_title|$spec_name|$file_path"
        return 0
    fi
    return 1
}

# Function to extract detailed task information
extract_task_details() {
    local file_path="$1"
    local task_id="$2"
    local start_line="$3"
    
    local component=""
    local dependencies=""
    local effort=""
    local priority=""
    local epic=""
    local description=""
    
    # Read from the task line until next task or end of file
    local line_num=$((start_line + 1))
    while IFS= read -r line; do
        # Stop if we hit another task
        if [[ $line =~ ^###[[:space:]]+T[0-9]+ ]]; then
            break
        fi
        
        # Extract metadata
        if [[ $line =~ ^\*\*Component\*\*:[[:space:]]*(.+)$ ]]; then
            component="${BASH_REMATCH[1]}"
        elif [[ $line =~ ^\*\*Dependencies\*\*:[[:space:]]*(.+)$ ]]; then
            dependencies="${BASH_REMATCH[1]}"
        elif [[ $line =~ ^\*\*Effort\*\*:[[:space:]]*([0-9]+) ]]; then
            effort="${BASH_REMATCH[1]}"
        elif [[ $line =~ ^\*\*Priority\*\*:[[:space:]]*(.+)$ ]]; then
            priority="${BASH_REMATCH[1]}"
        elif [[ $line =~ ^\*\*Epic\*\*:[[:space:]]*(.+)$ ]]; then
            epic="${BASH_REMATCH[1]}"
        elif [[ $line =~ ^\*\*Description\*\*:[[:space:]]*(.+)$ ]]; then
            description="${BASH_REMATCH[1]}"
        fi
        
        line_num=$((line_num + 1))
    done < <(tail -n +$line_num "$file_path")
    
    echo "$component|$dependencies|$effort|$priority|$epic|$description"
}

# Function to validate task format
validate_task() {
    local task_id="$1"
    local title="$2"
    local component="$3"
    local effort="$4"
    local priority="$5"
    local epic="$6"
    
    local valid=true
    
    # Validate task ID format
    if [[ ! $task_id =~ ^T[0-9]{3,}$ ]]; then
        log_warning "Task $task_id: Invalid task ID format (should be T001, T002, etc.)"
        valid=false
    fi
    
    # Validate required fields
    if [[ -z "$title" ]]; then
        log_warning "Task $task_id: Missing title"
        valid=false
    fi
    
    if [[ -z "$component" ]]; then
        log_warning "Task $task_id: Missing component"
        valid=false
    fi
    
    if [[ -z "$effort" ]] || [[ ! "$effort" =~ ^[0-9]+$ ]]; then
        log_warning "Task $task_id: Missing or invalid effort (should be numeric)"
        valid=false
    fi
    
    if [[ -z "$priority" ]] || [[ ! "$priority" =~ ^P[0-3]$ ]]; then
        log_warning "Task $task_id: Missing or invalid priority (should be P0-P3)"
        valid=false
    fi
    
    if [[ -z "$epic" ]]; then
        log_warning "Task $task_id: Missing epic"
        valid=false
    fi
    
    if [[ "$valid" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to process a single tasks.md file
process_tasks_file() {
    local file_path="$1"
    local spec_name="$2"
    
    log_info "Processing: $file_path"
    
    if [[ ! -f "$file_path" ]]; then
        log_warning "File not found: $file_path"
        return 1
    fi
    
    local task_count=0
    local valid_task_count=0
    local line_num=0
    
    # First pass: find all task headers
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        
        if extract_task_info "$line" "$file_path" "$spec_name" >/dev/null; then
            task_count=$((task_count + 1))
            
            # Extract task ID and title
            local task_info
            task_info=$(extract_task_info "$line" "$file_path" "$spec_name")
            local task_id
            task_id=$(echo "$task_info" | cut -d'|' -f1)
            local task_title
            task_title=$(echo "$task_info" | cut -d'|' -f2)
            
            # Extract detailed information
            local details
            details=$(extract_task_details "$file_path" "$task_id" "$line_num")
            local component
            component=$(echo "$details" | cut -d'|' -f1)
            local dependencies
            dependencies=$(echo "$details" | cut -d'|' -f2)
            local effort
            effort=$(echo "$details" | cut -d'|' -f3)
            local priority
            priority=$(echo "$details" | cut -d'|' -f4)
            local epic
            epic=$(echo "$details" | cut -d'|' -f5)
            local description
            description=$(echo "$details" | cut -d'|' -f6)
            
            # Validate task
            if validate_task "$task_id" "$task_title" "$component" "$effort" "$priority" "$epic"; then
                valid_task_count=$((valid_task_count + 1))
                
                # Output to CSV (escape commas and quotes)
                printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n" \
                    "\"$task_id\"" \
                    "\"${task_title//\"/\"\"}\"" \
                    "\"$component\"" \
                    "\"$dependencies\"" \
                    "\"$effort\"" \
                    "\"$priority\"" \
                    "\"$epic\"" \
                    "\"${description//\"/\"\"}\"" \
                    "\"$spec_name\"" \
                    "\"$file_path\"" >> "$TEMP_FILE"
            fi
        fi
    done < "$file_path"
    
    log_success "Found $task_count tasks, $valid_task_count valid in $spec_name"
    return 0
}

# Main function
main() {
    log_info "Starting task extraction from specifications..."
    
    # Check if specs directory exists
    if [[ ! -d "$SPECS_DIR" ]]; then
        log_error "Specifications directory not found: $SPECS_DIR"
        log_info "Please create the specs directory and add your specification files."
        exit 1
    fi
    
    # Initialize temp file with CSV header
    echo "task_id,title,component,dependencies,effort,priority,epic,description,spec_name,file_path" > "$TEMP_FILE"
    
    local total_files=0
    local processed_files=0
    local total_tasks=0
    
    # Find all tasks.md files
    while IFS= read -r -d '' file; do
        total_files=$((total_files + 1))
        
        # Extract spec name from path
        local spec_name
        spec_name=$(basename "$(dirname "$file")")
        
        if process_tasks_file "$file" "$spec_name"; then
            processed_files=$((processed_files + 1))
        fi
    done < <(find "$SPECS_DIR" -name "tasks.md" -type f -print0)
    
    # Count total extracted tasks (excluding header)
    total_tasks=$(($(wc -l < "$TEMP_FILE") - 1))
    
    # Move temp file to final location
    mv "$TEMP_FILE" "$OUTPUT_FILE"
    
    # Summary
    echo ""
    log_success "Task extraction completed!"
    log_info "Files processed: $processed_files/$total_files"
    log_info "Total tasks extracted: $total_tasks"
    log_info "Output file: $OUTPUT_FILE"
    
    if [[ $total_tasks -eq 0 ]]; then
        log_warning "No tasks were extracted. Please check your tasks.md files format."
        log_info "Expected format:"
        echo "### T001: Task Title"
        echo "**Component**: Component Name"
        echo "**Dependencies**: T000 (or None)"
        echo "**Effort**: 5 story points"
        echo "**Priority**: P0"
        echo "**Epic**: epic-name"
        echo "**Description**: Task description"
        exit 1
    fi
    
    # Display first few tasks as sample
    if [[ $total_tasks -gt 0 ]]; then
        echo ""
        log_info "Sample extracted tasks:"
        head -6 "$OUTPUT_FILE" | while IFS=, read -r task_id title component dependencies effort priority epic description spec_name file_path; do
            if [[ "$task_id" != "task_id" ]]; then  # Skip header
                echo "  $task_id: $title [$epic, $priority, ${effort} pts]"
            fi
        done
        
        if [[ $total_tasks -gt 5 ]]; then
            echo "  ... and $((total_tasks - 5)) more tasks"
        fi
    fi
    
    echo ""
    log_info "Next steps:"
    echo "  1. Review the extracted tasks in: $OUTPUT_FILE"
    echo "  2. Run: ./03-github-setup/create-labels.sh"
    echo "  3. Run: ./03-github-setup/create-milestones.sh"
    echo "  4. Run: ./03-github-setup/create-issues.sh"
}

# Help function
show_help() {
    echo "Extract Tasks from Specification Files"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -s, --specs     Specify specs directory (default: ../specs)"
    echo "  -o, --output    Specify output file (default: ../extracted-tasks.csv)"
    echo ""
    echo "This script searches for tasks.md files in the specs directory and"
    echo "extracts task information into a CSV file for GitHub issue creation."
    echo ""
    echo "Expected task format in tasks.md:"
    echo "  ### T001: Task Title"
    echo "  **Component**: Component Name"
    echo "  **Dependencies**: T000 (or None)"
    echo "  **Effort**: 5 story points"
    echo "  **Priority**: P0"
    echo "  **Epic**: epic-name"
    echo "  **Description**: Task description"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--specs)
            SPECS_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
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