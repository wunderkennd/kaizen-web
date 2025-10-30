-- Migration: Create analytics and experimentation tables
-- Version: 004
-- Description: Create comprehensive analytics and A/B testing infrastructure

BEGIN;

-- Custom types for analytics and experiments
CREATE TYPE event_type AS ENUM (
    'page_view',
    'click',
    'form_submit',
    'purchase',
    'signup',
    'login',
    'logout',
    'search',
    'scroll',
    'time_spent',
    'error',
    'custom'
);

CREATE TYPE experiment_status AS ENUM (
    'draft',
    'running',
    'paused',
    'completed',
    'cancelled',
    'archived'
);

CREATE TYPE experiment_type AS ENUM (
    'ab_test',
    'multivariate',
    'split_url',
    'feature_flag',
    'personalization'
);

CREATE TYPE allocation_method AS ENUM (
    'random',
    'weighted',
    'deterministic',
    'custom'
);

CREATE TYPE statistical_significance AS ENUM (
    'not_significant',
    'approaching_significant',
    'significant',
    'highly_significant'
);

CREATE TYPE conversion_type AS ENUM (
    'primary',
    'secondary',
    'counter'
);

-- Event tracking for comprehensive analytics
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Event identification
    event_type event_type NOT NULL,
    event_name VARCHAR(255) NOT NULL,
    event_category VARCHAR(100),
    
    -- User and session context
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES user_sessions(id) ON DELETE SET NULL,
    anonymous_id UUID, -- For anonymous tracking
    
    -- Organization context
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Event data
    properties JSONB DEFAULT '{}',
    custom_properties JSONB DEFAULT '{}',
    
    -- Page/Screen context
    page_url TEXT,
    page_title VARCHAR(500),
    referrer_url TEXT,
    
    -- Device and technical context
    device_type device_type,
    browser_name VARCHAR(100),
    browser_version VARCHAR(50),
    os_name VARCHAR(100),
    os_version VARCHAR(50),
    viewport_width INTEGER,
    viewport_height INTEGER,
    screen_width INTEGER,
    screen_height INTEGER,
    pixel_ratio DECIMAL(3,2),
    
    -- Location context
    ip_address INET,
    country_code CHAR(2),
    region VARCHAR(100),
    city VARCHAR(100),
    timezone VARCHAR(50),
    
    -- Campaign tracking
    utm_source VARCHAR(255),
    utm_medium VARCHAR(255),
    utm_campaign VARCHAR(255),
    utm_term VARCHAR(255),
    utm_content VARCHAR(255),
    
    -- Performance metrics
    page_load_time_ms INTEGER,
    dom_ready_time_ms INTEGER,
    
    -- Experiment context
    experiment_id UUID, -- Will reference experiments table
    variant_id UUID, -- Will reference experiment_variants table
    
    -- Metadata
    client_timestamp TIMESTAMP WITH TIME ZONE,
    server_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE,
    
    -- Indexing optimization
    event_date DATE GENERATED ALWAYS AS (DATE(server_timestamp)) STORED,
    event_hour TIMESTAMP GENERATED ALWAYS AS (DATE_TRUNC('hour', server_timestamp)) STORED
);

-- Funnel analysis tracking
CREATE TABLE funnels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Funnel definition
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Funnel steps (ordered)
    steps JSONB NOT NULL, -- Array of step definitions
    
    -- Configuration
    time_window_hours INTEGER DEFAULT 24, -- Max time between steps
    is_strict_order BOOLEAN DEFAULT true, -- Must complete steps in order
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    tags TEXT[],
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Funnel user journeys
CREATE TABLE funnel_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    funnel_id UUID NOT NULL REFERENCES funnels(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES user_sessions(id) ON DELETE SET NULL,
    
    -- Journey tracking
    current_step INTEGER DEFAULT 0,
    completed_steps INTEGER[] DEFAULT '{}',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_step_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Conversion tracking
    is_completed BOOLEAN DEFAULT FALSE,
    conversion_value DECIMAL(12,2),
    
    -- Context
    entry_point VARCHAR(255),
    exit_point VARCHAR(255),
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);

-- Experiments table for A/B testing
CREATE TABLE experiments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Experiment identification
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    hypothesis TEXT,
    
    -- Experiment configuration
    experiment_type experiment_type DEFAULT 'ab_test',
    status experiment_status DEFAULT 'draft',
    
    -- Targeting and allocation
    target_audience JSONB DEFAULT '{}', -- Targeting criteria
    allocation_method allocation_method DEFAULT 'random',
    traffic_allocation DECIMAL(5,2) DEFAULT 100.00, -- Percentage of users
    
    -- Timing
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    planned_duration_days INTEGER,
    
    -- Sample size and statistics
    minimum_sample_size INTEGER DEFAULT 1000,
    confidence_level DECIMAL(5,2) DEFAULT 95.00,
    minimum_detectable_effect DECIMAL(5,2) DEFAULT 5.00,
    statistical_power DECIMAL(5,2) DEFAULT 80.00,
    
    -- Goals and metrics
    primary_metric VARCHAR(255),
    secondary_metrics TEXT[],
    success_criteria JSONB DEFAULT '{}',
    
    -- Results tracking
    current_significance statistical_significance DEFAULT 'not_significant',
    winner_variant_id UUID, -- Will reference experiment_variants
    results_summary JSONB DEFAULT '{}',
    
    -- Configuration
    sticky_bucketing BOOLEAN DEFAULT true,
    equal_weighting BOOLEAN DEFAULT true,
    
    -- Quality assurance
    quality_assurance JSONB DEFAULT '{}',
    
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

-- Experiment variants
CREATE TABLE experiment_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experiment_id UUID NOT NULL REFERENCES experiments(id) ON DELETE CASCADE,
    
    -- Variant identification
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Variant configuration
    allocation_percentage DECIMAL(5,2) NOT NULL,
    is_control BOOLEAN DEFAULT false,
    
    -- Implementation details
    changes JSONB DEFAULT '{}', -- What changes in this variant
    feature_flags JSONB DEFAULT '{}',
    
    -- Performance tracking
    user_count INTEGER DEFAULT 0,
    conversion_count INTEGER DEFAULT 0,
    conversion_rate DECIMAL(8,4) DEFAULT 0,
    
    -- Statistical results
    confidence_interval JSONB DEFAULT '{}',
    p_value DECIMAL(10,8),
    statistical_significance statistical_significance DEFAULT 'not_significant',
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(experiment_id, slug)
);

-- User experiment assignments
CREATE TABLE experiment_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experiment_id UUID NOT NULL REFERENCES experiments(id) ON DELETE CASCADE,
    variant_id UUID NOT NULL REFERENCES experiment_variants(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    -- Assignment details
    bucketing_key VARCHAR(255) NOT NULL, -- For consistent bucketing
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    first_exposure_at TIMESTAMP WITH TIME ZONE,
    
    -- Tracking
    exposure_count INTEGER DEFAULT 0,
    conversion_events INTEGER DEFAULT 0,
    has_converted BOOLEAN DEFAULT false,
    converted_at TIMESTAMP WITH TIME ZONE,
    conversion_value DECIMAL(12,2),
    
    -- Context
    assignment_context JSONB DEFAULT '{}',
    
    -- Quality metrics
    is_bot_traffic BOOLEAN DEFAULT false,
    excluded_reason VARCHAR(255),
    
    UNIQUE(experiment_id, user_id),
    UNIQUE(experiment_id, bucketing_key)
);

-- Conversion goals for experiments
CREATE TABLE conversion_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experiment_id UUID NOT NULL REFERENCES experiments(id) ON DELETE CASCADE,
    
    -- Goal definition
    name VARCHAR(255) NOT NULL,
    description TEXT,
    conversion_type conversion_type DEFAULT 'primary',
    
    -- Goal criteria
    event_criteria JSONB NOT NULL, -- What constitutes a conversion
    value_criteria JSONB DEFAULT '{}', -- Revenue/value tracking
    
    -- Timing constraints
    time_window_hours INTEGER DEFAULT 168, -- 7 days default
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Cohort analysis support
CREATE TABLE cohorts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Cohort definition
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Cohort criteria
    definition_criteria JSONB NOT NULL,
    time_period VARCHAR(50) NOT NULL, -- 'daily', 'weekly', 'monthly'
    
    -- Cohort date
    cohort_date DATE NOT NULL,
    
    -- Metrics
    initial_size INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(organization_id, name, cohort_date)
);

-- Cohort user membership
CREATE TABLE cohort_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cohort_id UUID NOT NULL REFERENCES cohorts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Membership details
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    first_activity_at TIMESTAMP WITH TIME ZONE,
    last_activity_at TIMESTAMP WITH TIME ZONE,
    
    -- Retention tracking
    retention_data JSONB DEFAULT '{}', -- Period-based retention
    
    -- Value metrics
    lifetime_value DECIMAL(12,2) DEFAULT 0,
    
    UNIQUE(cohort_id, user_id)
);

-- Real-time analytics dashboard data
CREATE TABLE analytics_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Snapshot metadata
    snapshot_type VARCHAR(100) NOT NULL, -- 'hourly', 'daily', 'weekly', 'monthly'
    snapshot_date TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Metrics data
    metrics JSONB NOT NULL DEFAULT '{}',
    
    -- Dimensions
    dimensions JSONB DEFAULT '{}',
    
    -- Metadata
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(organization_id, snapshot_type, snapshot_date)
);

-- Performance indexes
CREATE INDEX idx_events_user_id ON events(user_id);
CREATE INDEX idx_events_session_id ON events(session_id);
CREATE INDEX idx_events_org_id ON events(organization_id);
CREATE INDEX idx_events_type ON events(event_type);
CREATE INDEX idx_events_name ON events(event_name);
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_events_hour ON events(event_hour);
CREATE INDEX idx_events_timestamp ON events(server_timestamp);
CREATE INDEX idx_events_experiment ON events(experiment_id, variant_id);

CREATE INDEX idx_funnels_org_id ON funnels(organization_id);
CREATE INDEX idx_funnels_active ON funnels(is_active);

CREATE INDEX idx_funnel_sessions_funnel_id ON funnel_sessions(funnel_id);
CREATE INDEX idx_funnel_sessions_user_id ON funnel_sessions(user_id);
CREATE INDEX idx_funnel_sessions_completed ON funnel_sessions(is_completed);
CREATE INDEX idx_funnel_sessions_started_at ON funnel_sessions(started_at);

CREATE INDEX idx_experiments_org_id ON experiments(organization_id);
CREATE INDEX idx_experiments_status ON experiments(status);
CREATE INDEX idx_experiments_slug ON experiments(slug);
CREATE INDEX idx_experiments_dates ON experiments(start_date, end_date);

CREATE INDEX idx_experiment_variants_experiment_id ON experiment_variants(experiment_id);
CREATE INDEX idx_experiment_variants_slug ON experiment_variants(slug);

CREATE INDEX idx_experiment_assignments_experiment_id ON experiment_assignments(experiment_id);
CREATE INDEX idx_experiment_assignments_user_id ON experiment_assignments(user_id);
CREATE INDEX idx_experiment_assignments_variant_id ON experiment_assignments(variant_id);
CREATE INDEX idx_experiment_assignments_bucketing_key ON experiment_assignments(bucketing_key);

CREATE INDEX idx_conversion_goals_experiment_id ON conversion_goals(experiment_id);

CREATE INDEX idx_cohorts_org_id ON cohorts(organization_id);
CREATE INDEX idx_cohorts_date ON cohorts(cohort_date);
CREATE INDEX idx_cohorts_active ON cohorts(is_active);

CREATE INDEX idx_cohort_users_cohort_id ON cohort_users(cohort_id);
CREATE INDEX idx_cohort_users_user_id ON cohort_users(user_id);

CREATE INDEX idx_analytics_snapshots_org_id ON analytics_snapshots(organization_id);
CREATE INDEX idx_analytics_snapshots_type_date ON analytics_snapshots(snapshot_type, snapshot_date);

-- GIN indexes for JSONB columns
CREATE INDEX idx_events_properties_gin ON events USING GIN(properties);
CREATE INDEX idx_events_custom_properties_gin ON events USING GIN(custom_properties);
CREATE INDEX idx_funnels_steps_gin ON funnels USING GIN(steps);
CREATE INDEX idx_experiments_target_audience_gin ON experiments USING GIN(target_audience);
CREATE INDEX idx_experiment_variants_changes_gin ON experiment_variants USING GIN(changes);
CREATE INDEX idx_conversion_goals_criteria_gin ON conversion_goals USING GIN(event_criteria);
CREATE INDEX idx_cohorts_definition_gin ON cohorts USING GIN(definition_criteria);
CREATE INDEX idx_analytics_snapshots_metrics_gin ON analytics_snapshots USING GIN(metrics);

-- Partitioning for events table (by date)
CREATE TABLE events_y2024m01 PARTITION OF events
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
CREATE TABLE events_y2024m02 PARTITION OF events
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
-- Additional partitions would be created dynamically

-- Updated_at triggers
CREATE TRIGGER update_funnels_updated_at 
    BEFORE UPDATE ON funnels 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_experiments_updated_at 
    BEFORE UPDATE ON experiments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_experiment_variants_updated_at 
    BEFORE UPDATE ON experiment_variants 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cohorts_updated_at 
    BEFORE UPDATE ON cohorts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to track experiment exposure
CREATE OR REPLACE FUNCTION track_experiment_exposure(
    p_experiment_id UUID,
    p_user_id UUID,
    p_variant_id UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_assignment_id UUID;
    v_variant_id UUID;
BEGIN
    -- Get or create assignment
    SELECT id, variant_id INTO v_assignment_id, v_variant_id
    FROM experiment_assignments
    WHERE experiment_id = p_experiment_id AND user_id = p_user_id;
    
    IF NOT FOUND THEN
        -- Create new assignment if variant not specified
        IF p_variant_id IS NULL THEN
            -- Simple random assignment (would use more sophisticated logic in production)
            SELECT id INTO v_variant_id
            FROM experiment_variants
            WHERE experiment_id = p_experiment_id
            ORDER BY RANDOM()
            LIMIT 1;
        ELSE
            v_variant_id := p_variant_id;
        END IF;
        
        INSERT INTO experiment_assignments (
            experiment_id, variant_id, user_id, bucketing_key
        ) VALUES (
            p_experiment_id, v_variant_id, p_user_id, p_user_id::TEXT
        ) RETURNING id INTO v_assignment_id;
    END IF;
    
    -- Update exposure tracking
    UPDATE experiment_assignments SET
        exposure_count = exposure_count + 1,
        first_exposure_at = COALESCE(first_exposure_at, CURRENT_TIMESTAMP)
    WHERE id = v_assignment_id;
    
    RETURN v_assignment_id;
END;
$$ LANGUAGE plpgsql;

-- Function to track conversion
CREATE OR REPLACE FUNCTION track_conversion(
    p_experiment_id UUID,
    p_user_id UUID,
    p_conversion_value DECIMAL(12,2) DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_assignment experiment_assignments%ROWTYPE;
BEGIN
    -- Get assignment
    SELECT * INTO v_assignment
    FROM experiment_assignments
    WHERE experiment_id = p_experiment_id AND user_id = p_user_id;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Update conversion if not already converted
    IF NOT v_assignment.has_converted THEN
        UPDATE experiment_assignments SET
            has_converted = TRUE,
            converted_at = CURRENT_TIMESTAMP,
            conversion_events = conversion_events + 1,
            conversion_value = COALESCE(p_conversion_value, conversion_value)
        WHERE id = v_assignment.id;
        
        -- Update variant statistics
        UPDATE experiment_variants SET
            conversion_count = conversion_count + 1,
            conversion_rate = (conversion_count + 1)::DECIMAL / GREATEST(user_count, 1)
        WHERE id = v_assignment.variant_id;
        
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate experiment statistics
CREATE OR REPLACE FUNCTION calculate_experiment_stats(p_experiment_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_stats JSONB;
    v_variant RECORD;
BEGIN
    v_stats := '{"variants": {}}'::JSONB;
    
    FOR v_variant IN
        SELECT 
            ev.*,
            COUNT(ea.id) as total_users,
            COUNT(CASE WHEN ea.has_converted THEN 1 END) as conversions,
            AVG(ea.conversion_value) as avg_conversion_value
        FROM experiment_variants ev
        LEFT JOIN experiment_assignments ea ON ev.id = ea.variant_id
        WHERE ev.experiment_id = p_experiment_id
        GROUP BY ev.id
    LOOP
        v_stats := jsonb_set(
            v_stats,
            ARRAY['variants', v_variant.slug],
            jsonb_build_object(
                'users', v_variant.total_users,
                'conversions', v_variant.conversions,
                'conversion_rate', CASE 
                    WHEN v_variant.total_users > 0 
                    THEN v_variant.conversions::DECIMAL / v_variant.total_users 
                    ELSE 0 
                END,
                'avg_value', COALESCE(v_variant.avg_conversion_value, 0)
            )
        );
    END LOOP;
    
    RETURN v_stats;
END;
$$ LANGUAGE plpgsql;

-- Row Level Security
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE experiments ENABLE ROW LEVEL SECURITY;
ALTER TABLE funnels ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohorts ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies
CREATE POLICY events_org_access ON events
    USING (
        organization_id IN (
            SELECT organization_id FROM users 
            WHERE id = current_setting('app.current_user_id')::UUID
        )
    );

CREATE POLICY experiments_org_access ON experiments
    USING (
        organization_id IN (
            SELECT organization_id FROM users 
            WHERE id = current_setting('app.current_user_id')::UUID
        )
    );

COMMIT;