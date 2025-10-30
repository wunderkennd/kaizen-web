-- Migration: Create users and authentication tables
-- Version: 001
-- Description: Create comprehensive user management system with PCM stages support

BEGIN;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "citext";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Custom types for user management
CREATE TYPE user_status AS ENUM (
    'active',
    'inactive', 
    'suspended',
    'pending_verification',
    'deleted'
);

CREATE TYPE auth_provider AS ENUM (
    'email',
    'google',
    'github',
    'microsoft',
    'apple'
);

CREATE TYPE pcm_stage AS ENUM (
    'awareness',    -- User is aware of the platform
    'attraction',   -- User is attracted to features
    'attachment',   -- User is attached and engaged
    'allegiance'    -- User has strong loyalty/advocacy
);

CREATE TYPE user_role AS ENUM (
    'user',
    'admin',
    'moderator',
    'analyst',
    'super_admin'
);

CREATE TYPE session_status AS ENUM (
    'active',
    'expired',
    'revoked'
);

-- Organizations table for multi-tenancy
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug CITEXT UNIQUE NOT NULL,
    domain VARCHAR(255),
    settings JSONB DEFAULT '{}',
    billing_plan VARCHAR(50) DEFAULT 'free',
    max_users INTEGER DEFAULT 5,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Users table with comprehensive profile information
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    email CITEXT UNIQUE NOT NULL,
    email_verified BOOLEAN DEFAULT false,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    username CITEXT UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    display_name VARCHAR(255),
    avatar_url TEXT,
    phone VARCHAR(20),
    phone_verified BOOLEAN DEFAULT false,
    bio TEXT,
    website VARCHAR(255),
    location VARCHAR(255),
    timezone VARCHAR(50) DEFAULT 'UTC',
    locale VARCHAR(10) DEFAULT 'en',
    date_of_birth DATE,
    status user_status DEFAULT 'pending_verification',
    role user_role DEFAULT 'user',
    
    -- PCM (Preference-Cognitive-Motivational) Classification
    current_pcm_stage pcm_stage DEFAULT 'awareness',
    pcm_stage_updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    pcm_confidence_score DECIMAL(5,4) DEFAULT 0.0, -- 0.0 to 1.0
    pcm_attributes JSONB DEFAULT '{}', -- Store detailed PCM analysis
    
    -- User preferences and settings
    preferences JSONB DEFAULT '{}',
    ui_preferences JSONB DEFAULT '{}', -- Theme, layout, etc.
    notification_preferences JSONB DEFAULT '{}',
    privacy_settings JSONB DEFAULT '{}',
    
    -- Engagement metrics
    last_login_at TIMESTAMP WITH TIME ZONE,
    last_active_at TIMESTAMP WITH TIME ZONE,
    login_count INTEGER DEFAULT 0,
    total_session_time INTEGER DEFAULT 0, -- in seconds
    
    -- Security and compliance
    password_hash TEXT, -- For email auth
    password_changed_at TIMESTAMP WITH TIME ZONE,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP WITH TIME ZONE,
    terms_accepted_at TIMESTAMP WITH TIME ZONE,
    privacy_policy_accepted_at TIMESTAMP WITH TIME ZONE,
    marketing_consent BOOLEAN DEFAULT false,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    tags TEXT[],
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_by UUID
);

-- Authentication providers for OAuth/SSO
CREATE TABLE user_auth_providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider auth_provider NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    provider_username VARCHAR(255),
    provider_email CITEXT,
    provider_data JSONB DEFAULT '{}',
    access_token_encrypted TEXT,
    refresh_token_encrypted TEXT,
    token_expires_at TIMESTAMP WITH TIME ZONE,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(provider, provider_user_id),
    UNIQUE(user_id, provider)
);

-- User sessions for security tracking
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    status session_status DEFAULT 'active',
    ip_address INET,
    user_agent TEXT,
    device_fingerprint VARCHAR(255),
    location_data JSONB DEFAULT '{}',
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Password reset tokens
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Email verification tokens
CREATE TABLE email_verification_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email CITEXT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User PCM journey tracking
CREATE TABLE user_pcm_journey (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    from_stage pcm_stage,
    to_stage pcm_stage NOT NULL,
    confidence_score DECIMAL(5,4) NOT NULL,
    trigger_event VARCHAR(255),
    trigger_data JSONB DEFAULT '{}',
    model_version VARCHAR(50),
    model_features JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User activity log for comprehensive tracking
CREATE TABLE user_activity_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES user_sessions(id) ON DELETE SET NULL,
    activity_type VARCHAR(100) NOT NULL,
    activity_category VARCHAR(50),
    description TEXT,
    metadata JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance optimization
CREATE INDEX idx_users_organization_id ON users(organization_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_current_pcm_stage ON users(current_pcm_stage);
CREATE INDEX idx_users_last_active_at ON users(last_active_at);
CREATE INDEX idx_users_created_at ON users(created_at);

CREATE INDEX idx_organizations_slug ON organizations(slug);
CREATE INDEX idx_organizations_domain ON organizations(domain);

CREATE INDEX idx_user_auth_providers_user_id ON user_auth_providers(user_id);
CREATE INDEX idx_user_auth_providers_provider ON user_auth_providers(provider);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_status ON user_sessions(status);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX idx_password_reset_tokens_token ON password_reset_tokens(token);
CREATE INDEX idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);

CREATE INDEX idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);
CREATE INDEX idx_email_verification_tokens_token ON email_verification_tokens(token);

CREATE INDEX idx_user_pcm_journey_user_id ON user_pcm_journey(user_id);
CREATE INDEX idx_user_pcm_journey_to_stage ON user_pcm_journey(to_stage);
CREATE INDEX idx_user_pcm_journey_created_at ON user_pcm_journey(created_at);

CREATE INDEX idx_user_activity_log_user_id ON user_activity_log(user_id);
CREATE INDEX idx_user_activity_log_activity_type ON user_activity_log(activity_type);
CREATE INDEX idx_user_activity_log_created_at ON user_activity_log(created_at);

-- GIN indexes for JSONB columns
CREATE INDEX idx_users_preferences_gin ON users USING GIN(preferences);
CREATE INDEX idx_users_pcm_attributes_gin ON users USING GIN(pcm_attributes);
CREATE INDEX idx_users_metadata_gin ON users USING GIN(metadata);
CREATE INDEX idx_user_activity_log_metadata_gin ON user_activity_log USING GIN(metadata);

-- Triggers for updated_at columns
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_organizations_updated_at 
    BEFORE UPDATE ON organizations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_auth_providers_updated_at 
    BEFORE UPDATE ON user_auth_providers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update PCM stage with journey tracking
CREATE OR REPLACE FUNCTION update_user_pcm_stage(
    p_user_id UUID,
    p_new_stage pcm_stage,
    p_confidence_score DECIMAL(5,4),
    p_trigger_event VARCHAR(255) DEFAULT NULL,
    p_trigger_data JSONB DEFAULT '{}'
) RETURNS VOID AS $$
DECLARE
    v_current_stage pcm_stage;
BEGIN
    -- Get current stage
    SELECT current_pcm_stage INTO v_current_stage 
    FROM users WHERE id = p_user_id;
    
    -- Only update if stage is different
    IF v_current_stage != p_new_stage THEN
        -- Update user's PCM stage
        UPDATE users 
        SET 
            current_pcm_stage = p_new_stage,
            pcm_stage_updated_at = CURRENT_TIMESTAMP,
            pcm_confidence_score = p_confidence_score
        WHERE id = p_user_id;
        
        -- Record journey transition
        INSERT INTO user_pcm_journey (
            user_id, from_stage, to_stage, confidence_score,
            trigger_event, trigger_data
        ) VALUES (
            p_user_id, v_current_stage, p_new_stage, p_confidence_score,
            p_trigger_event, p_trigger_data
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to log user activity
CREATE OR REPLACE FUNCTION log_user_activity(
    p_user_id UUID,
    p_session_id UUID,
    p_activity_type VARCHAR(100),
    p_activity_category VARCHAR(50) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}',
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_activity_id UUID;
BEGIN
    INSERT INTO user_activity_log (
        user_id, session_id, activity_type, activity_category,
        description, metadata, ip_address, user_agent
    ) VALUES (
        p_user_id, p_session_id, p_activity_type, p_activity_category,
        p_description, p_metadata, p_ip_address, p_user_agent
    ) RETURNING id INTO v_activity_id;
    
    -- Update user's last activity
    UPDATE users 
    SET last_active_at = CURRENT_TIMESTAMP 
    WHERE id = p_user_id;
    
    RETURN v_activity_id;
END;
$$ LANGUAGE plpgsql;

-- Row Level Security (RLS) setup
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_auth_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_pcm_journey ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activity_log ENABLE ROW LEVEL SECURITY;

-- RLS Policies (basic examples - adjust based on your auth system)
CREATE POLICY users_own_data ON users
    FOR ALL
    USING (id = current_setting('app.current_user_id')::UUID);

CREATE POLICY users_org_admin ON users
    FOR ALL
    USING (
        organization_id IN (
            SELECT organization_id FROM users 
            WHERE id = current_setting('app.current_user_id')::UUID 
            AND role IN ('admin', 'super_admin')
        )
    );

-- Create initial system organization
INSERT INTO organizations (id, name, slug, domain, billing_plan, max_users) 
VALUES (
    '00000000-0000-0000-0000-000000000000',
    'System',
    'system',
    'system.internal',
    'enterprise',
    999999
);

COMMIT;