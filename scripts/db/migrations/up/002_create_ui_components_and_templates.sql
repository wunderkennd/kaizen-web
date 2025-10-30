-- Migration: Create UI components and templates tables
-- Version: 002
-- Description: Create comprehensive UI component system for dynamic interface generation

BEGIN;

-- Custom types for UI components
CREATE TYPE component_type AS ENUM (
    'layout',
    'navigation',
    'form',
    'input',
    'button',
    'display',
    'media',
    'feedback',
    'overlay',
    'data',
    'chart',
    'custom'
);

CREATE TYPE component_status AS ENUM (
    'draft',
    'active',
    'deprecated',
    'archived'
);

CREATE TYPE template_type AS ENUM (
    'page',
    'section',
    'widget',
    'email',
    'notification',
    'report'
);

CREATE TYPE ui_framework AS ENUM (
    'react',
    'vue',
    'angular',
    'svelte',
    'html',
    'native'
);

CREATE TYPE device_type AS ENUM (
    'desktop',
    'tablet',
    'mobile',
    'watch',
    'tv'
);

CREATE TYPE interaction_type AS ENUM (
    'click',
    'hover',
    'focus',
    'scroll',
    'touch',
    'drag',
    'keyboard',
    'voice'
);

-- Component library for reusable UI elements
CREATE TABLE component_library (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    component_type component_type NOT NULL,
    category VARCHAR(100),
    tags TEXT[],
    
    -- Component definition
    schema_definition JSONB NOT NULL, -- Component structure schema
    style_definition JSONB DEFAULT '{}', -- CSS/style properties
    behavior_definition JSONB DEFAULT '{}', -- JavaScript/interaction logic
    
    -- Framework implementations
    implementations JSONB DEFAULT '{}', -- Code for different frameworks
    
    -- Responsive design
    responsive_breakpoints JSONB DEFAULT '{}',
    device_adaptations JSONB DEFAULT '{}',
    
    -- Accessibility
    accessibility_features JSONB DEFAULT '{}',
    aria_attributes JSONB DEFAULT '{}',
    keyboard_navigation JSONB DEFAULT '{}',
    
    -- Versioning and compatibility
    version VARCHAR(50) NOT NULL DEFAULT '1.0.0',
    parent_component_id UUID REFERENCES component_library(id),
    framework_compatibility ui_framework[] DEFAULT ARRAY['react'],
    browser_compatibility JSONB DEFAULT '{}',
    
    -- Usage and performance
    usage_count INTEGER DEFAULT 0,
    performance_metrics JSONB DEFAULT '{}',
    
    -- Documentation
    documentation TEXT,
    examples JSONB DEFAULT '{}',
    
    -- Metadata
    status component_status DEFAULT 'draft',
    is_system_component BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}',
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    UNIQUE(organization_id, slug, version)
);

-- UI Templates for complete interface layouts
CREATE TABLE ui_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    template_type template_type NOT NULL,
    category VARCHAR(100),
    tags TEXT[],
    
    -- Template structure
    layout_structure JSONB NOT NULL, -- Component tree/hierarchy
    component_mapping JSONB DEFAULT '{}', -- Maps to component_library
    data_binding JSONB DEFAULT '{}', -- Data source bindings
    
    -- Styling and theming
    theme_definition JSONB DEFAULT '{}',
    style_overrides JSONB DEFAULT '{}',
    responsive_layout JSONB DEFAULT '{}',
    
    -- Behavior and interactions
    interaction_map JSONB DEFAULT '{}',
    event_handlers JSONB DEFAULT '{}',
    state_management JSONB DEFAULT '{}',
    
    -- Personalization
    personalization_rules JSONB DEFAULT '{}',
    user_customizations JSONB DEFAULT '{}',
    
    -- A/B Testing support
    variations JSONB DEFAULT '{}',
    test_parameters JSONB DEFAULT '{}',
    
    -- Performance
    load_priority INTEGER DEFAULT 0,
    lazy_loading_config JSONB DEFAULT '{}',
    caching_strategy JSONB DEFAULT '{}',
    
    -- SEO and metadata
    seo_metadata JSONB DEFAULT '{}',
    open_graph_data JSONB DEFAULT '{}',
    
    -- Versioning
    version VARCHAR(50) NOT NULL DEFAULT '1.0.0',
    parent_template_id UUID REFERENCES ui_templates(id),
    
    -- Usage tracking
    usage_count INTEGER DEFAULT 0,
    conversion_metrics JSONB DEFAULT '{}',
    
    -- Status and permissions
    status component_status DEFAULT 'draft',
    is_system_template BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT false,
    access_permissions JSONB DEFAULT '{}',
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    UNIQUE(organization_id, slug, version)
);

-- User interface instances (deployed templates)
CREATE TABLE ui_instances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    template_id UUID NOT NULL REFERENCES ui_templates(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    -- Instance configuration
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    configuration JSONB DEFAULT '{}',
    
    -- Runtime data
    current_data JSONB DEFAULT '{}',
    user_state JSONB DEFAULT '{}',
    session_data JSONB DEFAULT '{}',
    
    -- Personalization
    personalized_config JSONB DEFAULT '{}',
    user_preferences JSONB DEFAULT '{}',
    
    -- Context information
    context_data JSONB DEFAULT '{}',
    environment VARCHAR(50) DEFAULT 'production',
    
    -- Performance tracking
    render_time_ms INTEGER,
    last_render_at TIMESTAMP WITH TIME ZONE,
    error_count INTEGER DEFAULT 0,
    last_error_at TIMESTAMP WITH TIME ZONE,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(organization_id, slug)
);

-- Component interactions tracking
CREATE TABLE component_interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id UUID REFERENCES user_sessions(id) ON DELETE SET NULL,
    ui_instance_id UUID REFERENCES ui_instances(id) ON DELETE CASCADE,
    component_id UUID REFERENCES component_library(id) ON DELETE SET NULL,
    
    -- Interaction details
    interaction_type interaction_type NOT NULL,
    component_path VARCHAR(500), -- Path within the UI tree
    element_id VARCHAR(255),
    element_class VARCHAR(255),
    
    -- Context
    page_url TEXT,
    viewport_size JSONB DEFAULT '{}',
    device_info JSONB DEFAULT '{}',
    
    -- Interaction data
    interaction_data JSONB DEFAULT '{}',
    before_state JSONB DEFAULT '{}',
    after_state JSONB DEFAULT '{}',
    
    -- Timing
    interaction_duration_ms INTEGER,
    timestamp_precise TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Location and technical details
    coordinates JSONB DEFAULT '{}', -- x, y coordinates
    ip_address INET,
    user_agent TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- UI performance metrics
CREATE TABLE ui_performance_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ui_instance_id UUID NOT NULL REFERENCES ui_instances(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    -- Timing metrics
    load_time_ms INTEGER NOT NULL,
    first_contentful_paint_ms INTEGER,
    largest_contentful_paint_ms INTEGER,
    first_input_delay_ms INTEGER,
    cumulative_layout_shift DECIMAL(10,6),
    
    -- Resource metrics
    total_size_kb INTEGER,
    javascript_size_kb INTEGER,
    css_size_kb INTEGER,
    image_size_kb INTEGER,
    
    -- Network metrics
    connection_type VARCHAR(50),
    effective_connection_type VARCHAR(50),
    downlink_mbps DECIMAL(10,2),
    rtt_ms INTEGER,
    
    -- Device and browser
    device_type device_type,
    viewport_width INTEGER,
    viewport_height INTEGER,
    pixel_ratio DECIMAL(3,2),
    browser_name VARCHAR(100),
    browser_version VARCHAR(50),
    
    -- Error metrics
    javascript_errors INTEGER DEFAULT 0,
    network_errors INTEGER DEFAULT 0,
    
    -- User experience
    bounce_rate DECIMAL(5,4),
    time_on_page_seconds INTEGER,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Component usage analytics
CREATE TABLE component_usage_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    component_id UUID NOT NULL REFERENCES component_library(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Usage metrics
    usage_date DATE NOT NULL,
    impression_count INTEGER DEFAULT 0,
    interaction_count INTEGER DEFAULT 0,
    unique_users INTEGER DEFAULT 0,
    
    -- Performance metrics
    avg_render_time_ms DECIMAL(10,2),
    error_rate DECIMAL(5,4),
    
    -- Context metrics
    device_breakdown JSONB DEFAULT '{}',
    browser_breakdown JSONB DEFAULT '{}',
    page_breakdown JSONB DEFAULT '{}',
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(component_id, organization_id, usage_date)
);

-- UI themes for consistent styling
CREATE TABLE ui_themes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Theme definition
    color_palette JSONB NOT NULL DEFAULT '{}',
    typography JSONB DEFAULT '{}',
    spacing JSONB DEFAULT '{}',
    borders JSONB DEFAULT '{}',
    shadows JSONB DEFAULT '{}',
    animations JSONB DEFAULT '{}',
    
    -- Component styles
    component_styles JSONB DEFAULT '{}',
    
    -- Responsive breakpoints
    breakpoints JSONB DEFAULT '{}',
    
    -- Dark/light mode support
    mode_variants JSONB DEFAULT '{}',
    
    -- Custom CSS
    custom_css TEXT,
    css_variables JSONB DEFAULT '{}',
    
    -- Status
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    UNIQUE(organization_id, slug)
);

-- Indexes for performance
CREATE INDEX idx_component_library_org_id ON component_library(organization_id);
CREATE INDEX idx_component_library_type ON component_library(component_type);
CREATE INDEX idx_component_library_status ON component_library(status);
CREATE INDEX idx_component_library_slug ON component_library(slug);
CREATE INDEX idx_component_library_tags ON component_library USING GIN(tags);

CREATE INDEX idx_ui_templates_org_id ON ui_templates(organization_id);
CREATE INDEX idx_ui_templates_type ON ui_templates(template_type);
CREATE INDEX idx_ui_templates_status ON ui_templates(status);
CREATE INDEX idx_ui_templates_slug ON ui_templates(slug);

CREATE INDEX idx_ui_instances_org_id ON ui_instances(organization_id);
CREATE INDEX idx_ui_instances_template_id ON ui_instances(template_id);
CREATE INDEX idx_ui_instances_user_id ON ui_instances(user_id);
CREATE INDEX idx_ui_instances_slug ON ui_instances(slug);
CREATE INDEX idx_ui_instances_active ON ui_instances(is_active);

CREATE INDEX idx_component_interactions_user_id ON component_interactions(user_id);
CREATE INDEX idx_component_interactions_instance_id ON component_interactions(ui_instance_id);
CREATE INDEX idx_component_interactions_component_id ON component_interactions(component_id);
CREATE INDEX idx_component_interactions_type ON component_interactions(interaction_type);
CREATE INDEX idx_component_interactions_timestamp ON component_interactions(timestamp_precise);

CREATE INDEX idx_ui_performance_metrics_instance_id ON ui_performance_metrics(ui_instance_id);
CREATE INDEX idx_ui_performance_metrics_user_id ON ui_performance_metrics(user_id);
CREATE INDEX idx_ui_performance_metrics_recorded_at ON ui_performance_metrics(recorded_at);

CREATE INDEX idx_component_usage_analytics_component_id ON component_usage_analytics(component_id);
CREATE INDEX idx_component_usage_analytics_org_id ON component_usage_analytics(organization_id);
CREATE INDEX idx_component_usage_analytics_date ON component_usage_analytics(usage_date);

CREATE INDEX idx_ui_themes_org_id ON ui_themes(organization_id);
CREATE INDEX idx_ui_themes_slug ON ui_themes(slug);
CREATE INDEX idx_ui_themes_default ON ui_themes(is_default);

-- GIN indexes for JSONB columns
CREATE INDEX idx_component_library_schema_gin ON component_library USING GIN(schema_definition);
CREATE INDEX idx_component_library_style_gin ON component_library USING GIN(style_definition);
CREATE INDEX idx_component_library_metadata_gin ON component_library USING GIN(metadata);

CREATE INDEX idx_ui_templates_layout_gin ON ui_templates USING GIN(layout_structure);
CREATE INDEX idx_ui_templates_theme_gin ON ui_templates USING GIN(theme_definition);
CREATE INDEX idx_ui_templates_metadata_gin ON ui_templates USING GIN(metadata);

CREATE INDEX idx_ui_instances_config_gin ON ui_instances USING GIN(configuration);
CREATE INDEX idx_ui_instances_data_gin ON ui_instances USING GIN(current_data);

CREATE INDEX idx_component_interactions_data_gin ON component_interactions USING GIN(interaction_data);
CREATE INDEX idx_ui_performance_metrics_metadata_gin ON ui_performance_metrics USING GIN(metadata);

-- Updated_at triggers
CREATE TRIGGER update_component_library_updated_at 
    BEFORE UPDATE ON component_library 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ui_templates_updated_at 
    BEFORE UPDATE ON ui_templates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ui_instances_updated_at 
    BEFORE UPDATE ON ui_instances 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ui_themes_updated_at 
    BEFORE UPDATE ON ui_themes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to track component usage
CREATE OR REPLACE FUNCTION track_component_usage(
    p_component_id UUID,
    p_organization_id UUID,
    p_interaction_type interaction_type DEFAULT 'click'
) RETURNS VOID AS $$
BEGIN
    -- Update daily usage analytics
    INSERT INTO component_usage_analytics (
        component_id, organization_id, usage_date, impression_count, interaction_count, unique_users
    ) VALUES (
        p_component_id, p_organization_id, CURRENT_DATE, 
        CASE WHEN p_interaction_type = 'impression' THEN 1 ELSE 0 END,
        CASE WHEN p_interaction_type != 'impression' THEN 1 ELSE 0 END,
        1
    )
    ON CONFLICT (component_id, organization_id, usage_date) 
    DO UPDATE SET
        impression_count = component_usage_analytics.impression_count + 
            CASE WHEN p_interaction_type = 'impression' THEN 1 ELSE 0 END,
        interaction_count = component_usage_analytics.interaction_count + 
            CASE WHEN p_interaction_type != 'impression' THEN 1 ELSE 0 END;
            
    -- Update component library usage count
    UPDATE component_library 
    SET usage_count = usage_count + 1 
    WHERE id = p_component_id;
END;
$$ LANGUAGE plpgsql;

-- Function to render UI template with personalization
CREATE OR REPLACE FUNCTION render_ui_template(
    p_template_id UUID,
    p_user_id UUID DEFAULT NULL,
    p_context_data JSONB DEFAULT '{}'
) RETURNS JSONB AS $$
DECLARE
    v_template ui_templates%ROWTYPE;
    v_user_prefs JSONB;
    v_result JSONB;
BEGIN
    -- Get template
    SELECT * INTO v_template FROM ui_templates WHERE id = p_template_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Template not found: %', p_template_id;
    END IF;
    
    -- Get user preferences if user provided
    IF p_user_id IS NOT NULL THEN
        SELECT ui_preferences INTO v_user_prefs 
        FROM users WHERE id = p_user_id;
    ELSE
        v_user_prefs := '{}';
    END IF;
    
    -- Build result with template and personalization
    v_result := jsonb_build_object(
        'template_id', p_template_id,
        'layout_structure', v_template.layout_structure,
        'theme_definition', v_template.theme_definition,
        'user_preferences', v_user_prefs,
        'context_data', p_context_data,
        'render_timestamp', CURRENT_TIMESTAMP
    );
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Row Level Security
ALTER TABLE component_library ENABLE ROW LEVEL SECURITY;
ALTER TABLE ui_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE ui_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE ui_themes ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies (adjust based on your requirements)
CREATE POLICY component_library_org_access ON component_library
    USING (
        organization_id IN (
            SELECT organization_id FROM users 
            WHERE id = current_setting('app.current_user_id')::UUID
        ) OR is_public = true
    );

CREATE POLICY ui_templates_org_access ON ui_templates
    USING (
        organization_id IN (
            SELECT organization_id FROM users 
            WHERE id = current_setting('app.current_user_id')::UUID
        ) OR is_public = true
    );

COMMIT;