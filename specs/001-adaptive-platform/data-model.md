# Data Model: KAIZEN Adaptive Platform Core

## Core Entities (11 total)

### 1. UserProfile
Primary entity representing a platform user with their psychological state and preferences.

**Fields:**
- `id`: UUID - Unique identifier
- `email`: String - User email (unique)
- `username`: String - Display name
- `pcm_stage`: Enum - Current PCM stage (Awareness|Attraction|Attachment|Allegiance)
- `expertise_level`: Enum - Expertise classification (Curious|Casual|Enthusiast|Expert)
- `created_at`: Timestamp - Account creation date
- `updated_at`: Timestamp - Last profile update
- `preferences`: JSON - User preferences and settings
- `octalysis_scores`: JSON - Core drive scores (CD2-CD5)
- `device_preferences`: JSON - Preferred settings per device type
- `privacy_settings`: JSON - Data collection and sharing preferences

**Relationships:**
- Has many ContextSnapshots
- Has many MasteryTracks
- Has one AvatarProfile

### 2. ContextSnapshot
Real-time representation of user's current situation and intent.

**Fields:**
- `id`: UUID - Unique identifier
- `user_id`: UUID - Reference to UserProfile
- `device_type`: Enum - Device category (Web|Mobile|TV)
- `device_id`: String - Unique device identifier
- `location`: String - Geographic location (country/region)
- `timestamp`: Timestamp - Context capture time
- `session_id`: UUID - Current session identifier
- `active_content_id`: UUID - Currently viewing content
- `time_constraint`: Enum - Time availability (Limited|Normal|Extended)
- `event_context`: String - Special event if applicable
- `inferred_intent`: String - ML-inferred user intent
- `network_quality`: Enum - Connection quality (Poor|Fair|Good|Excellent)

**Relationships:**
- Belongs to UserProfile
- Has one UIConfiguration

### 3. UIConfiguration
Dynamic interface layout with component selections and arrangements.

**Fields:**
- `id`: UUID - Unique identifier
- `context_snapshot_id`: UUID - Reference to ContextSnapshot
- `configuration`: JSON - Complete UI layout specification
- `sections`: Array<Section> - Ordered page sections
- `frame_config`: JSON - Persistent navigation configuration
- `canvas_config`: JSON - Dynamic content area configuration
- `density`: Enum - UI density (Comfortable|Compact)
- `metadata_verbosity`: Enum - Information level (Minimal|Standard|Detailed)
- `theme`: String - Active visual theme
- `generated_at`: Timestamp - Configuration generation time
- `assembly_time_ms`: Integer - Generation duration

**Relationships:**
- Belongs to ContextSnapshot
- Has many ComponentInstances

### 4. KDSComponent
Modular UI element from the Kaizen Design System.

**Fields:**
- `id`: UUID - Unique identifier
- `name`: String - Component name
- `atomic_type`: Enum - Component level (Atom|Molecule|Organism)
- `version`: String - Component version (semver)
- `properties`: JSON - Dynamic property definitions
- `constraints`: JSON - Layout and behavior constraints
- `accessibility`: JSON - WCAG compliance metadata
- `presentations`: Array<Presentation> - Available presentation modes
- `created_at`: Timestamp - Component creation date
- `updated_at`: Timestamp - Last modification date

**Relationships:**
- Has many ComponentInstances

### 5. ComponentInstance
Instantiation of a KDS component with specific configuration.

**Fields:**
- `id`: UUID - Unique identifier
- `component_id`: UUID - Reference to KDSComponent
- `ui_config_id`: UUID - Reference to UIConfiguration
- `section_index`: Integer - Vertical position in layout
- `position_index`: Integer - Horizontal position within section
- `presentation_type`: Enum - Selected presentation mode
- `importance_score`: Float - Computed importance (0-1)
- `properties`: JSON - Applied property values
- `content_ids`: Array<UUID> - Associated content items
- `render_time_ms`: Integer - Component render duration

**Relationships:**
- Belongs to KDSComponent
- Belongs to UIConfiguration
- Has many ContentItems

### 6. AdaptationRule
IF/THEN logic for context-aware UI adaptations.

**Fields:**
- `id`: UUID - Unique identifier
- `rule_id`: String - Human-readable rule identifier
- `name`: String - Rule description
- `priority`: Integer - Execution priority (0-100)
- `conditions`: JSON - IF conditions (context/state)
- `directives`: JSON - THEN UI directives
- `rule_type`: Enum - Rule category (Rerank|Morph|Configure|Filter)
- `is_active`: Boolean - Rule enabled status
- `version`: Integer - Rule version number
- `created_by`: UUID - Designer who created rule
- `created_at`: Timestamp - Rule creation date

**Relationships:**
- Belongs to RuleSetVersion

### 7. RuleSetVersion
Collection of active adaptation rules with governance.

**Fields:**
- `id`: UUID - Unique identifier
- `version`: String - Version number (semver)
- `status`: Enum - Version status (Draft|Testing|Active|Archived)
- `rules`: Array<UUID> - Rule references in this version
- `approval_status`: Enum - Governance state (Pending|Approved|Rejected)
- `approved_by`: UUID - Approver user ID
- `deployed_at`: Timestamp - Production deployment time
- `rollback_to`: UUID - Previous version reference

**Relationships:**
- Has many AdaptationRules

### 8. ContentItem
Anime content with metadata and connections.

**Fields:**
- `id`: UUID - Unique identifier
- `title`: String - Content title
- `type`: Enum - Content type (Episode|Movie|Clip|Trailer)
- `series_id`: UUID - Parent series reference
- `metadata`: JSON - Detailed content information
- `emotional_tags`: Array<String> - Mood classifications
- `pcm_appropriateness`: JSON - Stage suitability scores
- `merchandise_links`: Array<UUID> - Related products
- `game_connections`: Array<UUID> - Related games
- `genre_tags`: Array<String> - Genre classifications
- `release_date`: Timestamp - Original air date
- `importance_base`: Float - Base importance score

**Relationships:**
- Belongs to many ComponentInstances

### 9. DiscoveryQuery
Natural language or mood-based search request.

**Fields:**
- `id`: UUID - Unique identifier
- `user_id`: UUID - Reference to UserProfile
- `query_text`: String - Original query
- `query_type`: Enum - Query category (Natural|Mood|Theme|Specific)
- `intent_classification`: String - ML-classified intent
- `emotional_context`: JSON - Extracted emotional signals
- `results_returned`: Integer - Number of results
- `results_clicked`: Array<UUID> - Clicked result IDs
- `timestamp`: Timestamp - Query time
- `response_time_ms`: Integer - Processing duration

**Relationships:**
- Belongs to UserProfile
- Has many ContentItems (results)

### 10. MasteryTrack
Personalized progression and achievement system.

**Fields:**
- `id`: UUID - Unique identifier
- `user_id`: UUID - Reference to UserProfile
- `track_name`: String - Track title (e.g., "Isekai Explorer")
- `track_type`: Enum - Track category (Genre|Creator|Era|Theme)
- `current_level`: Integer - Current progression level
- `total_levels`: Integer - Maximum level
- `progress_points`: Integer - Points toward next level
- `achievements`: Array<Achievement> - Unlocked achievements
- `unlocked_features`: Array<String> - Features enabled by progress
- `milestones`: JSON - Key progression milestones
- `started_at`: Timestamp - Track start date

**Relationships:**
- Belongs to UserProfile

### 11. LayoutPerformance
Metrics for layout effectiveness and user engagement.

**Fields:**
- `id`: UUID - Unique identifier
- `ui_config_id`: UUID - Reference to UIConfiguration
- `user_id`: UUID - Reference to UserProfile
- `session_id`: UUID - Session identifier
- `layout_hash`: String - Layout configuration hash
- `engagement_score`: Float - Computed engagement (0-1)
- `click_through_rate`: Float - CTR percentage
- `dwell_time_ms`: Integer - Time spent on page
- `scroll_depth`: Float - Maximum scroll percentage
- `interactions`: JSON - User interaction events
- `timestamp`: Timestamp - Measurement time

**Relationships:**
- Belongs to UIConfiguration
- Belongs to UserProfile

## Relationships Diagram

```
UserProfile
    ├── ContextSnapshot
    │   └── UIConfiguration
    │       └── ComponentInstance
    │           ├── KDSComponent
    │           └── ContentItem
    ├── MasteryTrack
    └── DiscoveryQuery

AdaptationRule
    └── RuleSetVersion

LayoutPerformance
    ├── UIConfiguration
    └── UserProfile
```

## Data Constraints

### Performance Requirements
- User profile queries: <50ms
- Context evaluation: <100ms
- Rule execution: <50ms per rule
- UI assembly: <500ms total
- Content queries: <200ms

### Storage Requirements
- User profiles: ~10KB per user
- Context snapshots: ~2KB per snapshot
- UI configurations: ~50KB per config
- Rules: ~1KB per rule
- Content metadata: ~5KB per item

### Retention Policies
- User profiles: Indefinite until deletion request
- Context snapshots: 90 days
- UI configurations: 30 days
- Discovery queries: 180 days
- Performance metrics: 1 year

### Privacy Compliance
- PII encryption at rest
- Right to deletion (GDPR Article 17)
- Data portability (GDPR Article 20)
- Consent tracking for minors (COPPA)
- Anonymization after account closure