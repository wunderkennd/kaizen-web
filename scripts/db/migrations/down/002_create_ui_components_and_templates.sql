-- Rollback: Create UI components and templates tables
-- Version: 002
-- Description: Rollback for UI components and templates migration

BEGIN;

-- Drop RLS policies
DROP POLICY IF EXISTS component_library_org_access ON component_library;
DROP POLICY IF EXISTS ui_templates_org_access ON ui_templates;

-- Drop functions
DROP FUNCTION IF EXISTS render_ui_template(UUID, UUID, JSONB);
DROP FUNCTION IF EXISTS track_component_usage(UUID, UUID, interaction_type);

-- Drop triggers
DROP TRIGGER IF EXISTS update_component_library_updated_at ON component_library;
DROP TRIGGER IF EXISTS update_ui_templates_updated_at ON ui_templates;
DROP TRIGGER IF EXISTS update_ui_instances_updated_at ON ui_instances;
DROP TRIGGER IF EXISTS update_ui_themes_updated_at ON ui_themes;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS component_usage_analytics;
DROP TABLE IF EXISTS ui_performance_metrics;
DROP TABLE IF EXISTS component_interactions;
DROP TABLE IF EXISTS ui_themes;
DROP TABLE IF EXISTS ui_instances;
DROP TABLE IF EXISTS ui_templates;
DROP TABLE IF EXISTS component_library;

-- Drop custom types
DROP TYPE IF EXISTS interaction_type;
DROP TYPE IF EXISTS device_type;
DROP TYPE IF EXISTS ui_framework;
DROP TYPE IF EXISTS template_type;
DROP TYPE IF EXISTS component_status;
DROP TYPE IF EXISTS component_type;

COMMIT;