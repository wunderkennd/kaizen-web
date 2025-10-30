-- Development Seed Data
-- This file contains sample data for development and testing

BEGIN;

-- Insert sample organizations
INSERT INTO organizations (id, name, slug, domain, billing_plan, max_users, is_active) VALUES
('11111111-1111-1111-1111-111111111111', 'KAIZEN Demo Corp', 'kaizen-demo', 'demo.kaizen.dev', 'enterprise', 1000, true),
('22222222-2222-2222-2222-222222222222', 'TechStart Innovations', 'techstart', 'techstart.example.com', 'pro', 50, true),
('33333333-3333-3333-3333-333333333333', 'Retail Masters Inc', 'retail-masters', 'retailmasters.com', 'basic', 10, true);

-- Insert sample users
INSERT INTO users (
    id, organization_id, email, email_verified, username, first_name, last_name, 
    display_name, status, role, current_pcm_stage, pcm_confidence_score,
    preferences, ui_preferences, notification_preferences,
    terms_accepted_at, privacy_policy_accepted_at, created_at
) VALUES
-- Admin users
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'admin@kaizen.dev', true, 'admin', 'Admin', 'User', 'Admin User', 'active', 'super_admin', 'allegiance', 0.95, 
 '{"timezone": "UTC", "language": "en"}', '{"theme": "dark", "layout": "grid"}', '{"email": true, "push": true, "sms": false}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
 
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'alice@techstart.example.com', true, 'alice_chen', 'Alice', 'Chen', 'Alice Chen', 'active', 'admin', 'attachment', 0.87,
 '{"timezone": "America/Los_Angeles", "language": "en"}', '{"theme": "light", "layout": "list"}', '{"email": true, "push": true, "sms": true}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- Regular users with different PCM stages
('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', 'john.doe@demo.kaizen.dev', true, 'john_doe', 'John', 'Doe', 'John Doe', 'active', 'user', 'awareness', 0.72,
 '{"timezone": "America/New_York", "language": "en"}', '{"theme": "light", "layout": "grid"}', '{"email": true, "push": false, "sms": false}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', 'sarah.wilson@demo.kaizen.dev', true, 'sarah_w', 'Sarah', 'Wilson', 'Sarah Wilson', 'active', 'user', 'attraction', 0.68,
 '{"timezone": "Europe/London", "language": "en"}', '{"theme": "dark", "layout": "list"}', '{"email": true, "push": true, "sms": false}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '11111111-1111-1111-1111-111111111111', 'mike.johnson@demo.kaizen.dev', true, 'mike_j', 'Mike', 'Johnson', 'Mike J', 'active', 'user', 'attachment', 0.91,
 '{"timezone": "America/Chicago", "language": "en"}', '{"theme": "light", "layout": "grid"}', '{"email": true, "push": true, "sms": true}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('ffffffff-ffff-ffff-ffff-ffffffffffff', '33333333-3333-3333-3333-333333333333', 'emma.davis@retailmasters.com', true, 'emma_d', 'Emma', 'Davis', 'Emma Davis', 'active', 'analyst', 'allegiance', 0.88,
 '{"timezone": "Australia/Sydney", "language": "en"}', '{"theme": "dark", "layout": "grid"}', '{"email": true, "push": true, "sms": false}',
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert sample UI themes
INSERT INTO ui_themes (
    id, organization_id, name, slug, description, color_palette, typography, spacing,
    is_default, is_active, created_by
) VALUES
('theme001-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'KAIZEN Default Light', 'kaizen-light', 'Default light theme for KAIZEN platform',
 '{"primary": "#3B82F6", "secondary": "#10B981", "accent": "#F59E0B", "background": "#FFFFFF", "surface": "#F9FAFB", "text": "#111827"}',
 '{"fontFamily": "Inter", "fontSize": {"small": "14px", "medium": "16px", "large": "18px"}}',
 '{"xs": "4px", "sm": "8px", "md": "16px", "lg": "24px", "xl": "32px"}',
 true, true, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('theme002-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'KAIZEN Dark Mode', 'kaizen-dark', 'Dark theme for KAIZEN platform',
 '{"primary": "#60A5FA", "secondary": "#34D399", "accent": "#FBBF24", "background": "#111827", "surface": "#1F2937", "text": "#F9FAFB"}',
 '{"fontFamily": "Inter", "fontSize": {"small": "14px", "medium": "16px", "large": "18px"}}',
 '{"xs": "4px", "sm": "8px", "md": "16px", "lg": "24px", "xl": "32px"}',
 false, true, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert sample component library items
INSERT INTO component_library (
    id, organization_id, name, slug, description, component_type, category,
    schema_definition, style_definition, behavior_definition,
    version, framework_compatibility, status, is_system_component,
    created_by
) VALUES
('comp0001-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Primary Button', 'primary-button', 'Standard primary action button',
 'button', 'actions',
 '{"type": "button", "props": {"text": "string", "variant": "primary|secondary|danger", "size": "sm|md|lg", "disabled": "boolean"}}',
 '{"base": {"padding": "8px 16px", "borderRadius": "6px", "fontWeight": "600"}, "variants": {"primary": {"backgroundColor": "var(--color-primary)", "color": "white"}}}',
 '{"onClick": "function", "onHover": "function"}',
 '1.0.0', ARRAY['react', 'vue'], 'active', true,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('comp0002-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Text Input', 'text-input', 'Standard text input field',
 'input', 'forms',
 '{"type": "input", "props": {"placeholder": "string", "type": "text|email|password", "required": "boolean", "disabled": "boolean"}}',
 '{"base": {"border": "1px solid var(--color-border)", "borderRadius": "4px", "padding": "12px"}}',
 '{"onChange": "function", "onFocus": "function", "onBlur": "function"}',
 '1.0.0', ARRAY['react', 'vue'], 'active', true,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('comp0003-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Dashboard Card', 'dashboard-card', 'Reusable card component for dashboards',
 'display', 'layout',
 '{"type": "card", "props": {"title": "string", "subtitle": "string", "children": "node", "actions": "array"}}',
 '{"base": {"backgroundColor": "var(--color-surface)", "borderRadius": "8px", "padding": "24px", "boxShadow": "0 1px 3px rgba(0,0,0,0.1)"}}',
 '{"onCardClick": "function"}',
 '1.0.0', ARRAY['react'], 'active', false,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert sample UI templates
INSERT INTO ui_templates (
    id, organization_id, name, slug, description, template_type, category,
    layout_structure, component_mapping, theme_definition,
    version, status, is_system_template, created_by
) VALUES
('tmpl0001-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Login Page', 'login-page', 'Standard login page template',
 'page', 'authentication',
 '{"layout": "centered", "sections": [{"id": "header", "component": "app-header"}, {"id": "login-form", "component": "login-form"}, {"id": "footer", "component": "app-footer"}]}',
 '{"login-form": "comp0002-2222-2222-2222-222222222222", "submit-button": "comp0001-1111-1111-1111-111111111111"}',
 '{"extends": "kaizen-light", "overrides": {"background": "#F8FAFC"}}',
 '1.0.0', 'active', true,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('tmpl0002-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Dashboard Overview', 'dashboard-overview', 'Main dashboard template with metrics',
 'page', 'dashboard',
 '{"layout": "grid", "columns": 3, "sections": [{"id": "metrics-row", "span": 3, "components": ["metric-card", "metric-card", "metric-card"]}, {"id": "chart-section", "span": 2, "component": "analytics-chart"}, {"id": "activity-feed", "span": 1, "component": "activity-list"}]}',
 '{"metric-card": "comp0003-3333-3333-3333-333333333333"}',
 '{"extends": "kaizen-light"}',
 '1.0.0', 'active', true,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert sample user segments
INSERT INTO user_segments (
    id, organization_id, name, slug, description, criteria_definition,
    is_dynamic, estimated_size, is_active, created_by
) VALUES
('seg00001-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Power Users', 'power-users', 'Highly engaged users with frequent activity',
 '{"conditions": [{"field": "login_count", "operator": "greater_than", "value": 50}, {"field": "current_pcm_stage", "operator": "in", "value": ["attachment", "allegiance"]}]}',
 true, 25, true,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('seg00002-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'New Users', 'new-users', 'Recently joined users in awareness stage',
 '{"conditions": [{"field": "created_at", "operator": "greater_than", "value": "30 days ago"}, {"field": "current_pcm_stage", "operator": "equals", "value": "awareness"}]}',
 true, 150, true,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('seg00003-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'At Risk Users', 'at-risk-users', 'Users who may churn soon',
 '{"conditions": [{"field": "last_active_at", "operator": "less_than", "value": "14 days ago"}, {"field": "login_count", "operator": "greater_than", "value": 5}]}',
 true, 45, true,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert sample user segment memberships
INSERT INTO user_segment_memberships (user_id, segment_id, confidence_score, calculation_method) VALUES
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'seg00001-1111-1111-1111-111111111111', 0.92, 'rule_based'),
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'seg00001-1111-1111-1111-111111111111', 0.89, 'rule_based'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'seg00002-2222-2222-2222-222222222222', 0.85, 'rule_based'),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'seg00002-2222-2222-2222-222222222222', 0.78, 'rule_based');

-- Insert sample rule groups
INSERT INTO rule_groups (
    id, organization_id, name, slug, description, is_active, execution_order, created_by
) VALUES
('rgrp0001-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Onboarding Rules', 'onboarding-rules', 'Rules for new user onboarding experience', true, 1,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('rgrp0002-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Personalization Rules', 'personalization-rules', 'Content and UI personalization rules', true, 2,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('rgrp0003-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Engagement Rules', 'engagement-rules', 'User engagement and retention rules', true, 3,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert sample rules
INSERT INTO rules (
    id, organization_id, rule_group_id, name, slug, description,
    priority, status, execution_mode, target_segments, created_by
) VALUES
('rule0001-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'rgrp0001-1111-1111-1111-111111111111', 
 'Show Welcome Tutorial', 'show-welcome-tutorial', 'Display interactive tutorial for new users',
 'high', 'active', 'immediate', ARRAY['new-users'],
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('rule0002-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'rgrp0002-2222-2222-2222-222222222222',
 'Personalize Dashboard', 'personalize-dashboard', 'Customize dashboard based on user PCM stage',
 'medium', 'active', 'immediate', ARRAY['power-users'],
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('rule0003-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'rgrp0003-3333-3333-3333-333333333333',
 'Re-engagement Notification', 'reengage-notification', 'Send notification to inactive users',
 'high', 'active', 'scheduled', ARRAY['at-risk-users'],
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert sample rule conditions
INSERT INTO rule_conditions (rule_id, condition_type, field_path, operator, expected_value, execution_order) VALUES
('rule0001-1111-1111-1111-111111111111', 'user_attribute', 'current_pcm_stage', 'equals', '"awareness"', 1),
('rule0001-1111-1111-1111-111111111111', 'user_behavior', 'login_count', 'less_than_or_equal', '3', 2),

('rule0002-2222-2222-2222-222222222222', 'user_attribute', 'current_pcm_stage', 'in', '["attachment", "allegiance"]', 1),
('rule0002-2222-2222-2222-222222222222', 'user_behavior', 'login_count', 'greater_than', '10', 2),

('rule0003-3333-3333-3333-333333333333', 'user_behavior', 'last_active_at', 'less_than', '"14 days ago"', 1),
('rule0003-3333-3333-3333-333333333333', 'user_behavior', 'login_count', 'greater_than', '5', 2);

-- Insert sample rule actions
INSERT INTO rule_actions (rule_id, action_type, target_selector, action_data, execution_order) VALUES
('rule0001-1111-1111-1111-111111111111', 'show_component', '.tutorial-overlay', '{"component": "welcome-tutorial", "modal": true}', 1),
('rule0001-1111-1111-1111-111111111111', 'track_event', null, '{"event": "tutorial_shown", "category": "onboarding"}', 2),

('rule0002-2222-2222-2222-222222222222', 'modify_component', '.dashboard-grid', '{"layout": "advanced", "widgets": ["analytics", "shortcuts", "activity"]}', 1),
('rule0002-2222-2222-2222-222222222222', 'personalize_content', '.recommendation-panel', '{"algorithm": "collaborative_filtering", "count": 5}', 2),

('rule0003-3333-3333-3333-333333333333', 'send_notification', null, '{"type": "email", "template": "re_engagement", "delay": "1 hour"}', 1),
('rule0003-3333-3333-3333-333333333333', 'track_event', null, '{"event": "reengagement_triggered", "category": "retention"}', 2);

-- Insert sample feature flags
INSERT INTO feature_flags (
    id, organization_id, name, slug, description, is_enabled,
    rollout_percentage, target_segments, environments, created_by
) VALUES
('flag0001-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 
 'New Dashboard Design', 'new-dashboard-design', 'Enable new dashboard design for testing',
 true, 25.00, ARRAY['power-users'], ARRAY['staging'],
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('flag0002-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111',
 'Advanced Analytics', 'advanced-analytics', 'Enable advanced analytics features',
 true, 50.00, ARRAY['power-users'], ARRAY['staging', 'production'],
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('flag0003-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111',
 'AI Recommendations', 'ai-recommendations', 'Enable AI-powered content recommendations',
 false, 10.00, ARRAY[], ARRAY['staging'],
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert sample experiments
INSERT INTO experiments (
    id, organization_id, name, slug, description, experiment_type, status,
    traffic_allocation, minimum_sample_size, confidence_level,
    primary_metric, secondary_metrics, start_date, planned_duration_days, created_by
) VALUES
('exp00001-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
 'CTA Button Color Test', 'cta-button-color', 'Test different colors for primary CTA buttons',
 'ab_test', 'running', 50.00, 1000, 95.00,
 'click_through_rate', ARRAY['conversion_rate', 'bounce_rate'],
 CURRENT_TIMESTAMP - INTERVAL '5 days', 14,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('exp00002-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111',
 'Onboarding Flow Optimization', 'onboarding-flow-opt', 'Test different onboarding flow variations',
 'multivariate', 'running', 75.00, 1500, 95.00,
 'completion_rate', ARRAY['time_to_complete', 'user_satisfaction'],
 CURRENT_TIMESTAMP - INTERVAL '3 days', 21,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert experiment variants
INSERT INTO experiment_variants (experiment_id, name, slug, description, allocation_percentage, is_control) VALUES
('exp00001-1111-1111-1111-111111111111', 'Control (Blue)', 'control-blue', 'Original blue CTA buttons', 50.00, true),
('exp00001-1111-1111-1111-111111111111', 'Green Variant', 'green-variant', 'Green CTA buttons', 50.00, false),

('exp00002-2222-2222-2222-222222222222', 'Control Flow', 'control-flow', 'Current onboarding flow', 33.33, true),
('exp00002-2222-2222-2222-222222222222', 'Simplified Flow', 'simplified-flow', 'Simplified 3-step onboarding', 33.33, false),
('exp00002-2222-2222-2222-222222222222', 'Gamified Flow', 'gamified-flow', 'Gamified onboarding with progress bar', 33.34, false);

-- Insert sample events for analytics
INSERT INTO events (
    event_type, event_name, event_category, user_id, organization_id,
    properties, page_url, device_type, browser_name,
    country_code, server_timestamp
) VALUES
('page_view', 'dashboard_view', 'navigation', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111',
 '{"page": "dashboard", "section": "overview"}', '/dashboard', 'desktop', 'Chrome',
 'US', CURRENT_TIMESTAMP - INTERVAL '1 hour'),

('click', 'cta_button_click', 'interaction', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111',
 '{"button_text": "Get Started", "button_color": "blue", "experiment_id": "exp00001-1111-1111-1111-111111111111"}', '/landing', 'mobile', 'Safari',
 'GB', CURRENT_TIMESTAMP - INTERVAL '30 minutes'),

('form_submit', 'signup_complete', 'conversion', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '11111111-1111-1111-1111-111111111111',
 '{"form_type": "signup", "source": "homepage", "experiment_id": "exp00002-2222-2222-2222-222222222222"}', '/signup', 'desktop', 'Firefox',
 'CA', CURRENT_TIMESTAMP - INTERVAL '15 minutes'),

('custom', 'feature_used', 'feature', 'ffffffff-ffff-ffff-ffff-ffffffffffff', '33333333-3333-3333-3333-333333333333',
 '{"feature": "advanced_analytics", "first_time": true}', '/analytics', 'desktop', 'Chrome',
 'AU', CURRENT_TIMESTAMP - INTERVAL '5 minutes');

-- Insert sample funnels
INSERT INTO funnels (
    id, organization_id, name, description, steps, time_window_hours, created_by
) VALUES
('funl0001-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
 'User Signup Funnel', 'Track user journey from landing to signup completion',
 '[{"name": "Landing Page View", "event": "page_view", "criteria": {"page": "landing"}}, {"name": "Signup Form View", "event": "page_view", "criteria": {"page": "signup"}}, {"name": "Form Submission", "event": "form_submit", "criteria": {"form_type": "signup"}}, {"name": "Email Verification", "event": "email_verified", "criteria": {}}]',
 72, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('funl0002-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111',
 'Feature Adoption Funnel', 'Track adoption of new features',
 '[{"name": "Feature Discovery", "event": "page_view", "criteria": {"page": "features"}}, {"name": "Feature Trial", "event": "custom", "criteria": {"event_name": "feature_trial_start"}}, {"name": "Feature Usage", "event": "custom", "criteria": {"event_name": "feature_used"}}]',
 168, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert sample cohorts
INSERT INTO cohorts (
    id, organization_id, name, description, definition_criteria,
    time_period, cohort_date, initial_size, created_by
) VALUES
('coh00001-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
 'January 2024 Signups', 'Users who signed up in January 2024',
 '{"signup_date": {"start": "2024-01-01", "end": "2024-01-31"}}',
 'monthly', '2024-01-01', 234,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),

('coh00002-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111',
 'Week 42 Power Users', 'Power users cohort from week 42',
 '{"signup_date": {"start": "2024-10-14", "end": "2024-10-20"}, "activity_level": "high"}',
 'weekly', '2024-10-14', 45,
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- Insert sample analytics snapshots
INSERT INTO analytics_snapshots (
    organization_id, snapshot_type, snapshot_date, metrics, dimensions
) VALUES
('11111111-1111-1111-1111-111111111111', 'daily', CURRENT_DATE - INTERVAL '1 day',
 '{"total_users": 1250, "active_users": 425, "page_views": 3420, "conversions": 23, "revenue": 1150.50}',
 '{"top_pages": ["/dashboard", "/analytics", "/settings"], "top_events": ["page_view", "click", "form_submit"]}'),

('11111111-1111-1111-1111-111111111111', 'weekly', DATE_TRUNC('week', CURRENT_DATE),
 '{"total_users": 1250, "new_users": 89, "returning_users": 356, "churn_rate": 0.05, "avg_session_duration": 1850}',
 '{"acquisition_channels": {"organic": 45, "paid": 23, "referral": 21}, "user_segments": {"new": 89, "active": 267, "at_risk": 45}}');

COMMIT;