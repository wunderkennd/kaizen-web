#!/bin/bash

# Spec-Kit Configuration File
# Copy this file to config.sh and update with your project details

# =============================================================================
# GITHUB CONFIGURATION
# =============================================================================

# GitHub repository details (REQUIRED)
export GITHUB_OWNER="your-github-username"      # Your GitHub username or organization
export GITHUB_REPO="your-repository-name"       # Your repository name

# GitHub API settings
export GITHUB_API_DELAY="1"                     # Delay between API calls (seconds)
export GITHUB_API_BATCH_SIZE="10"               # Batch size for bulk operations

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

# Project details
export PROJECT_NAME="Your Project Name"         # Human-readable project name
export PROJECT_DESCRIPTION="Project description here"
export PROJECT_START_DATE="$(date +%Y-%m-%d)"   # Project start date (YYYY-MM-DD)

# Task configuration
export TASKS_PREFIX="T"                         # Task ID prefix (T001, T002, etc.)
export TASKS_PADDING="3"                        # Number of digits for task IDs

# =============================================================================
# WORKFLOW CONFIGURATION
# =============================================================================

# Script execution settings
export DRY_RUN="false"                          # Set to "true" to preview changes without making them
export FORCE_UPDATE="false"                     # Set to "true" to force update existing items
export BATCH_SIZE="10"                          # Default batch size for processing
export RATE_LIMIT_DELAY="1"                     # Default delay between batches (seconds)

# Feature flags
export INCLUDE_DETAILS="true"                   # Include detailed information in reports
export INCLUDE_CHARTS="false"                   # Generate chart visualizations
export STORY_POINT_MAPPING="true"               # Use story points instead of issue count

# =============================================================================
# MILESTONE CONFIGURATION
# =============================================================================

# Default milestone structure
export MILESTONE_1_WEEKS="4"                    # M1: MVP Foundation (weeks from start)
export MILESTONE_2_WEEKS="10"                   # M2: Core Platform
export MILESTONE_3_WEEKS="14"                   # M3: User Experience
export MILESTONE_4_WEEKS="18"                   # M4: Production Ready
export MILESTONE_5_WEEKS="24"                   # M5: Enhancement & Scale

# Milestone naming convention
export MILESTONE_PREFIX="M"                     # Milestone prefix
export MILESTONE_FORMAT="M%d: %s"              # Format: M1: Title

# =============================================================================
# EPIC CONFIGURATION
# =============================================================================

# Epic colors (hex codes without #)
export EPIC_FOUNDATION_COLOR="0052cc"
export EPIC_DATA_LAYER_COLOR="5319e7"
export EPIC_CORE_SERVICES_COLOR="b60205"
export EPIC_FRONTEND_COLOR="f9d0c4"
export EPIC_TESTING_COLOR="1d76db"
export EPIC_OPERATIONS_COLOR="fbca04"
export EPIC_CICD_COLOR="006b75"
export EPIC_EXPERIMENTATION_COLOR="c5def5"
export EPIC_DOCUMENTATION_COLOR="7057ff"

# Epic task ranges (customize based on your task organization)
export EPIC_FOUNDATION_TASKS="T001-T020,T183-T190"
export EPIC_DATA_LAYER_TASKS="T021-T040"
export EPIC_CORE_SERVICES_TASKS="T041-T070,T163-T164,T166"
export EPIC_FRONTEND_TASKS="T071-T100,T162,T167-T168,T172,T178"
export EPIC_TESTING_TASKS="T101-T130"
export EPIC_OPERATIONS_TASKS="T131-T160,T165,T175,T180"
export EPIC_CICD_TASKS="T175-T182"
export EPIC_EXPERIMENTATION_TASKS="T161,T169-T170"
export EPIC_DOCUMENTATION_TASKS="T171,T173-T174,T176-T177,T179"

# =============================================================================
# LABEL CONFIGURATION
# =============================================================================

# Priority label colors
export LABEL_P0_COLOR="d73a4a"                  # Critical
export LABEL_P1_COLOR="e99695"                  # High
export LABEL_P2_COLOR="fef2c0"                  # Medium
export LABEL_P3_COLOR="c2e0c6"                  # Low

# Size label colors
export LABEL_SIZE_XS_COLOR="ffffff"             # 1-2 story points
export LABEL_SIZE_S_COLOR="c2e0c6"              # 3-5 story points
export LABEL_SIZE_M_COLOR="fef2c0"              # 5-8 story points
export LABEL_SIZE_L_COLOR="f9d0c4"              # 8-13 story points
export LABEL_SIZE_XL_COLOR="e99695"             # 13+ story points

# Status label colors
export LABEL_STATUS_READY_COLOR="0e8a16"
export LABEL_STATUS_IN_PROGRESS_COLOR="fbca04"
export LABEL_STATUS_REVIEW_COLOR="7057ff"
export LABEL_STATUS_BLOCKED_COLOR="d73a4a"
export LABEL_STATUS_ON_HOLD_COLOR="fef2c0"

# =============================================================================
# REPORTING CONFIGURATION
# =============================================================================

# Report settings
export REPORT_TIME_PERIOD="30"                  # Days to look back for activity analysis
export REPORT_INCLUDE_CHARTS="false"            # Generate visual charts
export REPORT_OUTPUT_FORMAT="markdown"          # Output format: markdown, html, json

# Weekly status report settings
export WEEKLY_STATUS_WEEK_START="7"             # Days ago to start the week
export WEEKLY_STATUS_INCLUDE_TEAM_METRICS="true"

# Burndown chart settings
export BURNDOWN_TYPE="milestone"                # Default burndown type: milestone, epic, sprint
export BURNDOWN_SPRINT_DAYS="14"                # Default sprint duration
export BURNDOWN_STORY_POINTS="true"             # Use story points vs issue count

# =============================================================================
# TEAM CONFIGURATION
# =============================================================================

# Team members (for assignment and reporting)
export TEAM_LEAD="team-lead-username"
export TECH_LEAD="tech-lead-username"
export FRONTEND_LEAD="frontend-lead-username"
export BACKEND_LEAD="backend-lead-username"
export QA_LEAD="qa-lead-username"
export DEVOPS_LEAD="devops-lead-username"

# Team notification settings
export SLACK_WEBHOOK_URL=""                     # Slack webhook for notifications (optional)
export TEAMS_WEBHOOK_URL=""                     # Microsoft Teams webhook (optional)
export EMAIL_NOTIFICATIONS="false"              # Enable email notifications

# =============================================================================
# FILE PATHS CONFIGURATION
# =============================================================================

# Input file paths (relative to spec-kit-templates directory)
export SPECS_DIR="../specs"                     # Specifications directory
export TASKS_FILE="../extracted-tasks.csv"     # Extracted tasks file
export EPICS_CONFIG="./04-organization/epics.yaml"
export MILESTONES_CONFIG="./04-organization/milestones.yaml"

# Output file paths
export OUTPUT_DIR="../"                         # Output directory for reports
export DOCS_DIR="../docs"                       # Documentation output directory
export REPORTS_DIR="../reports"                 # Reports output directory

# =============================================================================
# ADVANCED CONFIGURATION
# =============================================================================

# Task extraction settings
export EXTRACT_VALIDATE_FORMAT="true"          # Validate task format during extraction
export EXTRACT_SKIP_INVALID="false"            # Skip invalid tasks or fail
export EXTRACT_AUTO_ASSIGN_EPIC="true"         # Auto-assign epic based on task ID

# Issue creation settings
export ISSUE_CREATE_BATCH_SIZE="10"            # Issues to create per batch
export ISSUE_CREATE_DELAY="2"                  # Delay between batches (seconds)
export ISSUE_ENRICH_DEPENDENCIES="true"        # Add dependency comments
export ISSUE_ENRICH_EPIC_CONTEXT="true"        # Add epic context

# Epic assignment settings
export EPIC_ASSIGN_BATCH_SIZE="5"              # Epic assignments per batch
export EPIC_ASSIGN_DELAY="2"                   # Delay between assignments
export EPIC_ASSIGN_CREATE_COMMENTS="true"      # Add epic assignment comments

# Milestone assignment settings
export MILESTONE_ASSIGN_BATCH_SIZE="5"         # Milestone assignments per batch
export MILESTONE_ASSIGN_DELAY="2"              # Delay between assignments
export MILESTONE_ASSIGN_BALANCE_WORKLOAD="true" # Attempt to balance milestone workload

# =============================================================================
# VALIDATION RULES
# =============================================================================

# Task validation rules
export VALIDATE_TASK_ID_FORMAT="^T[0-9]{3,}$"  # Regex for valid task ID format
export VALIDATE_REQUIRED_FIELDS="title,component,effort,priority,epic"
export VALIDATE_PRIORITY_VALUES="P0,P1,P2,P3"
export VALIDATE_EFFORT_RANGE="1-21"            # Min-max story points

# Epic validation rules
export VALIDATE_EPIC_NAMES="foundation,data-layer,core-services,frontend,testing,operations,cicd,experimentation,documentation"

# =============================================================================
# AUTOMATION SETTINGS
# =============================================================================

# Automation flags
export AUTO_CREATE_LABELS="true"               # Automatically create missing labels
export AUTO_CREATE_MILESTONES="true"           # Automatically create milestones
export AUTO_ASSIGN_EPICS="true"                # Automatically assign issues to epics
export AUTO_ASSIGN_MILESTONES="true"           # Automatically assign issues to milestones
export AUTO_ENRICH_ISSUES="true"               # Automatically enrich issue descriptions

# Continuous integration settings
export CI_MODE="false"                         # Enable CI-friendly mode (less interactive)
export CI_FAIL_ON_VALIDATION="true"           # Fail CI on validation errors
export CI_SKIP_CONFIRMATIONS="false"          # Skip user confirmations in CI

# =============================================================================
# LOGGING AND DEBUG
# =============================================================================

# Logging configuration
export LOG_LEVEL="INFO"                        # DEBUG, INFO, WARN, ERROR
export LOG_FILE=""                             # Log file path (empty = stdout only)
export LOG_TIMESTAMP="true"                    # Include timestamps in logs

# Debug settings
export DEBUG_MODE="false"                      # Enable debug output
export VERBOSE_OUTPUT="false"                  # Enable verbose output
export PRESERVE_TEMP_FILES="false"             # Keep temporary files for debugging

# =============================================================================
# INTEGRATION SETTINGS
# =============================================================================

# External tool integration
export JIRA_INTEGRATION="false"                # Enable Jira integration
export JIRA_URL=""                             # Jira instance URL
export JIRA_USERNAME=""                        # Jira username
export JIRA_TOKEN=""                           # Jira API token

export CONFLUENCE_INTEGRATION="false"          # Enable Confluence integration
export CONFLUENCE_URL=""                       # Confluence instance URL
export CONFLUENCE_SPACE=""                     # Confluence space key

# Analytics integration
export GOOGLE_ANALYTICS_ID=""                  # Google Analytics tracking ID
export MIXPANEL_TOKEN=""                       # Mixpanel project token

# =============================================================================
# CUSTOM HOOKS
# =============================================================================

# Custom script hooks (optional)
export PRE_SETUP_HOOK=""                       # Script to run before setup
export POST_SETUP_HOOK=""                      # Script to run after setup
export PRE_ISSUE_CREATE_HOOK=""                # Script to run before creating issues
export POST_ISSUE_CREATE_HOOK=""               # Script to run after creating issues

# =============================================================================
# ENVIRONMENT-SPECIFIC OVERRIDES
# =============================================================================

# Development environment overrides
if [[ "$ENV" == "development" ]]; then
    export DRY_RUN="true"
    export DEBUG_MODE="true"
    export BATCH_SIZE="5"
    export RATE_LIMIT_DELAY="3"
fi

# Production environment overrides
if [[ "$ENV" == "production" ]]; then
    export DRY_RUN="false"
    export CI_MODE="true"
    export LOG_LEVEL="WARN"
    export BATCH_SIZE="20"
fi

# =============================================================================
# VALIDATION AND HELPERS
# =============================================================================

# Function to validate required configuration
validate_config() {
    local errors=0
    
    if [[ -z "$GITHUB_OWNER" ]]; then
        echo "ERROR: GITHUB_OWNER is required"
        errors=$((errors + 1))
    fi
    
    if [[ -z "$GITHUB_REPO" ]]; then
        echo "ERROR: GITHUB_REPO is required"
        errors=$((errors + 1))
    fi
    
    if [[ -z "$PROJECT_NAME" ]]; then
        echo "ERROR: PROJECT_NAME is required"
        errors=$((errors + 1))
    fi
    
    if [[ $errors -gt 0 ]]; then
        echo "Configuration validation failed with $errors errors"
        return 1
    fi
    
    return 0
}

# Function to show configuration summary
show_config() {
    echo "=== Spec-Kit Configuration Summary ==="
    echo "Repository: $GITHUB_OWNER/$GITHUB_REPO"
    echo "Project: $PROJECT_NAME"
    echo "Start Date: $PROJECT_START_DATE"
    echo "Dry Run: $DRY_RUN"
    echo "Story Points: $STORY_POINT_MAPPING"
    echo "======================================="
}

# Auto-validation (if not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_config
    show_config
fi

# =============================================================================
# NOTES AND TIPS
# =============================================================================

# Configuration Tips:
# 1. Copy this file to config.sh: cp config.example.sh config.sh
# 2. Update GITHUB_OWNER and GITHUB_REPO with your repository details
# 3. Customize PROJECT_NAME and PROJECT_DESCRIPTION
# 4. Adjust epic task ranges to match your project structure
# 5. Set team member usernames for assignment tracking
# 6. Enable integrations by setting appropriate URLs and tokens
# 7. Use environment-specific overrides for different deployment contexts

# Security Notes:
# 1. Never commit config.sh with real credentials to version control
# 2. Use environment variables or secure vaults for sensitive data
# 3. Rotate API tokens regularly
# 4. Review permissions for GitHub tokens and external integrations

# Performance Notes:
# 1. Adjust BATCH_SIZE and RATE_LIMIT_DELAY based on GitHub API limits
# 2. Use larger batches for faster processing, smaller for stability
# 3. Increase delays if you encounter rate limiting issues
# 4. Monitor GitHub API usage in your repository settings