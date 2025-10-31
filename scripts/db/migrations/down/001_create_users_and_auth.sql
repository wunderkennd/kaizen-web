-- Rollback: Create users and authentication tables
-- Version: 001
-- Description: Rollback for users and authentication tables migration

BEGIN;

-- Drop RLS policies
DROP POLICY IF EXISTS users_own_data ON users;
DROP POLICY IF EXISTS users_org_admin ON users;

-- Drop functions
DROP FUNCTION IF EXISTS log_user_activity(UUID, UUID, VARCHAR(100), VARCHAR(50), TEXT, JSONB, INET, TEXT);
DROP FUNCTION IF EXISTS update_user_pcm_stage(UUID, pcm_stage, DECIMAL(5,4), VARCHAR(255), JSONB);
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop triggers
DROP TRIGGER IF EXISTS update_organizations_updated_at ON organizations;
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_user_auth_providers_updated_at ON user_auth_providers;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS user_activity_log;
DROP TABLE IF EXISTS user_pcm_journey;
DROP TABLE IF EXISTS email_verification_tokens;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS user_auth_providers;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS organizations;

-- Drop custom types
DROP TYPE IF EXISTS session_status;
DROP TYPE IF EXISTS user_role;
DROP TYPE IF EXISTS pcm_stage;
DROP TYPE IF EXISTS auth_provider;
DROP TYPE IF EXISTS user_status;

COMMIT;