-- Rollback: Create rules engine tables
-- Version: 003
-- Description: Rollback for rules engine migration

BEGIN;

-- Drop RLS policies
DROP POLICY IF EXISTS rule_groups_org_access ON rule_groups;
DROP POLICY IF EXISTS rules_org_access ON rules;

-- Drop functions
DROP FUNCTION IF EXISTS is_feature_enabled(VARCHAR(255), UUID, UUID, JSONB);
DROP FUNCTION IF EXISTS execute_rule_actions(UUID, UUID, JSONB);
DROP FUNCTION IF EXISTS evaluate_rule_conditions(UUID, UUID, JSONB);

-- Drop triggers
DROP TRIGGER IF EXISTS update_rule_groups_updated_at ON rule_groups;
DROP TRIGGER IF EXISTS update_rules_updated_at ON rules;
DROP TRIGGER IF EXISTS update_user_segments_updated_at ON user_segments;
DROP TRIGGER IF EXISTS update_feature_flags_updated_at ON feature_flags;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS feature_flag_evaluations;
DROP TABLE IF EXISTS feature_flags;
DROP TABLE IF EXISTS user_segment_memberships;
DROP TABLE IF EXISTS user_segments;
DROP TABLE IF EXISTS rule_dependencies;
DROP TABLE IF EXISTS condition_cache;
DROP TABLE IF EXISTS rule_executions;
DROP TABLE IF EXISTS rule_actions;
DROP TABLE IF EXISTS rule_conditions;
DROP TABLE IF EXISTS rules;
DROP TABLE IF EXISTS rule_groups;

-- Drop custom types
DROP TYPE IF EXISTS execution_status;
DROP TYPE IF EXISTS execution_mode;
DROP TYPE IF EXISTS action_type;
DROP TYPE IF EXISTS condition_type;
DROP TYPE IF EXISTS condition_operator;
DROP TYPE IF EXISTS rule_priority;
DROP TYPE IF EXISTS rule_status;

COMMIT;