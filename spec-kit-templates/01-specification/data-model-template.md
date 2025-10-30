# Data Model Template

This document defines the data models, entities, and relationships for the project.

---

## 📊 Database Schema Overview

### Entity Relationship Diagram
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      Users      │────│   UserProfiles  │    │      Roles      │
│                 │    │                 │    │                 │
│ - id (PK)       │    │ - user_id (FK)  │    │ - id (PK)       │
│ - email         │    │ - first_name    │    │ - name          │
│ - password_hash │    │ - last_name     │    │ - permissions   │
│ - role_id (FK)  │    │ - avatar_url    │    │ - created_at    │
│ - created_at    │    │ - bio           │    │ - updated_at    │
│ - updated_at    │    │ - created_at    │    └─────────────────┘
│ - deleted_at    │    │ - updated_at    │           │
└─────────────────┘    └─────────────────┘           │
         │                       │                   │
         └───────────────────────┼───────────────────┘
                                 │
         ┌─────────────────┐     │     ┌─────────────────┐
         │    Projects     │─────┼─────│  ProjectMembers │
         │                 │     │     │                 │
         │ - id (PK)       │     │     │ - project_id(FK)│
         │ - name          │     │     │ - user_id (FK)  │
         │ - description   │     │     │ - role          │
         │ - owner_id (FK) │     │     │ - joined_at     │
         │ - status        │     │     └─────────────────┘
         │ - created_at    │     │
         │ - updated_at    │     │
         └─────────────────┘     │
                  │              │
                  │              │
         ┌─────────────────┐     │
         │      Tasks      │─────┘
         │                 │
         │ - id (PK)       │
         │ - project_id(FK)│
         │ - title         │
         │ - description   │
         │ - assignee_id(FK)│
         │ - status        │
         │ - priority      │
         │ - due_date      │
         │ - created_at    │
         │ - updated_at    │
         └─────────────────┘
```

---

## 🏗️ Core Entities

### Users
Primary user entity for authentication and identification.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id UUID REFERENCES roles(id),
    email_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP,
    last_login_at TIMESTAMP,
    login_count INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NULL;
```

**Attributes:**
- `id`: Unique identifier (UUID)
- `email`: User's email address (unique)
- `password_hash`: Hashed password
- `role_id`: Reference to user role
- `email_verified`: Email verification status
- `status`: Account status (active, inactive, suspended)
- `created_at`, `updated_at`, `deleted_at`: Audit timestamps

### UserProfiles
Extended user information and preferences.

```sql
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    display_name VARCHAR(100),
    avatar_url VARCHAR(500),
    bio TEXT,
    phone VARCHAR(20),
    timezone VARCHAR(50) DEFAULT 'UTC',
    language VARCHAR(10) DEFAULT 'en',
    date_format VARCHAR(20) DEFAULT 'YYYY-MM-DD',
    theme_preference VARCHAR(20) DEFAULT 'light' CHECK (theme_preference IN ('light', 'dark', 'auto')),
    notification_preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_user_profiles_display_name ON user_profiles(display_name);
CREATE INDEX idx_user_profiles_timezone ON user_profiles(timezone);
```

**Attributes:**
- `user_id`: Reference to users table
- `first_name`, `last_name`: User's name
- `display_name`: Public display name
- `avatar_url`: Profile picture URL
- `bio`: User biography
- `timezone`, `language`: Localization preferences
- `notification_preferences`: JSON object with notification settings

### Roles
Role-based access control system.

```sql
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '[]',
    is_system_role BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Default roles
INSERT INTO roles (name, display_name, description, permissions, is_system_role) VALUES
('admin', 'Administrator', 'Full system access', '["*"]', TRUE),
('manager', 'Manager', 'Project and team management', '["projects.*", "users.read", "reports.*"]', TRUE),
('user', 'User', 'Standard user access', '["projects.read", "tasks.*", "profile.*"]', TRUE),
('viewer', 'Viewer', 'Read-only access', '["projects.read", "tasks.read", "profile.read"]', TRUE);
```

**Attributes:**
- `name`: Unique role identifier
- `display_name`: Human-readable role name
- `permissions`: JSON array of permission strings
- `is_system_role`: Whether role is system-defined

---

## 📋 Business Entities

### Projects
Main project/workspace entity.

```sql
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL,
    description TEXT,
    owner_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'archived', 'deleted')),
    visibility VARCHAR(20) DEFAULT 'private' CHECK (visibility IN ('public', 'private', 'internal')),
    settings JSONB DEFAULT '{}',
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_projects_owner_id ON projects(owner_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_slug ON projects(slug);
CREATE INDEX idx_projects_deleted_at ON projects(deleted_at) WHERE deleted_at IS NULL;
```

**Attributes:**
- `name`: Project name
- `slug`: URL-friendly identifier
- `owner_id`: Project owner reference
- `status`: Project status
- `visibility`: Access level
- `settings`: JSON configuration object
- `start_date`, `end_date`: Project timeline
- `budget`: Project budget

### ProjectMembers
Many-to-many relationship between users and projects.

```sql
CREATE TABLE project_members (
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member', 'viewer')),
    permissions JSONB DEFAULT '[]',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    invited_by UUID REFERENCES users(id),
    invitation_accepted_at TIMESTAMP,
    
    PRIMARY KEY (project_id, user_id)
);

-- Indexes
CREATE INDEX idx_project_members_user_id ON project_members(user_id);
CREATE INDEX idx_project_members_role ON project_members(role);
```

**Attributes:**
- `project_id`, `user_id`: Composite primary key
- `role`: Project-specific role
- `permissions`: Custom permissions for this project
- `joined_at`: When user joined project
- `invited_by`: Who invited the user

### Tasks
Individual work items within projects.

```sql
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    task_number VARCHAR(20), -- T001, T002, etc.
    assignee_id UUID REFERENCES users(id),
    reporter_id UUID REFERENCES users(id),
    parent_task_id UUID REFERENCES tasks(id),
    epic_id UUID REFERENCES epics(id),
    milestone_id UUID REFERENCES milestones(id),
    status VARCHAR(50) DEFAULT 'todo' CHECK (status IN ('todo', 'in_progress', 'review', 'done', 'blocked')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('critical', 'high', 'medium', 'low')),
    story_points INTEGER CHECK (story_points > 0),
    tags TEXT[], -- Array of tags
    due_date TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    estimated_hours DECIMAL(5, 2),
    logged_hours DECIMAL(5, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_assignee_id ON tasks(assignee_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_epic_id ON tasks(epic_id);
CREATE INDEX idx_tasks_task_number ON tasks(task_number);
CREATE INDEX idx_tasks_deleted_at ON tasks(deleted_at) WHERE deleted_at IS NULL;
```

**Attributes:**
- `task_number`: Human-readable task identifier
- `assignee_id`: Who is working on the task
- `reporter_id`: Who created the task
- `parent_task_id`: For subtasks
- `epic_id`, `milestone_id`: Organizational grouping
- `status`: Current task state
- `priority`: Importance level
- `story_points`: Effort estimation
- `tags`: Flexible categorization

---

## 🏷️ Organizational Entities

### Epics
Large feature groups that contain multiple tasks.

```sql
CREATE TABLE epics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    epic_key VARCHAR(50), -- EPIC-001, etc.
    owner_id UUID REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'planning' CHECK (status IN ('planning', 'in_progress', 'done', 'cancelled')),
    color VARCHAR(7), -- Hex color code
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_epics_project_id ON epics(project_id);
CREATE INDEX idx_epics_status ON epics(status);
CREATE INDEX idx_epics_epic_key ON epics(epic_key);
```

### Milestones
Time-boxed goals with specific deliverables.

```sql
CREATE TABLE milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    milestone_number INTEGER,
    status VARCHAR(50) DEFAULT 'planning' CHECK (status IN ('planning', 'active', 'completed', 'cancelled')),
    start_date DATE,
    due_date DATE,
    completion_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_milestones_project_id ON milestones(project_id);
CREATE INDEX idx_milestones_status ON milestones(status);
CREATE INDEX idx_milestones_due_date ON milestones(due_date);
```

---

## 🔗 Relationship Entities

### TaskDependencies
Define dependencies between tasks.

```sql
CREATE TABLE task_dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    depends_on_task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    dependency_type VARCHAR(20) DEFAULT 'blocks' CHECK (dependency_type IN ('blocks', 'related')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(task_id, depends_on_task_id),
    CHECK (task_id != depends_on_task_id) -- Prevent self-dependency
);

-- Indexes
CREATE INDEX idx_task_dependencies_task_id ON task_dependencies(task_id);
CREATE INDEX idx_task_dependencies_depends_on ON task_dependencies(depends_on_task_id);
```

### Comments
Comments on tasks, projects, and other entities.

```sql
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL CHECK (entity_type IN ('task', 'project', 'epic')),
    entity_id UUID NOT NULL,
    author_id UUID NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    parent_comment_id UUID REFERENCES comments(id), -- For threaded comments
    is_internal BOOLEAN DEFAULT FALSE, -- Internal team comments
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Indexes
CREATE INDEX idx_comments_entity ON comments(entity_type, entity_id);
CREATE INDEX idx_comments_author_id ON comments(author_id);
CREATE INDEX idx_comments_parent ON comments(parent_comment_id);
CREATE INDEX idx_comments_deleted_at ON comments(deleted_at) WHERE deleted_at IS NULL;
```

---

## 📊 Activity & Audit Entities

### ActivityLogs
Track all system activities for audit and history.

```sql
CREATE TABLE activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL, -- 'created', 'updated', 'deleted', etc.
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    changes JSONB, -- Store what changed
    metadata JSONB DEFAULT '{}', -- Additional context
    ip_address INET,
    user_agent TEXT,
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_entity ON activity_logs(entity_type, entity_id);
CREATE INDEX idx_activity_logs_action ON activity_logs(action);
CREATE INDEX idx_activity_logs_occurred_at ON activity_logs(occurred_at);
```

### Sessions
User session management.

```sql
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_token_hash ON sessions(token_hash);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);

-- Cleanup expired sessions
CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS void AS $$
BEGIN
    DELETE FROM sessions WHERE expires_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;
```

---

## 📁 File & Media Entities

### Attachments
File attachments for various entities.

```sql
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100),
    file_size BIGINT, -- Size in bytes
    storage_path VARCHAR(500),
    storage_provider VARCHAR(50) DEFAULT 'local', -- 'local', 's3', 'gcs', etc.
    uploaded_by UUID NOT NULL REFERENCES users(id),
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_attachments_entity ON attachments(entity_type, entity_id);
CREATE INDEX idx_attachments_uploaded_by ON attachments(uploaded_by);
CREATE INDEX idx_attachments_storage_provider ON attachments(storage_provider);
```

---

## 🔧 Configuration & Settings

### SystemSettings
Global system configuration.

```sql
CREATE TABLE system_settings (
    key VARCHAR(100) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE, -- Whether setting is visible to non-admins
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Default settings
INSERT INTO system_settings (key, value, description, is_public) VALUES
('app_name', '"My Application"', 'Application name', TRUE),
('app_version', '"1.0.0"', 'Application version', TRUE),
('maintenance_mode', 'false', 'Maintenance mode status', FALSE),
('max_file_size', '10485760', 'Maximum file upload size in bytes', FALSE),
('session_timeout', '3600', 'Session timeout in seconds', FALSE);
```

---

## 📈 Reporting & Analytics Entities

### Reports
Saved report definitions.

```sql
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    report_type VARCHAR(50) NOT NULL, -- 'burndown', 'velocity', 'custom'
    configuration JSONB NOT NULL, -- Report parameters and filters
    created_by UUID NOT NULL REFERENCES users(id),
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_reports_created_by ON reports(created_by);
CREATE INDEX idx_reports_type ON reports(report_type);
```

---

## 🗃️ Data Validation Rules

### Database Constraints

```sql
-- Ensure task numbers are unique within a project
CREATE UNIQUE INDEX idx_unique_task_number_per_project 
ON tasks(project_id, task_number) 
WHERE deleted_at IS NULL;

-- Ensure epic keys are unique within a project
CREATE UNIQUE INDEX idx_unique_epic_key_per_project 
ON epics(project_id, epic_key);

-- Ensure milestone numbers are unique within a project
CREATE UNIQUE INDEX idx_unique_milestone_number_per_project 
ON milestones(project_id, milestone_number);

-- Prevent circular task dependencies
CREATE OR REPLACE FUNCTION check_circular_dependency()
RETURNS TRIGGER AS $$
BEGIN
    -- Simplified check - in practice, you'd use a recursive CTE
    IF EXISTS (
        SELECT 1 FROM task_dependencies 
        WHERE task_id = NEW.depends_on_task_id 
        AND depends_on_task_id = NEW.task_id
    ) THEN
        RAISE EXCEPTION 'Circular dependency detected';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_circular_dependencies
    BEFORE INSERT OR UPDATE ON task_dependencies
    FOR EACH ROW EXECUTE FUNCTION check_circular_dependency();
```

---

## 📋 Sample Data

### Default Roles and Permissions

```sql
-- Permission structure examples
UPDATE roles SET permissions = '[
    "users.create", "users.read", "users.update", "users.delete",
    "projects.create", "projects.read", "projects.update", "projects.delete",
    "tasks.create", "tasks.read", "tasks.update", "tasks.delete",
    "reports.create", "reports.read", "reports.update", "reports.delete",
    "settings.read", "settings.update"
]' WHERE name = 'admin';

UPDATE roles SET permissions = '[
    "users.read",
    "projects.create", "projects.read", "projects.update",
    "tasks.create", "tasks.read", "tasks.update",
    "reports.create", "reports.read", "reports.update"
]' WHERE name = 'manager';

UPDATE roles SET permissions = '[
    "projects.read",
    "tasks.create", "tasks.read", "tasks.update",
    "reports.read"
]' WHERE name = 'user';
```

---

## 🔄 Migration Strategy

### Version Control
- Use sequential migration files: `001_initial_schema.sql`, `002_add_tags.sql`
- Include rollback scripts for each migration
- Test migrations on copy of production data

### Data Migration
- Plan for data transformation during schema changes
- Backup before migrations
- Use transactions for atomic changes

---

*This data model provides a comprehensive foundation for a project management system with user management, task tracking, and organizational features.*