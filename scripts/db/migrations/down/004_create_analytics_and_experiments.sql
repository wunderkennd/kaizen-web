-- Rollback: Create analytics and experimentation tables
-- Version: 004
-- Description: Rollback for analytics and experimentation migration

BEGIN;

-- Drop RLS policies
DROP POLICY IF EXISTS events_org_access ON events;
DROP POLICY IF EXISTS experiments_org_access ON experiments;

-- Drop functions
DROP FUNCTION IF EXISTS calculate_experiment_stats(UUID);
DROP FUNCTION IF EXISTS track_conversion(UUID, UUID, DECIMAL(12,2));
DROP FUNCTION IF EXISTS track_experiment_exposure(UUID, UUID, UUID);

-- Drop triggers
DROP TRIGGER IF EXISTS update_funnels_updated_at ON funnels;
DROP TRIGGER IF EXISTS update_experiments_updated_at ON experiments;
DROP TRIGGER IF EXISTS update_experiment_variants_updated_at ON experiment_variants;
DROP TRIGGER IF EXISTS update_cohorts_updated_at ON cohorts;

-- Drop partitioned tables
DROP TABLE IF EXISTS events_y2024m01;
DROP TABLE IF EXISTS events_y2024m02;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS analytics_snapshots;
DROP TABLE IF EXISTS cohort_users;
DROP TABLE IF EXISTS cohorts;
DROP TABLE IF EXISTS conversion_goals;
DROP TABLE IF EXISTS experiment_assignments;
DROP TABLE IF EXISTS experiment_variants;
DROP TABLE IF EXISTS experiments;
DROP TABLE IF EXISTS funnel_sessions;
DROP TABLE IF EXISTS funnels;
DROP TABLE IF EXISTS events;

-- Drop custom types
DROP TYPE IF EXISTS conversion_type;
DROP TYPE IF EXISTS statistical_significance;
DROP TYPE IF EXISTS allocation_method;
DROP TYPE IF EXISTS experiment_type;
DROP TYPE IF EXISTS experiment_status;
DROP TYPE IF EXISTS event_type;

COMMIT;