#!/bin/bash

# KAIZEN Database Seeding Script
# Loads development and test data into the database

set -euo pipefail

# Configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-kaizen_db}"
DB_USER="${DB_USER:-kaizen}"
DB_PASSWORD="${DB_PASSWORD:-kaizen_dev_password}"
SEEDS_DIR="${SEEDS_DIR:-$(dirname "$0")/seeds}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Database connection string
get_db_url() {
    echo "postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable"
}

# Execute SQL file with error handling
execute_sql_file() {
    local file="$1"
    local description="${2:-SQL file}"
    
    log_info "Executing: $description"
    if ! psql "$(get_db_url)" -f "$file" > /dev/null 2>&1; then
        log_error "Failed to execute: $file"
        return 1
    fi
    return 0
}

# Check if database has data
check_existing_data() {
    local count
    local org_uuid="00000000-0000-0000-0000-000000000000"
    count=$(psql "$(get_db_url)" -v org_uuid="$org_uuid" -t -c "SELECT COUNT(*) FROM users WHERE organization_id != :'org_uuid';" 2>/dev/null | tr -d ' ' || echo "0")
    echo "$count"
}

# Backup existing data
backup_data() {
    local backup_file="backup_$(date +%Y%m%d_%H%M%S).sql"
    log_info "Creating backup: $backup_file"
    
    pg_dump "$(get_db_url)" > "$backup_file"
    
    if [ $? -eq 0 ]; then
        log_success "Backup created: $backup_file"
        echo "$backup_file"
    else
        log_error "Failed to create backup"
        return 1
    fi
}

# Clear existing data (except system data)
clear_data() {
    log_info "Clearing existing data (preserving system data)..."
    
    local sql="
    -- Disable foreign key checks temporarily
    SET session_replication_role = replica;
    
    -- Clear user-generated data (preserve system organization)
    DELETE FROM analytics_snapshots WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM cohort_users;
    DELETE FROM cohorts WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM conversion_goals;
    DELETE FROM experiment_assignments;
    DELETE FROM experiment_variants;
    DELETE FROM experiments WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM funnel_sessions;
    DELETE FROM funnels WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM events WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM feature_flag_evaluations;
    DELETE FROM feature_flags WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM user_segment_memberships;
    DELETE FROM user_segments WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM rule_dependencies;
    DELETE FROM condition_cache;
    DELETE FROM rule_executions;
    DELETE FROM rule_actions;
    DELETE FROM rule_conditions;
    DELETE FROM rules WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM rule_groups WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM component_usage_analytics;
    DELETE FROM ui_performance_metrics;
    DELETE FROM component_interactions;
    DELETE FROM ui_instances WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM ui_themes WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM ui_templates WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM component_library WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM user_activity_log;
    DELETE FROM user_pcm_journey;
    DELETE FROM email_verification_tokens;
    DELETE FROM password_reset_tokens;
    DELETE FROM user_sessions;
    DELETE FROM user_auth_providers;
    DELETE FROM users WHERE organization_id != '00000000-0000-0000-0000-000000000000';
    DELETE FROM organizations WHERE id != '00000000-0000-0000-0000-000000000000';
    
    -- Re-enable foreign key checks
    SET session_replication_role = DEFAULT;
    "
    
    if psql "$(get_db_url)" -c "$sql" > /dev/null 2>&1; then
        log_success "Existing data cleared"
        return 0
    else
        log_error "Failed to clear existing data"
        return 1
    fi
}

# Load seed files
load_seeds() {
    local seed_files
    seed_files=$(find "$SEEDS_DIR" -name "*.sql" -type f | sort)
    
    if [ -z "$seed_files" ]; then
        log_warning "No seed files found in $SEEDS_DIR"
        return 0
    fi
    
    log_info "Loading seed files..."
    
    local loaded_count=0
    for file in $seed_files; do
        local filename
        filename=$(basename "$file")
        
        if execute_sql_file "$file" "Seed file: $filename"; then
            log_success "Loaded: $filename"
            ((loaded_count++))
        else
            log_error "Failed to load: $filename"
            return 1
        fi
    done
    
    log_success "Loaded $loaded_count seed file(s)"
    return 0
}

# Verify seeded data
verify_data() {
    log_info "Verifying seeded data..."
    
    local sql="
    SELECT 
        'organizations' as table_name, COUNT(*) as count FROM organizations
        WHERE id != '00000000-0000-0000-0000-000000000000'
    UNION ALL
    SELECT 'users', COUNT(*) FROM users 
        WHERE organization_id != '00000000-0000-0000-0000-000000000000'
    UNION ALL
    SELECT 'component_library', COUNT(*) FROM component_library
    UNION ALL
    SELECT 'ui_templates', COUNT(*) FROM ui_templates
    UNION ALL
    SELECT 'rules', COUNT(*) FROM rules
    UNION ALL
    SELECT 'experiments', COUNT(*) FROM experiments
    UNION ALL
    SELECT 'events', COUNT(*) FROM events
        WHERE organization_id != '00000000-0000-0000-0000-000000000000'
    ORDER BY table_name;
    "
    
    log_info "Data verification results:"
    psql "$(get_db_url)" -c "$sql"
}

# Show help
show_help() {
    cat << EOF
KAIZEN Database Seeding Tool

Usage: $0 COMMAND [OPTIONS]

Commands:
    load            Load seed data (default)
    clear           Clear existing data only
    reload          Clear and reload seed data
    verify          Verify existing data
    backup          Create database backup

Options:
    --force         Skip confirmation prompts
    --no-backup     Skip automatic backup (for reload)

Examples:
    $0 load                    # Load seed data
    $0 reload --force          # Clear and reload without prompts
    $0 clear --force           # Clear data without backup
    $0 verify                  # Check seeded data

Environment Variables:
    DB_HOST           Database host (default: localhost)
    DB_PORT           Database port (default: 5432)
    DB_NAME           Database name (default: kaizen_db)
    DB_USER           Database user (default: kaizen)
    DB_PASSWORD       Database password (default: kaizen_dev_password)
    SEEDS_DIR         Seeds directory (default: ./seeds)

EOF
}

# Check dependencies
check_dependencies() {
    if ! command -v psql >/dev/null 2>&1; then
        log_error "psql command not found. Please install PostgreSQL client."
        exit 1
    fi
    
    if ! command -v pg_dump >/dev/null 2>&1; then
        log_error "pg_dump command not found. Please install PostgreSQL client."
        exit 1
    fi
}

# Test database connection
test_connection() {
    log_info "Testing database connection..."
    
    if psql "$(get_db_url)" -c "SELECT 1;" > /dev/null 2>&1; then
        log_success "Database connection successful"
        return 0
    else
        log_error "Failed to connect to database"
        log_error "Connection string: $(get_db_url | sed 's/:.*@/:***@/')"
        return 1
    fi
}

# Main execution
main() {
    check_dependencies
    
    local command="${1:-load}"
    local force_flag=false
    local no_backup_flag=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force_flag=true
                shift
                ;;
            --no-backup)
                no_backup_flag=true
                shift
                ;;
            load|clear|reload|verify|backup|help|-h|--help)
                command="$1"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    case "$command" in
        "load")
            test_connection
            
            local existing_data
            existing_data=$(check_existing_data)
            
            if [ "$existing_data" -gt 0 ] && [ "$force_flag" = false ]; then
                log_warning "Database contains $existing_data existing user records"
                read -p "Continue loading seed data? This may cause conflicts (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log_info "Operation cancelled"
                    exit 0
                fi
            fi
            
            load_seeds
            verify_data
            ;;
            
        "clear")
            test_connection
            
            local existing_data
            existing_data=$(check_existing_data)
            
            if [ "$existing_data" -eq 0 ]; then
                log_info "No user data found to clear"
                exit 0
            fi
            
            if [ "$force_flag" = false ]; then
                log_warning "This will delete $existing_data user records and all associated data"
                read -p "Are you sure you want to clear all data? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log_info "Operation cancelled"
                    exit 0
                fi
            fi
            
            if [ "$no_backup_flag" = false ]; then
                backup_data
            fi
            
            clear_data
            log_success "Data cleared successfully"
            ;;
            
        "reload")
            test_connection
            
            local existing_data
            existing_data=$(check_existing_data)
            
            if [ "$existing_data" -gt 0 ] && [ "$force_flag" = false ]; then
                log_warning "This will delete $existing_data user records and reload seed data"
                read -p "Are you sure you want to reload all data? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log_info "Operation cancelled"
                    exit 0
                fi
            fi
            
            if [ "$existing_data" -gt 0 ] && [ "$no_backup_flag" = false ]; then
                backup_data
            fi
            
            if [ "$existing_data" -gt 0 ]; then
                clear_data
            fi
            
            load_seeds
            verify_data
            ;;
            
        "verify")
            test_connection
            verify_data
            ;;
            
        "backup")
            test_connection
            backup_data
            ;;
            
        "help"|"-h"|"--help")
            show_help
            ;;
            
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Create seeds directory if it doesn't exist
mkdir -p "$SEEDS_DIR"

main "$@"