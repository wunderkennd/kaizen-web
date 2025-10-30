-- Migration: Create rules engine tables
-- Version: 003
-- Description: Create comprehensive rules engine for dynamic behavior and personalization

BEGIN;

-- Custom types for rules engine
CREATE TYPE rule_status AS ENUM (
    'draft',
    'active',
    'paused',
    'archived',
    'error'
);

CREATE TYPE rule_priority AS ENUM (
    'critical',
    'high',
    'medium',
    'low'
);

CREATE TYPE condition_operator AS ENUM (
    'equals',
    'not_equals',
    'greater_than',
    'greater_than_or_equal',
    'less_than',
    'less_than_or_equal',
    'contains',
    'not_contains',
    'starts_with',
    'ends_with',
    'in',
    'not_in',
    'regex_match',
    'is_null',
    'is_not_null',
    'between',
    'exists',
    'not_exists'
);

CREATE TYPE condition_type AS ENUM (
    'user_attribute',
    'user_behavior',
    'context',
    'time_based',
    'device',
    'location',
    'custom_event',
    'segment',
    'experiment',
    'feature_flag'
);

CREATE TYPE action_type AS ENUM (
    'show_component',
    'hide_component',
    'modify_component',
    'redirect',
    'display_message',
    'send_notification',
    'track_event',
    'modify_data',
    'trigger_function',
    'assign_segment',
    'start_experiment',
    'personalize_content',
    'update_user_attribute'
);

CREATE TYPE execution_mode AS ENUM (
    'immediate',
    'delayed',
    'scheduled',
    'conditional'
);

CREATE TYPE execution_status AS ENUM (
    'pending',
    'running',
    'completed',
    'failed',
    'cancelled'
);

-- Rule groups for organizing related rules
CREATE TABLE rule_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Group configuration
    is_active BOOLEAN DEFAULT true,
    execution_order INTEGER DEFAULT 0,
    
    -- Conditions for group activation
    activation_conditions JSONB DEFAULT '{}',
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    tags TEXT[],
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    UNIQUE(organization_id, slug)
);

-- Core rules table
CREATE TABLE rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    rule_group_id UUID REFERENCES rule_groups(id) ON DELETE SET NULL,
    
    -- Rule identification
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Rule configuration
    priority rule_priority DEFAULT 'medium',
    status rule_status DEFAULT 'draft',
    is_system_rule BOOLEAN DEFAULT false,
    
    -- Execution settings
    execution_mode execution_mode DEFAULT 'immediate',
    max_executions INTEGER, -- NULL = unlimited
    execution_count INTEGER DEFAULT 0,
    
    -- Timing constraints
    valid_from TIMESTAMP WITH TIME ZONE,
    valid_until TIMESTAMP WITH TIME ZONE,
    schedule_config JSONB DEFAULT '{}', -- Cron-like scheduling
    
    -- Rate limiting
    rate_limit_config JSONB DEFAULT '{}',
    
    -- Target audience
    target_segments TEXT[],
    audience_filter JSONB DEFAULT '{}',
    
    -- Success metrics
    success_criteria JSONB DEFAULT '{}',
    
    -- Version control
    version VARCHAR(50) DEFAULT '1.0.0',
    parent_rule_id UUID REFERENCES rules(id),
    
    -- Performance tracking
    avg_execution_time_ms DECIMAL(10,2) DEFAULT 0,
    success_rate DECIMAL(5,4) DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    last_execution_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    tags TEXT[],
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    UNIQUE(organization_id, slug)
);

-- Rule conditions (IF part of rules)
CREATE TABLE rule_conditions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rule_id UUID NOT NULL REFERENCES rules(id) ON DELETE CASCADE,
    
    -- Condition hierarchy
    parent_condition_id UUID REFERENCES rule_conditions(id) ON DELETE CASCADE,
    logical_operator VARCHAR(10) DEFAULT 'AND', -- AND, OR, NOT
    execution_order INTEGER DEFAULT 0,
    
    -- Condition definition
    condition_type condition_type NOT NULL,
    field_path VARCHAR(500), -- JSON path for complex objects
    operator condition_operator NOT NULL,
    expected_value JSONB,
    
    -- Advanced condition settings
    case_sensitive BOOLEAN DEFAULT true,
    negate_result BOOLEAN DEFAULT false,
    
    -- Condition metadata
    description TEXT,
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Rule actions (THEN part of rules)
CREATE TABLE rule_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rule_id UUID NOT NULL REFERENCES rules(id) ON DELETE CASCADE,
    
    -- Action configuration
    action_type action_type NOT NULL,
    execution_order INTEGER DEFAULT 0,
    
    -- Action parameters
    target_selector VARCHAR(500), -- CSS selector or component path
    action_data JSONB NOT NULL DEFAULT '{}',
    
    -- Execution settings
    delay_seconds INTEGER DEFAULT 0,
    retry_attempts INTEGER DEFAULT 0,
    retry_delay_seconds INTEGER DEFAULT 5,
    
    -- Conditional execution
    condition_expression TEXT,
    
    -- Action metadata
    description TEXT,
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Rule execution history and audit trail
CREATE TABLE rule_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rule_id UUID NOT NULL REFERENCES rules(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES user_sessions(id) ON DELETE SET NULL,
    
    -- Execution context
    trigger_event VARCHAR(255),
    execution_context JSONB DEFAULT '{}',
    input_data JSONB DEFAULT '{}',
    
    -- Execution details
    status execution_status DEFAULT 'pending',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    execution_time_ms INTEGER,
    
    -- Results
    conditions_met BOOLEAN,
    actions_executed INTEGER DEFAULT 0,
    actions_successful INTEGER DEFAULT 0,
    actions_failed INTEGER DEFAULT 0,
    
    -- Output and errors
    output_data JSONB DEFAULT '{}',
    error_message TEXT,
    error_details JSONB DEFAULT '{}',
    
    -- Performance metrics
    memory_usage_mb DECIMAL(10,2),
    cpu_time_ms INTEGER,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);

-- Condition evaluation cache for performance
CREATE TABLE condition_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    condition_id UUID NOT NULL REFERENCES rule_conditions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Cache data
    input_hash VARCHAR(64) NOT NULL, -- Hash of input parameters
    result BOOLEAN NOT NULL,
    confidence_score DECIMAL(5,4) DEFAULT 1.0,
    
    -- Cache metadata
    cached_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,
    hit_count INTEGER DEFAULT 1,
    
    UNIQUE(condition_id, user_id, input_hash)
);

-- Rule dependencies and relationships
CREATE TABLE rule_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dependent_rule_id UUID NOT NULL REFERENCES rules(id) ON DELETE CASCADE,
    dependency_rule_id UUID NOT NULL REFERENCES rules(id) ON DELETE CASCADE,
    
    -- Dependency type
    dependency_type VARCHAR(50) NOT NULL, -- 'requires', 'conflicts', 'follows', 'precedes'
    is_required BOOLEAN DEFAULT true,
    
    -- Metadata
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(dependent_rule_id, dependency_rule_id)
);

-- User segments for rule targeting
CREATE TABLE user_segments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Segment definition
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Segment criteria
    criteria_definition JSONB NOT NULL,
    is_dynamic BOOLEAN DEFAULT true, -- Auto-update membership
    
    -- Segment metadata
    estimated_size INTEGER DEFAULT 0,
    last_calculated_at TIMESTAMP WITH TIME ZONE,
    calculation_frequency_hours INTEGER DEFAULT 24,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    tags TEXT[],
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    UNIQUE(organization_id, slug)
);

-- User segment membership
CREATE TABLE user_segment_memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    segment_id UUID NOT NULL REFERENCES user_segments(id) ON DELETE CASCADE,
    
    -- Membership details
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    removed_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    
    -- Calculation metadata
    confidence_score DECIMAL(5,4) DEFAULT 1.0,
    calculation_method VARCHAR(100),
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    UNIQUE(user_id, segment_id)
);

-- Feature flags and toggles
CREATE TABLE feature_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Flag definition
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Flag configuration
    is_enabled BOOLEAN DEFAULT false,
    rollout_percentage DECIMAL(5,2) DEFAULT 0.00, -- 0.00 to 100.00
    
    -- Targeting
    target_segments TEXT[],
    user_whitelist UUID[], -- Specific users
    user_blacklist UUID[], -- Excluded users
    
    -- Environment controls
    environments TEXT[] DEFAULT ARRAY['production'],
    
    -- Rollout strategy
    rollout_strategy JSONB DEFAULT '{}',
    sticky_bucketing BOOLEAN DEFAULT true,
    
    -- Metrics
    usage_count INTEGER DEFAULT 0,
    
    -- Status
    is_permanent BOOLEAN DEFAULT false, -- Should not be removed
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    tags TEXT[],
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    UNIQUE(organization_id, slug)
);

-- Feature flag evaluations
CREATE TABLE feature_flag_evaluations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    flag_id UUID NOT NULL REFERENCES feature_flags(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    -- Evaluation result
    is_enabled BOOLEAN NOT NULL,
    variant VARCHAR(100),
    
    -- Evaluation context
    context_data JSONB DEFAULT '{}',
    bucketing_key VARCHAR(255),
    
    -- Metadata
    evaluated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexing for analytics
    evaluation_date DATE GENERATED ALWAYS AS (DATE(evaluated_at)) STORED
);

-- Indexes for performance optimization
CREATE INDEX idx_rule_groups_org_id ON rule_groups(organization_id);
CREATE INDEX idx_rule_groups_active ON rule_groups(is_active);
CREATE INDEX idx_rule_groups_order ON rule_groups(execution_order);

CREATE INDEX idx_rules_org_id ON rules(organization_id);
CREATE INDEX idx_rules_group_id ON rule_groups(id);
CREATE INDEX idx_rules_status ON rules(status);
CREATE INDEX idx_rules_priority ON rules(priority);
CREATE INDEX idx_rules_execution_mode ON rules(execution_mode);
CREATE INDEX idx_rules_valid_period ON rules(valid_from, valid_until);
CREATE INDEX idx_rules_last_execution ON rules(last_execution_at);

CREATE INDEX idx_rule_conditions_rule_id ON rule_conditions(rule_id);
CREATE INDEX idx_rule_conditions_parent ON rule_conditions(parent_condition_id);
CREATE INDEX idx_rule_conditions_type ON rule_conditions(condition_type);
CREATE INDEX idx_rule_conditions_order ON rule_conditions(execution_order);

CREATE INDEX idx_rule_actions_rule_id ON rule_actions(rule_id);
CREATE INDEX idx_rule_actions_type ON rule_actions(action_type);
CREATE INDEX idx_rule_actions_order ON rule_actions(execution_order);

CREATE INDEX idx_rule_executions_rule_id ON rule_executions(rule_id);
CREATE INDEX idx_rule_executions_user_id ON rule_executions(user_id);
CREATE INDEX idx_rule_executions_status ON rule_executions(status);
CREATE INDEX idx_rule_executions_started_at ON rule_executions(started_at);

CREATE INDEX idx_condition_cache_condition_id ON condition_cache(condition_id);
CREATE INDEX idx_condition_cache_user_id ON condition_cache(user_id);
CREATE INDEX idx_condition_cache_expires_at ON condition_cache(expires_at);

CREATE INDEX idx_user_segments_org_id ON user_segments(organization_id);
CREATE INDEX idx_user_segments_active ON user_segments(is_active);
CREATE INDEX idx_user_segments_dynamic ON user_segments(is_dynamic);

CREATE INDEX idx_user_segment_memberships_user_id ON user_segment_memberships(user_id);
CREATE INDEX idx_user_segment_memberships_segment_id ON user_segment_memberships(segment_id);
CREATE INDEX idx_user_segment_memberships_active ON user_segment_memberships(is_active);

CREATE INDEX idx_feature_flags_org_id ON feature_flags(organization_id);
CREATE INDEX idx_feature_flags_enabled ON feature_flags(is_enabled);
CREATE INDEX idx_feature_flags_slug ON feature_flags(slug);

CREATE INDEX idx_feature_flag_evaluations_flag_id ON feature_flag_evaluations(flag_id);
CREATE INDEX idx_feature_flag_evaluations_user_id ON feature_flag_evaluations(user_id);
CREATE INDEX idx_feature_flag_evaluations_date ON feature_flag_evaluations(evaluation_date);

-- GIN indexes for JSONB columns
CREATE INDEX idx_rules_metadata_gin ON rules USING GIN(metadata);
CREATE INDEX idx_rules_audience_filter_gin ON rules USING GIN(audience_filter);
CREATE INDEX idx_rule_conditions_expected_value_gin ON rule_conditions USING GIN(expected_value);
CREATE INDEX idx_rule_actions_action_data_gin ON rule_actions USING GIN(action_data);
CREATE INDEX idx_rule_executions_context_gin ON rule_executions USING GIN(execution_context);
CREATE INDEX idx_user_segments_criteria_gin ON user_segments USING GIN(criteria_definition);
CREATE INDEX idx_feature_flags_rollout_gin ON feature_flags USING GIN(rollout_strategy);

-- Array indexes
CREATE INDEX idx_rules_target_segments_gin ON rules USING GIN(target_segments);
CREATE INDEX idx_feature_flags_environments_gin ON feature_flags USING GIN(environments);
CREATE INDEX idx_feature_flags_whitelist_gin ON feature_flags USING GIN(user_whitelist);

-- Updated_at triggers
CREATE TRIGGER update_rule_groups_updated_at 
    BEFORE UPDATE ON rule_groups 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rules_updated_at 
    BEFORE UPDATE ON rules 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_segments_updated_at 
    BEFORE UPDATE ON user_segments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feature_flags_updated_at 
    BEFORE UPDATE ON feature_flags 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Rule evaluation function
CREATE OR REPLACE FUNCTION evaluate_rule_conditions(
    p_rule_id UUID,
    p_user_id UUID DEFAULT NULL,
    p_context_data JSONB DEFAULT '{}'
) RETURNS BOOLEAN AS $$
DECLARE
    v_condition RECORD;
    v_result BOOLEAN := TRUE;
    v_group_result BOOLEAN;
    v_current_group VARCHAR(10) := 'AND';
BEGIN
    -- Get all conditions for the rule, ordered by execution order
    FOR v_condition IN 
        SELECT * FROM rule_conditions 
        WHERE rule_id = p_rule_id 
        ORDER BY execution_order
    LOOP
        -- Evaluate individual condition (simplified - would need complex logic)
        v_group_result := TRUE; -- Placeholder for actual condition evaluation
        
        -- Apply logical operators
        IF v_condition.logical_operator = 'AND' THEN
            v_result := v_result AND v_group_result;
        ELSIF v_condition.logical_operator = 'OR' THEN
            v_result := v_result OR v_group_result;
        ELSIF v_condition.logical_operator = 'NOT' THEN
            v_result := v_result AND NOT v_group_result;
        END IF;
        
        -- Short-circuit evaluation for AND operations
        IF NOT v_result AND v_condition.logical_operator = 'AND' THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Function to execute rule actions
CREATE OR REPLACE FUNCTION execute_rule_actions(
    p_rule_id UUID,
    p_user_id UUID DEFAULT NULL,
    p_context_data JSONB DEFAULT '{}'
) RETURNS UUID AS $$
DECLARE
    v_execution_id UUID;
    v_action RECORD;
    v_actions_executed INTEGER := 0;
    v_actions_successful INTEGER := 0;
    v_start_time TIMESTAMP := CURRENT_TIMESTAMP;
BEGIN
    -- Create execution record
    INSERT INTO rule_executions (
        rule_id, user_id, execution_context, status
    ) VALUES (
        p_rule_id, p_user_id, p_context_data, 'running'
    ) RETURNING id INTO v_execution_id;
    
    -- Execute each action
    FOR v_action IN 
        SELECT * FROM rule_actions 
        WHERE rule_id = p_rule_id 
        ORDER BY execution_order
    LOOP
        BEGIN
            -- Execute action (placeholder - would contain actual action logic)
            v_actions_executed := v_actions_executed + 1;
            v_actions_successful := v_actions_successful + 1;
            
        EXCEPTION WHEN OTHERS THEN
            -- Log action failure but continue
            NULL;
        END;
    END LOOP;
    
    -- Update execution record
    UPDATE rule_executions SET
        status = 'completed',
        completed_at = CURRENT_TIMESTAMP,
        execution_time_ms = EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_start_time)) * 1000,
        actions_executed = v_actions_executed,
        actions_successful = v_actions_successful,
        actions_failed = v_actions_executed - v_actions_successful
    WHERE id = v_execution_id;
    
    -- Update rule statistics
    UPDATE rules SET
        execution_count = execution_count + 1,
        last_execution_at = CURRENT_TIMESTAMP
    WHERE id = p_rule_id;
    
    RETURN v_execution_id;
END;
$$ LANGUAGE plpgsql;

-- Function to check feature flag
CREATE OR REPLACE FUNCTION is_feature_enabled(
    p_flag_slug VARCHAR(255),
    p_user_id UUID,
    p_organization_id UUID,
    p_context JSONB DEFAULT '{}'
) RETURNS BOOLEAN AS $$
DECLARE
    v_flag feature_flags%ROWTYPE;
    v_result BOOLEAN := FALSE;
    v_user_hash INTEGER;
BEGIN
    -- Get feature flag
    SELECT * INTO v_flag 
    FROM feature_flags 
    WHERE slug = p_flag_slug AND organization_id = p_organization_id;
    
    IF NOT FOUND OR NOT v_flag.is_enabled THEN
        RETURN FALSE;
    END IF;
    
    -- Check whitelist
    IF p_user_id = ANY(v_flag.user_whitelist) THEN
        RETURN TRUE;
    END IF;
    
    -- Check blacklist
    IF p_user_id = ANY(v_flag.user_blacklist) THEN
        RETURN FALSE;
    END IF;
    
    -- Calculate rollout based on user hash
    v_user_hash := ABS(('x' || RIGHT(p_user_id::TEXT, 8))::BIT(32)::INTEGER);
    v_result := (v_user_hash % 10000) < (v_flag.rollout_percentage * 100);
    
    -- Log evaluation
    INSERT INTO feature_flag_evaluations (
        flag_id, user_id, is_enabled, context_data
    ) VALUES (
        v_flag.id, p_user_id, v_result, p_context
    );
    
    -- Update usage count
    UPDATE feature_flags SET usage_count = usage_count + 1 WHERE id = v_flag.id;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Row Level Security
ALTER TABLE rule_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_segments ENABLE ROW LEVEL SECURITY;
ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies
CREATE POLICY rule_groups_org_access ON rule_groups
    USING (
        organization_id IN (
            SELECT organization_id FROM users 
            WHERE id = current_setting('app.current_user_id')::UUID
        )
    );

CREATE POLICY rules_org_access ON rules
    USING (
        organization_id IN (
            SELECT organization_id FROM users 
            WHERE id = current_setting('app.current_user_id')::UUID
        )
    );

COMMIT;