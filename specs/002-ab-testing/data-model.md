# Data Model: A/B Testing Infrastructure

## Core Entities (4 total)

### 1. Experiment
Test configuration with variants, allocation, targeting, and success metrics.

**Fields:**
- `id`: UUID - Unique experiment identifier
- `name`: String - Human-readable experiment name
- `description`: Text - Experiment purpose and hypothesis
- `type`: Enum - Experiment type (AB|Feature)
- `status`: Enum - Status (Draft|Running|Paused|Completed|Archived)
- `variants`: JSON - Array of variant configurations
  - `name`: String - Variant name (e.g., "control", "treatment")
  - `description`: String - What this variant tests
  - `configuration`: JSON - Specific changes for this variant
- `traffic_allocation`: JSON - Percentage split per variant
- `success_metrics`: JSON - Primary and secondary metrics
  - `primary_metric`: String - Main success metric
  - `secondary_metrics`: Array<String> - Additional metrics
  - `minimum_sample_size`: Integer - Required sample size
- `targeting_rules`: JSON - User segment targeting
  - `include_segments`: Array<String> - Segments to include
  - `exclude_segments`: Array<String> - Segments to exclude
  - `user_attributes`: JSON - Specific attribute filters
- `start_date`: Timestamp - Experiment start time
- `end_date`: Timestamp - Planned end time
- `created_by`: String - Creator user ID
- `created_at`: Timestamp - Creation timestamp
- `updated_at`: Timestamp - Last modification

**Relationships:**
- Has many ExperimentAssignments
- Has many ExperimentResults

**Validation Rules:**
- Traffic allocation must sum to 100%
- At least 2 variants required
- Success metrics must be defined
- End date must be after start date

### 2. ExperimentAssignment
Maps users to experiment variants ensuring consistency.

**Fields:**
- `id`: UUID - Assignment identifier
- `experiment_id`: UUID - Reference to Experiment
- `user_id`: String - User identifier
- `variant`: String - Assigned variant name
- `assignment_reason`: String - Assignment algorithm used
- `assigned_at`: Timestamp - Assignment timestamp
- `sticky`: Boolean - Whether assignment is permanent
- `device_id`: String - Device identifier for cross-device consistency
- `session_id`: UUID - Session when assignment occurred

**Relationships:**
- Belongs to Experiment
- Belongs to UserProfile (from core platform)

**Validation Rules:**
- User can only have one assignment per experiment
- Variant must exist in experiment configuration
- Assignment must be consistent across sessions

### 3. ExperimentResult
Aggregated metrics and statistical analysis per variant.

**Fields:**
- `id`: UUID - Result identifier
- `experiment_id`: UUID - Reference to Experiment
- `variant`: String - Variant name
- `metric_name`: String - Metric being measured
- `sample_size`: Integer - Number of users
- `conversions`: Integer - Number of conversions
- `mean_value`: Float - Average metric value
- `variance`: Float - Statistical variance
- `confidence_interval`: JSON - 95% CI bounds
  - `lower`: Float - Lower bound
  - `upper`: Float - Upper bound
- `p_value`: Float - Statistical significance
- `lift`: Float - Percentage improvement vs control
- `statistical_power`: Float - Power of the test
- `computed_at`: Timestamp - Calculation timestamp
- `data_window`: JSON - Time range of data
  - `start`: Timestamp - Start of data window
  - `end`: Timestamp - End of data window

**Relationships:**
- Belongs to Experiment

**Validation Rules:**
- P-value must be between 0 and 1
- Sample size must be positive
- Confidence interval must contain mean value

### 4. FeatureFlag
Toggleable features with gradual rollout capability.

**Fields:**
- `id`: UUID - Flag identifier
- `key`: String - Unique flag key
- `name`: String - Display name
- `description`: Text - Flag purpose
- `type`: Enum - Type (Boolean|String|Number|JSON)
- `default_value`: JSON - Default when not enabled
- `enabled`: Boolean - Global on/off switch
- `rollout_percentage`: Float - Percentage of users (0-100)
- `targeting_rules`: JSON - User segment rules
  - `segments`: Array<String> - User segments
  - `attributes`: JSON - User attribute conditions
- `dependencies`: JSON - Other required flags
- `experiment_id`: UUID - Associated experiment (optional)
- `created_at`: Timestamp - Creation timestamp
- `updated_at`: Timestamp - Last modification

**Relationships:**
- May belong to Experiment
- Has many user overrides

**Validation Rules:**
- Key must be unique and valid identifier
- Rollout percentage between 0 and 100
- Dependencies must reference existing flags

## Supporting Entities

### ExperimentMetric
Definition of metrics tracked in experiments.

**Fields:**
- `id`: UUID - Metric identifier
- `name`: String - Metric name
- `type`: Enum - Metric type (Count|Rate|Duration|Revenue)
- `calculation`: String - How to calculate
- `unit`: String - Unit of measurement
- `aggregation`: Enum - Aggregation method (Sum|Average|Percentile)

### SegmentDefinition
User segment definitions for targeting.

**Fields:**
- `id`: UUID - Segment identifier
- `name`: String - Segment name
- `conditions`: JSON - Segment criteria
- `size_estimate`: Integer - Estimated user count
- `is_active`: Boolean - Whether segment is active

## Relationships Diagram

```
Experiment
    ├── ExperimentAssignment
    │   └── UserProfile (from core platform)
    ├── ExperimentResult
    └── FeatureFlag (optional)

FeatureFlag
    ├── Experiment (optional)
    └── UserOverrides

ExperimentMetric
    └── ExperimentResult

SegmentDefinition
    ├── Experiment (targeting)
    └── FeatureFlag (targeting)
```

## Data Constraints

### Performance Requirements
- Assignment lookup: <50ms (P95)
- Result computation: <5s for standard metrics
- Feature flag evaluation: <10ms

### Storage Requirements
- Experiments: ~5KB per experiment
- Assignments: ~200B per assignment
- Results: ~1KB per metric per variant
- Feature flags: ~1KB per flag

### Retention Policies
- Experiments: Indefinite
- Assignments: 180 days after experiment end
- Results: Indefinite for completed experiments
- Feature flags: Until explicitly deleted

### Scale Requirements
- Support 1000+ concurrent experiments
- 10M+ assignments per hour
- 100M+ feature flag evaluations per hour