#!/bin/bash

# Validate Spec-Kit Setup
# This script validates that all components are properly configured and ready to use

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
}

check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

# Function to check if file exists and is executable
check_file() {
    local file="$1"
    local description="$2"
    local required="${3:-true}"
    
    check
    if [[ -f "$file" ]]; then
        if [[ -x "$file" ]]; then
            log_success "$description: File exists and is executable"
        else
            log_warning "$description: File exists but is not executable"
        fi
    else
        if [[ "$required" == "true" ]]; then
            log_error "$description: File not found at $file"
        else
            log_warning "$description: Optional file not found at $file"
        fi
    fi
}

# Function to check directory structure
check_directory_structure() {
    log_info "Checking directory structure..."
    
    local directories=(
        "01-specification"
        "02-extraction" 
        "03-github-setup"
        "04-organization"
        "05-reporting"
    )
    
    for dir in "${directories[@]}"; do
        check
        if [[ -d "$ROOT_DIR/$dir" ]]; then
            log_success "Directory exists: $dir"
        else
            log_error "Directory missing: $dir"
        fi
    done
}

# Function to check core files
check_core_files() {
    log_info "Checking core files..."
    
    # Main setup script
    check_file "$ROOT_DIR/setup.sh" "Main setup script"
    check_file "$ROOT_DIR/README.md" "Documentation"
    check_file "$ROOT_DIR/config.example.sh" "Configuration template"
    
    # Configuration check
    check
    if [[ -f "$ROOT_DIR/config.sh" ]]; then
        log_success "Configuration file exists: config.sh"
    else
        log_warning "Configuration file not found: config.sh (copy from config.example.sh)"
    fi
}

# Function to check specification templates
check_specification_templates() {
    log_info "Checking specification templates..."
    
    local spec_dir="$ROOT_DIR/01-specification"
    
    check_file "$spec_dir/spec-template.md" "Specification template"
    check_file "$spec_dir/tasks-template.md" "Tasks template"
    check_file "$spec_dir/data-model-template.md" "Data model template"
}

# Function to check extraction scripts
check_extraction_scripts() {
    log_info "Checking extraction scripts..."
    
    local extract_dir="$ROOT_DIR/02-extraction"
    
    check_file "$extract_dir/extract-tasks.sh" "Task extraction script"
    check_file "$extract_dir/parse-dependencies.sh" "Dependency parsing script"
}

# Function to check GitHub setup scripts
check_github_setup_scripts() {
    log_info "Checking GitHub setup scripts..."
    
    local github_dir="$ROOT_DIR/03-github-setup"
    
    check_file "$github_dir/create-labels.sh" "Label creation script"
    check_file "$github_dir/create-milestones.sh" "Milestone creation script"
    check_file "$github_dir/create-issues.sh" "Issue creation script"
    check_file "$github_dir/enrich-issues.sh" "Issue enrichment script"
}

# Function to check organization files
check_organization_files() {
    log_info "Checking organization files..."
    
    local org_dir="$ROOT_DIR/04-organization"
    
    check_file "$org_dir/epics.yaml" "Epic configuration"
    check_file "$org_dir/milestones.yaml" "Milestone configuration"
    check_file "$org_dir/assign-to-epics.sh" "Epic assignment script"
    check_file "$org_dir/assign-to-milestones.sh" "Milestone assignment script"
}

# Function to check reporting scripts
check_reporting_scripts() {
    log_info "Checking reporting scripts..."
    
    local report_dir="$ROOT_DIR/05-reporting"
    
    check_file "$report_dir/generate-roadmap.sh" "Roadmap generation script"
    check_file "$report_dir/epic-progress.sh" "Epic progress script"
    check_file "$report_dir/weekly-status.sh" "Weekly status script"
    check_file "$report_dir/burndown.sh" "Burndown chart script"
}

# Function to check external dependencies
check_dependencies() {
    log_info "Checking external dependencies..."
    
    # GitHub CLI
    check
    if command -v gh &> /dev/null; then
        local gh_version
        gh_version=$(gh --version | head -1)
        log_success "GitHub CLI installed: $gh_version"
    else
        log_error "GitHub CLI not installed (required)"
    fi
    
    # jq
    check
    if command -v jq &> /dev/null; then
        local jq_version
        jq_version=$(jq --version)
        log_success "jq installed: $jq_version"
    else
        log_error "jq not installed (required for JSON processing)"
    fi
    
    # yq (optional)
    check
    if command -v yq &> /dev/null; then
        local yq_version
        yq_version=$(yq --version)
        log_success "yq installed: $yq_version"
    else
        log_warning "yq not installed (optional, for YAML processing)"
    fi
    
    # Python 3 (optional, for advanced features)
    check
    if command -v python3 &> /dev/null; then
        local python_version
        python_version=$(python3 --version)
        log_success "Python 3 installed: $python_version"
    else
        log_warning "Python 3 not installed (optional, for advanced analytics)"
    fi
    
    # curl
    check
    if command -v curl &> /dev/null; then
        log_success "curl available"
    else
        log_warning "curl not available (needed for some features)"
    fi
}

# Function to check GitHub authentication
check_github_auth() {
    log_info "Checking GitHub authentication..."
    
    check
    if command -v gh &> /dev/null; then
        if gh auth status &> /dev/null; then
            local auth_user
            auth_user=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
            log_success "GitHub CLI authenticated as: $auth_user"
        else
            log_error "GitHub CLI not authenticated (run: gh auth login)"
        fi
    else
        log_error "GitHub CLI not available"
    fi
}

# Function to validate configuration
check_configuration() {
    log_info "Checking configuration..."
    
    if [[ -f "$ROOT_DIR/config.sh" ]]; then
        # Source config file for validation
        # shellcheck source=/dev/null
        source "$ROOT_DIR/config.sh" 2>/dev/null || true
        
        # Check required variables
        check
        if [[ -n "$GITHUB_OWNER" ]]; then
            log_success "GITHUB_OWNER configured: $GITHUB_OWNER"
        else
            log_error "GITHUB_OWNER not set in config.sh"
        fi
        
        check
        if [[ -n "$GITHUB_REPO" ]]; then
            log_success "GITHUB_REPO configured: $GITHUB_REPO"
        else
            log_error "GITHUB_REPO not set in config.sh"
        fi
        
        check
        if [[ -n "$PROJECT_NAME" ]]; then
            log_success "PROJECT_NAME configured: $PROJECT_NAME"
        else
            log_warning "PROJECT_NAME not set in config.sh"
        fi
        
        # Test repository access if credentials are available
        if [[ -n "$GITHUB_OWNER" ]] && [[ -n "$GITHUB_REPO" ]] && command -v gh &> /dev/null && gh auth status &> /dev/null; then
            check
            if gh repo view "$GITHUB_OWNER/$GITHUB_REPO" &> /dev/null; then
                log_success "Repository accessible: $GITHUB_OWNER/$GITHUB_REPO"
            else
                log_error "Repository not accessible: $GITHUB_OWNER/$GITHUB_REPO"
            fi
        fi
    else
        check
        log_error "config.sh not found (copy from config.example.sh)"
    fi
}

# Function to check for common issues
check_common_issues() {
    log_info "Checking for common issues..."
    
    # Check for Windows line endings
    check
    if command -v file &> /dev/null; then
        local script_files
        script_files=$(find "$ROOT_DIR" -name "*.sh" -type f)
        local crlf_files=0
        
        while read -r script_file; do
            if file "$script_file" | grep -q "CRLF"; then
                crlf_files=$((crlf_files + 1))
            fi
        done <<< "$script_files"
        
        if [[ $crlf_files -eq 0 ]]; then
            log_success "No Windows line endings detected"
        else
            log_warning "$crlf_files script(s) have Windows line endings (may cause issues on Unix systems)"
        fi
    else
        log_warning "Cannot check for line endings (file command not available)"
    fi
    
    # Check for overly restrictive permissions
    check
    local unexecutable=0
    local script_files
    script_files=$(find "$ROOT_DIR" -name "*.sh" -type f)
    
    while read -r script_file; do
        if [[ ! -x "$script_file" ]]; then
            unexecutable=$((unexecutable + 1))
        fi
    done <<< "$script_files"
    
    if [[ $unexecutable -eq 0 ]]; then
        log_success "All shell scripts are executable"
    else
        log_warning "$unexecutable script(s) are not executable (run: chmod +x *.sh)"
    fi
}

# Function to generate validation report
generate_validation_report() {
    local report_file="$ROOT_DIR/validation-report.md"
    
    cat > "$report_file" << EOF
# Spec-Kit Validation Report

**Generated**: $(date)  
**Validation Script**: $0

## Summary

- **Total Checks**: $TOTAL_CHECKS
- **Passed**: $PASSED_CHECKS
- **Warnings**: $WARNING_CHECKS  
- **Failed**: $FAILED_CHECKS

## Status

EOF
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo "✅ **VALIDATION PASSED**: All critical checks passed" >> "$report_file"
    else
        echo "❌ **VALIDATION FAILED**: $FAILED_CHECKS critical checks failed" >> "$report_file"
    fi
    
    if [[ $WARNING_CHECKS -gt 0 ]]; then
        echo "⚠️ **WARNINGS**: $WARNING_CHECKS warnings found" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

## Next Steps

EOF
    
    if [[ $FAILED_CHECKS -gt 0 ]]; then
        cat >> "$report_file" << EOF
### Critical Issues to Address

1. Install missing dependencies (GitHub CLI, jq)
2. Fix configuration issues in config.sh
3. Ensure all required files are present
4. Check GitHub authentication and repository access

EOF
    fi
    
    if [[ $WARNING_CHECKS -gt 0 ]]; then
        cat >> "$report_file" << EOF
### Recommended Improvements

1. Install optional dependencies (yq, Python 3) for enhanced features
2. Complete configuration setup
3. Fix file permissions if needed
4. Review and address any warnings

EOF
    fi
    
    cat >> "$report_file" << EOF
### Ready to Use

If all critical checks passed, you can start using spec-kit:

\`\`\`bash
# 1. Ensure configuration is complete
cp config.example.sh config.sh
# Edit config.sh with your project details

# 2. Run the full setup
./setup.sh

# 3. Or run individual components
./02-extraction/extract-tasks.sh
./03-github-setup/create-labels.sh
# ... etc
\`\`\`

---
*Validation report generated by spec-kit*
EOF
    
    log_success "Validation report generated: $report_file"
}

# Function to show help
show_help() {
    cat << EOF
Spec-Kit Setup Validation

Usage: $0 [OPTIONS]

Options:
  -h, --help              Show this help message
  -q, --quiet             Quiet mode (only show summary)
  -v, --verbose           Verbose mode (show all details)
  --report                Generate validation report only
  --fix-permissions       Attempt to fix file permissions
  --check-auth            Only check GitHub authentication

This script validates that spec-kit is properly installed and configured.

Validation Categories:
  • Directory structure and required files
  • Script permissions and format
  • External dependencies (gh, jq, etc.)
  • GitHub authentication
  • Configuration completeness
  • Repository accessibility

Examples:
  $0                      # Full validation
  $0 --quiet              # Summary only
  $0 --check-auth         # Check GitHub auth only
  $0 --fix-permissions    # Fix script permissions
EOF
}

# Main validation function
main() {
    echo "==================================================================="
    echo "                  SPEC-KIT VALIDATION                            "
    echo "==================================================================="
    echo ""
    
    # Run all validation checks
    check_directory_structure
    echo ""
    
    check_core_files
    echo ""
    
    check_specification_templates
    echo ""
    
    check_extraction_scripts
    echo ""
    
    check_github_setup_scripts
    echo ""
    
    check_organization_files
    echo ""
    
    check_reporting_scripts
    echo ""
    
    check_dependencies
    echo ""
    
    check_github_auth
    echo ""
    
    check_configuration
    echo ""
    
    check_common_issues
    echo ""
    
    # Generate summary
    echo "==================================================================="
    echo "                     VALIDATION SUMMARY                          "
    echo "==================================================================="
    echo ""
    echo "Total Checks: $TOTAL_CHECKS"
    echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
    echo -e "Warnings: ${YELLOW}$WARNING_CHECKS${NC}"
    echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"
    echo ""
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo -e "${GREEN}✅ VALIDATION PASSED${NC}"
        echo "Spec-kit is ready to use!"
    else
        echo -e "${RED}❌ VALIDATION FAILED${NC}"
        echo "Please address the failed checks before using spec-kit."
    fi
    
    if [[ $WARNING_CHECKS -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  $WARNING_CHECKS warnings found${NC}"
        echo "Consider addressing warnings for optimal experience."
    fi
    
    echo ""
    
    # Generate validation report
    generate_validation_report
    
    echo "For detailed information, see: validation-report.md"
    echo ""
    
    # Exit with appropriate code
    if [[ $FAILED_CHECKS -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

# Function to fix permissions
fix_permissions() {
    log_info "Fixing file permissions..."
    
    # Make all shell scripts executable
    find "$ROOT_DIR" -name "*.sh" -type f -exec chmod +x {} \;
    
    log_success "File permissions updated"
}

# Function to check only GitHub authentication
check_auth_only() {
    check_github_auth
    
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo -e "${GREEN}✅ GitHub authentication is working${NC}"
        exit 0
    else
        echo -e "${RED}❌ GitHub authentication failed${NC}"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -q|--quiet)
            # Redirect detailed output to /dev/null, keep only summary
            exec 3>&1
            exec 1>/dev/null
            shift
            ;;
        -v|--verbose)
            set -x
            shift
            ;;
        --report)
            main > /dev/null 2>&1
            generate_validation_report
            exit 0
            ;;
        --fix-permissions)
            fix_permissions
            exit 0
            ;;
        --check-auth)
            check_auth_only
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main validation
main