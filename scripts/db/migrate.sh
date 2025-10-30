#!/bin/bash

# KAIZEN Database Migration Runner
# Supports forward and rollback migrations with proper versioning

set -euo pipefail

# Configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-kaizen_db}"
DB_USER="${DB_USER:-kaizen}"
DB_PASSWORD="${DB_PASSWORD:-kaizen_dev_password}"
MIGRATIONS_DIR="${MIGRATIONS_DIR:-$(dirname "$0")/migrations}"
SCHEMA_MIGRATIONS_TABLE="schema_migrations"

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

# Execute SQL with error handling
execute_sql() {
    local sql="$1"
    local description="${2:-SQL command}"
    
    log_info "Executing: $description"
    if ! psql "$(get_db_url)" -c "$sql" > /dev/null 2>&1; then
        log_error "Failed to execute: $description"
        return 1
    fi
    return 0
}

# Execute SQL file with error handling
execute_sql_file() {
    local file="$1"
    local description="${2:-SQL file}"
    
    log_info "Executing file: $file"
    if ! psql "$(get_db_url)" -f "$file" > /dev/null 2>&1; then
        log_error "Failed to execute file: $file"
        return 1
    fi
    return 0
}

# Initialize schema migrations table
init_migrations_table() {
    log_info "Initializing schema migrations table"
    
    local sql="
    CREATE TABLE IF NOT EXISTS ${SCHEMA_MIGRATIONS_TABLE} (
        version VARCHAR(255) PRIMARY KEY,
        filename VARCHAR(255) NOT NULL,
        applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        checksum VARCHAR(64) NOT NULL,
        execution_time_ms INTEGER NOT NULL DEFAULT 0
    );
    
    CREATE INDEX IF NOT EXISTS idx_schema_migrations_applied_at 
    ON ${SCHEMA_MIGRATIONS_TABLE}(applied_at);
    "
    
    execute_sql "$sql" "Initialize migrations table"
}

# Calculate file checksum
calculate_checksum() {
    local file="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | cut -d' ' -f1
    else
        log_error "No checksum utility found (sha256sum or shasum)"
        exit 1
    fi
}

# Check if migration was already applied
is_migration_applied() {
    local version="$1"
    local count
    count=$(psql "$(get_db_url)" -t -c "SELECT COUNT(*) FROM ${SCHEMA_MIGRATIONS_TABLE} WHERE version = '$version';" 2>/dev/null | tr -d ' ' || echo "0")
    [ "$count" -gt 0 ]
}

# Get applied migrations
get_applied_migrations() {
    psql "$(get_db_url)" -t -c "SELECT version FROM ${SCHEMA_MIGRATIONS_TABLE} ORDER BY version;" 2>/dev/null | sed 's/^ *//' | grep -v '^$' || true
}

# Record migration as applied
record_migration() {
    local version="$1"
    local filename="$2"
    local checksum="$3"
    local execution_time="$4"
    
    local sql="
    INSERT INTO ${SCHEMA_MIGRATIONS_TABLE} (version, filename, checksum, execution_time_ms)
    VALUES ('$version', '$filename', '$checksum', $execution_time)
    ON CONFLICT (version) DO UPDATE SET
        applied_at = CURRENT_TIMESTAMP,
        checksum = EXCLUDED.checksum,
        execution_time_ms = EXCLUDED.execution_time_ms;
    "
    
    execute_sql "$sql" "Record migration $version"
}

# Remove migration record
remove_migration_record() {
    local version="$1"
    
    local sql="DELETE FROM ${SCHEMA_MIGRATIONS_TABLE} WHERE version = '$version';"
    execute_sql "$sql" "Remove migration record $version"
}

# Get migration version from filename
get_version_from_filename() {
    local filename="$1"
    echo "$filename" | sed 's/^\([0-9]*\)_.*/\1/'
}

# Run up migration
run_up_migration() {
    local file="$1"
    local filename
    filename=$(basename "$file")
    local version
    version=$(get_version_from_filename "$filename")
    
    if is_migration_applied "$version"; then
        log_warning "Migration $version already applied, skipping"
        return 0
    fi
    
    log_info "Applying migration: $filename"
    
    local checksum
    checksum=$(calculate_checksum "$file")
    
    local start_time
    start_time=$(date +%s%3N)
    
    if execute_sql_file "$file" "Migration $filename"; then
        local end_time
        end_time=$(date +%s%3N)
        local execution_time=$((end_time - start_time))
        
        record_migration "$version" "$filename" "$checksum" "$execution_time"
        log_success "Applied migration: $filename (${execution_time}ms)"
        return 0
    else
        log_error "Failed to apply migration: $filename"
        return 1
    fi
}

# Run down migration
run_down_migration() {
    local file="$1"
    local filename
    filename=$(basename "$file")
    local version
    version=$(get_version_from_filename "$filename")
    
    if ! is_migration_applied "$version"; then
        log_warning "Migration $version not applied, skipping rollback"
        return 0
    fi
    
    log_info "Rolling back migration: $filename"
    
    if execute_sql_file "$file" "Rollback $filename"; then
        remove_migration_record "$version"
        log_success "Rolled back migration: $filename"
        return 0
    else
        log_error "Failed to rollback migration: $filename"
        return 1
    fi
}

# List migrations status
list_migrations() {
    log_info "Migration status:"
    echo
    printf "%-15s %-50s %-20s\n" "VERSION" "FILENAME" "STATUS"
    echo "-------------------------------------------------------------------------------"
    
    local applied_migrations
    applied_migrations=$(get_applied_migrations)
    
    for file in "$MIGRATIONS_DIR"/up/*.sql; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        local filename
        filename=$(basename "$file")
        local version
        version=$(get_version_from_filename "$filename")
        
        local status="PENDING"
        if echo "$applied_migrations" | grep -q "^$version$"; then
            status="APPLIED"
        fi
        
        printf "%-15s %-50s %-20s\n" "$version" "$filename" "$status"
    done
}

# Migrate up to latest or specific version
migrate_up() {
    local target_version="$1"
    
    init_migrations_table
    
    local migration_files
    migration_files=$(find "$MIGRATIONS_DIR/up" -name "*.sql" -type f | sort)
    
    if [ -z "$migration_files" ]; then
        log_warning "No migration files found in $MIGRATIONS_DIR/up"
        return 0
    fi
    
    local applied_count=0
    for file in $migration_files; do
        local filename
        filename=$(basename "$file")
        local version
        version=$(get_version_from_filename "$filename")
        
        # If target version specified, stop after reaching it
        if [ -n "$target_version" ] && [ "$version" -gt "$target_version" ]; then
            break
        fi
        
        if run_up_migration "$file"; then
            ((applied_count++))
        else
            log_error "Migration failed, stopping"
            exit 1
        fi
    done
    
    if [ $applied_count -eq 0 ]; then
        log_info "No new migrations to apply"
    else
        log_success "Applied $applied_count migration(s)"
    fi
}

# Migrate down by count or to specific version
migrate_down() {
    local target="$1"
    
    init_migrations_table
    
    local applied_migrations
    applied_migrations=$(get_applied_migrations | sort -nr)
    
    if [ -z "$applied_migrations" ]; then
        log_warning "No migrations to rollback"
        return 0
    fi
    
    local rollback_count=0
    local max_rollbacks
    
    # If target is a number, treat as rollback count
    if [[ "$target" =~ ^[0-9]+$ ]]; then
        max_rollbacks="$target"
    else
        # Otherwise, rollback until we reach the target version
        max_rollbacks=999999
    fi
    
    for version in $applied_migrations; do
        if [ $rollback_count -ge $max_rollbacks ]; then
            break
        fi
        
        # If target is a version number, stop when we reach it
        if [[ ! "$target" =~ ^[0-9]+$ ]] && [ "$version" -le "$target" ]; then
            break
        fi
        
        local down_file="$MIGRATIONS_DIR/down/${version}_*.sql"
        local down_files
        down_files=$(ls $down_file 2>/dev/null || true)
        
        if [ -z "$down_files" ]; then
            log_error "No rollback file found for migration $version"
            exit 1
        fi
        
        for file in $down_files; do
            if run_down_migration "$file"; then
                ((rollback_count++))
                break
            else
                log_error "Rollback failed, stopping"
                exit 1
            fi
        done
    done
    
    if [ $rollback_count -eq 0 ]; then
        log_info "No migrations to rollback"
    else
        log_success "Rolled back $rollback_count migration(s)"
    fi
}

# Show help
show_help() {
    cat << EOF
KAIZEN Database Migration Tool

Usage: $0 COMMAND [OPTIONS]

Commands:
    up [VERSION]        Apply all pending migrations or up to specific version
    down COUNT|VERSION  Rollback COUNT migrations or down to VERSION
    status              Show migration status
    create NAME         Create new migration files (up/down pair)

Examples:
    $0 up                    # Apply all pending migrations
    $0 up 003               # Apply migrations up to version 003
    $0 down 1               # Rollback last migration
    $0 down 001             # Rollback to migration 001
    $0 status               # Show migration status
    $0 create add_users     # Create new migration files

Environment Variables:
    DB_HOST           Database host (default: localhost)
    DB_PORT           Database port (default: 5432)
    DB_NAME           Database name (default: kaizen_db)
    DB_USER           Database user (default: kaizen)
    DB_PASSWORD       Database password (default: kaizen_dev_password)
    MIGRATIONS_DIR    Migrations directory (default: ./migrations)

EOF
}

# Create new migration files
create_migration() {
    local name="$1"
    
    if [ -z "$name" ]; then
        log_error "Migration name is required"
        exit 1
    fi
    
    # Generate version number based on timestamp
    local version
    version=$(date +%Y%m%d%H%M%S)
    
    local up_file="$MIGRATIONS_DIR/up/${version}_${name}.sql"
    local down_file="$MIGRATIONS_DIR/down/${version}_${name}.sql"
    
    # Create directories if they don't exist
    mkdir -p "$MIGRATIONS_DIR/up"
    mkdir -p "$MIGRATIONS_DIR/down"
    
    # Create up migration template
    cat > "$up_file" << EOF
-- Migration: $name
-- Version: $version
-- Description: Add description here

BEGIN;

-- Add your migration SQL here


COMMIT;
EOF
    
    # Create down migration template
    cat > "$down_file" << EOF
-- Rollback: $name
-- Version: $version
-- Description: Rollback for $name migration

BEGIN;

-- Add your rollback SQL here


COMMIT;
EOF
    
    log_success "Created migration files:"
    log_info "  Up:   $up_file"
    log_info "  Down: $down_file"
}

# Check dependencies
check_dependencies() {
    if ! command -v psql >/dev/null 2>&1; then
        log_error "psql command not found. Please install PostgreSQL client."
        exit 1
    fi
}

# Main execution
main() {
    check_dependencies
    
    local command="${1:-}"
    
    case "$command" in
        "up")
            migrate_up "${2:-}"
            ;;
        "down")
            if [ -z "${2:-}" ]; then
                log_error "Rollback count or target version required"
                show_help
                exit 1
            fi
            migrate_down "$2"
            ;;
        "status")
            list_migrations
            ;;
        "create")
            create_migration "${2:-}"
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

# Create migrations directory structure if it doesn't exist
mkdir -p "$MIGRATIONS_DIR/up"
mkdir -p "$MIGRATIONS_DIR/down"

main "$@"