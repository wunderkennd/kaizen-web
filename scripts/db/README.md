# KAIZEN Database Management

This directory contains database migration tools and seed data for the KAIZEN platform.

## Overview

The KAIZEN platform uses PostgreSQL as its primary database with comprehensive migration and seeding tools to manage schema changes and development data.

## Database Schema

The database is organized into several key areas:

### 1. User Management & Authentication (T012)
- **Organizations**: Multi-tenant organization management
- **Users**: Comprehensive user profiles with PCM (Preference-Cognitive-Motivational) classification
- **Authentication**: OAuth providers, sessions, password reset, email verification
- **User Journey**: PCM stage tracking and user activity logging

### 2. UI Components & Templates (T013)
- **Component Library**: Reusable UI components with versioning
- **UI Templates**: Complete interface layouts and page templates
- **UI Instances**: Deployed template instances with personalization
- **Performance Tracking**: Component usage analytics and performance metrics
- **Theming**: Comprehensive theme management system

### 3. Rules Engine (T014)
- **Rule Groups**: Organized rule collections with execution order
- **Rules**: Conditional logic with priority and scheduling
- **Conditions**: Complex condition evaluation with multiple operators
- **Actions**: Executable actions triggered by rule conditions
- **User Segments**: Dynamic user segmentation for targeting
- **Feature Flags**: A/B testing and feature rollout management

### 4. Analytics & Experimentation (T015)
- **Event Tracking**: Comprehensive event analytics with device/context data
- **Experiments**: A/B testing and multivariate experimentation
- **Funnels**: User journey and conversion funnel analysis
- **Cohorts**: User cohort analysis for retention tracking
- **Performance Metrics**: Real-time analytics and dashboard data

## Migration Tools

### Migration Runner (`migrate.sh`)

A comprehensive migration tool with forward and rollback capabilities.

```bash
# Apply all pending migrations
./scripts/db/migrate.sh up

# Apply migrations up to specific version
./scripts/db/migrate.sh up 003

# Rollback last migration
./scripts/db/migrate.sh down 1

# Rollback to specific version
./scripts/db/migrate.sh down 002

# Show migration status
./scripts/db/migrate.sh status

# Create new migration
./scripts/db/migrate.sh create add_user_preferences
```

#### Environment Variables

```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=kaizen_db
export DB_USER=kaizen
export DB_PASSWORD=kaizen_dev_password
export MIGRATIONS_DIR=./migrations
```

### Migration Structure

```
scripts/db/migrations/
├── up/
│   ├── 001_create_users_and_auth.sql
│   ├── 002_create_ui_components_and_templates.sql
│   ├── 003_create_rules_engine.sql
│   └── 004_create_analytics_and_experiments.sql
└── down/
    ├── 001_create_users_and_auth.sql
    ├── 002_create_ui_components_and_templates.sql
    ├── 003_create_rules_engine.sql
    └── 004_create_analytics_and_experiments.sql
```

### Features

- **Idempotent Migrations**: Safe to run multiple times
- **Checksums**: Verify migration integrity
- **Execution Tracking**: Detailed timing and status tracking
- **Rollback Support**: Clean rollback with down migrations
- **Version Control**: Proper migration versioning and dependencies

## Seed Data

### Seed Runner (`seed.sh`)

Tool for loading development and test data.

```bash
# Load seed data
./scripts/db/seed.sh load

# Clear and reload all data
./scripts/db/seed.sh reload

# Clear data only
./scripts/db/seed.sh clear

# Verify seeded data
./scripts/db/seed.sh verify

# Create backup
./scripts/db/seed.sh backup
```

### Development Data

The seed data includes:

- **Sample Organizations**: Demo companies with different billing plans
- **Test Users**: Users in different PCM stages with realistic profiles
- **UI Components**: Basic component library with buttons, inputs, cards
- **Templates**: Login page and dashboard templates
- **Rules**: Sample onboarding, personalization, and engagement rules
- **Experiments**: A/B tests for CTA buttons and onboarding flows
- **Analytics**: Sample events, funnels, and cohorts

## Database Setup

### Local Development

1. **Start PostgreSQL** (using Docker Compose):
   ```bash
   docker-compose up -d postgres
   ```

2. **Run Migrations**:
   ```bash
   ./scripts/db/migrate.sh up
   ```

3. **Load Seed Data**:
   ```bash
   ./scripts/db/seed.sh load
   ```

### Production Deployment

1. **Set Environment Variables**:
   ```bash
   export DB_HOST=your-production-host
   export DB_NAME=your-production-db
   export DB_USER=your-production-user
   export DB_PASSWORD=your-production-password
   ```

2. **Run Migrations Only**:
   ```bash
   ./scripts/db/migrate.sh up
   ```

   > **Note**: Never load seed data in production

## Security Features

### Row Level Security (RLS)

The database implements comprehensive RLS policies:

- **Organization Isolation**: Users can only access data from their organization
- **User Permissions**: Role-based access control
- **Data Privacy**: Sensitive data protection

### Encryption

- **Password Hashing**: bcrypt with configurable rounds
- **Token Encryption**: Secure token storage
- **PII Protection**: Encrypted sensitive data fields

## Performance Optimizations

### Indexing Strategy

- **Composite Indexes**: Optimized for common query patterns
- **Partial Indexes**: Conditional indexing for better performance
- **GIN Indexes**: JSONB and array column optimization

### Partitioning

- **Events Table**: Partitioned by date for analytics performance
- **Time-Series Data**: Monthly partitions with automatic cleanup

### Caching

- **Condition Cache**: Rule condition evaluation caching
- **Segment Cache**: User segment membership caching
- **Component Cache**: UI component rendering cache

## Monitoring and Maintenance

### Health Checks

The migration and seed scripts include:

- **Connection Testing**: Verify database connectivity
- **Data Validation**: Ensure data integrity
- **Performance Metrics**: Track execution times

### Backup Strategy

- **Automatic Backups**: Before destructive operations
- **Point-in-Time Recovery**: Transaction log backup
- **Migration Rollback**: Safe rollback procedures

## CI/CD Integration

### GitHub Actions

The database tools integrate with CI/CD pipelines:

- **Migration Testing**: Automated migration testing
- **Seed Data Validation**: Verify seed data integrity
- **Performance Testing**: Database performance benchmarks

### Cloud Run Deployment

- **Pre-deployment Migrations**: Automatic schema updates
- **Zero-Downtime Deployments**: Safe migration strategies
- **Rollback Support**: Automatic rollback on failure

## Troubleshooting

### Common Issues

1. **Connection Errors**:
   - Check database credentials
   - Verify network connectivity
   - Ensure PostgreSQL is running

2. **Migration Failures**:
   - Check migration file syntax
   - Verify schema dependencies
   - Review error logs

3. **Permission Errors**:
   - Verify user permissions
   - Check RLS policies
   - Ensure proper role assignments

### Debug Mode

Enable verbose logging:

```bash
export DEBUG=1
./scripts/db/migrate.sh up
```

### Log Analysis

Check migration logs:

```sql
SELECT * FROM schema_migrations ORDER BY applied_at DESC;
```

## Contributing

### Adding Migrations

1. **Create Migration**:
   ```bash
   ./scripts/db/migrate.sh create your_migration_name
   ```

2. **Edit Files**:
   - Edit `up/YYYYMMDDHHMMSS_your_migration_name.sql`
   - Edit `down/YYYYMMDDHHMMSS_your_migration_name.sql`

3. **Test Migration**:
   ```bash
   ./scripts/db/migrate.sh up
   ./scripts/db/migrate.sh down 1
   ./scripts/db/migrate.sh up
   ```

### Best Practices

- **Atomic Migrations**: Use transactions for all changes
- **Backward Compatibility**: Ensure rollback safety
- **Performance Testing**: Test with realistic data volumes
- **Documentation**: Document schema changes thoroughly

## API Reference

### Migration Functions

- `update_user_pcm_stage()`: Update user PCM classification
- `log_user_activity()`: Track user activities
- `track_component_usage()`: Record component interactions
- `evaluate_rule_conditions()`: Evaluate rule logic
- `track_experiment_exposure()`: Track A/B test exposure

### Utility Functions

- `calculate_experiment_stats()`: Generate experiment statistics
- `render_ui_template()`: Render personalized templates
- `is_feature_enabled()`: Check feature flag status