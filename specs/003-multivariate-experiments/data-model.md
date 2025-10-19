# Data Model: Multivariate Experimentation Platform

## Core Entities (5 total)

### 1. MultivariateExperiment
Full/fractional factorial design with multiple variables and levels.

**Fields:**
- `id`: UUID - Unique experiment identifier
- `name`: String - Experiment name
- `description`: Text - Experiment purpose and hypothesis
- `design_type`: Enum - Design type (FullFactorial|FractionalFactorial|LatinSquare|OrthogonalArray)
- `status`: Enum - Status (Draft|Running|Paused|Completed|Archived)
- `variables`: JSON - Array of experimental variables
  - `name`: String - Variable name
  - `levels`: Array<Any> - Possible values for this variable
  - `type`: String - Variable type (categorical|continuous)
- `combinations`: JSON - Generated test combinations
  - `combination_id`: String - Unique combination identifier
  - `variable_values`: Object - Values for each variable
  - `traffic_allocation`: Float - Traffic percentage
- `interaction_matrix`: JSON - Interaction effects to test
- `power_analysis`: JSON - Statistical power calculations
  - `effect_size`: Float - Expected effect size
  - `power`: Float - Statistical power (typically 0.8)
  - `required_sample_size`: Integer - Calculated sample size
- `created_at`: Timestamp - Creation time
- `updated_at`: Timestamp - Last update

**Relationships:**
- Has many BanditConfigurations
- Has many StatisticalModels
- Has many ExperimentResults (inherited)

**Validation Rules:**
- Maximum 5 variables with 4 levels each
- Design type must match variable configuration
- Power analysis required before running

### 2. BanditConfiguration
Multi-armed bandit setup with algorithm choice and exploration parameters.

**Fields:**
- `id`: UUID - Configuration identifier
- `experiment_id`: UUID - Reference to experiment
- `algorithm`: Enum - Algorithm type (EpsilonGreedy|ThompsonSampling|UCB|Contextual)
- `exploration_rate`: Float - Exploration vs exploitation (0-1)
- `context_features`: JSON - Features for contextual bandits
  - `user_features`: Array<String> - User attributes to consider
  - `content_features`: Array<String> - Content attributes to consider
- `arm_definitions`: JSON - Definition of each arm
  - `arm_id`: String - Unique arm identifier
  - `configuration`: Object - What this arm represents
  - `prior`: Object - Prior distribution parameters
- `update_frequency`: Integer - How often to update allocations (seconds)
- `regret_threshold`: Float - Acceptable regret level
- `non_stationary_params`: JSON - Drift detection settings
  - `window_size`: Integer - Detection window
  - `drift_threshold`: Float - Change threshold
- `is_active`: Boolean - Whether bandit is running
- `created_at`: Timestamp - Creation time

**Relationships:**
- Belongs to MultivariateExperiment
- Has many BanditAllocations
- Has many RegretMetrics

**Validation Rules:**
- Exploration rate between 0 and 1
- At least 2 arms required
- Context features must exist in data model

### 3. BayesianModel
Gaussian process or other probabilistic model for optimization.

**Fields:**
- `id`: UUID - Model identifier
- `experiment_id`: UUID - Reference to experiment
- `model_type`: Enum - Model type (GaussianProcess|BayesianLinear|DirichletProcess)
- `hyperparameters`: JSON - Model hyperparameters
  - `kernel`: String - Kernel function for GP
  - `length_scale`: Float - GP length scale
  - `noise_variance`: Float - Observation noise
- `acquisition_function`: Enum - Acquisition type (ExpectedImprovement|UCB|ProbabilityImprovement)
- `parameter_space`: JSON - Continuous parameter definitions
  - `parameters`: Array<Object> - Parameter definitions
    - `name`: String - Parameter name
    - `bounds`: Array<Float> - [min, max]
    - `scale`: String - Linear or log scale
- `posterior_state`: JSON - Current posterior distribution
- `next_points`: JSON - Suggested next experiments
- `convergence_metrics`: JSON - Model convergence tracking
- `updated_at`: Timestamp - Last posterior update

**Relationships:**
- Belongs to MultivariateExperiment
- Has many OptimizationIterations

**Validation Rules:**
- Parameter bounds must be valid ranges
- Acquisition function must match model type
- Posterior updates must be sequential

### 4. NetworkGraph
Social network structure for cluster randomization and spillover analysis.

**Fields:**
- `id`: UUID - Graph identifier
- `experiment_id`: UUID - Reference to experiment
- `graph_type`: Enum - Graph structure (Social|Geographic|Behavioral)
- `nodes`: JSON - Network nodes (users/entities)
  - `node_id`: String - Unique node identifier
  - `attributes`: Object - Node properties
  - `cluster_id`: String - Assigned cluster
- `edges`: JSON - Network connections
  - `source`: String - Source node ID
  - `target`: String - Target node ID
  - `weight`: Float - Connection strength
- `clusters`: JSON - Cluster definitions
  - `cluster_id`: String - Cluster identifier
  - `size`: Integer - Number of nodes
  - `treatment`: String - Assigned treatment
- `spillover_model`: JSON - Spillover effect parameters
  - `influence_decay`: Float - How influence decays with distance
  - `threshold`: Float - Minimum influence to matter
- `randomization_seed`: Integer - For reproducibility
- `created_at`: Timestamp - Graph creation time

**Relationships:**
- Belongs to MultivariateExperiment
- Has many SpilloverMeasurements

**Validation Rules:**
- Clusters must partition all nodes
- Edge weights between 0 and 1
- Graph must be connected or have defined components

### 5. StatisticalModel
Hierarchical or time series models for advanced analysis.

**Fields:**
- `id`: UUID - Model identifier
- `experiment_id`: UUID - Reference to experiment
- `model_class`: Enum - Model class (Hierarchical|TimeSeries|MixedEffects|Causal)
- `specification`: JSON - Model specification
  - `formula`: String - Statistical formula
  - `random_effects`: Array<String> - Random effect terms
  - `fixed_effects`: Array<String> - Fixed effect terms
  - `time_structure`: Object - For time series models
- `estimation_method`: Enum - Estimation approach (MLE|Bayesian|Bootstrap)
- `fitted_parameters`: JSON - Estimated model parameters
- `model_diagnostics`: JSON - Model fit statistics
  - `aic`: Float - Akaike Information Criterion
  - `bic`: Float - Bayesian Information Criterion
  - `r_squared`: Float - Variance explained
  - `residual_analysis`: Object - Residual diagnostics
- `predictions`: JSON - Model predictions
- `uncertainty_quantification`: JSON - Prediction intervals
- `computed_at`: Timestamp - Last computation time

**Relationships:**
- Belongs to MultivariateExperiment
- Has many ModelPredictions

**Validation Rules:**
- Formula must be valid statistical notation
- Model diagnostics must pass goodness-of-fit tests
- Predictions must include uncertainty bounds

## Supporting Entities

### BanditAllocation
Real-time traffic allocation from bandit algorithm.

**Fields:**
- `id`: UUID - Allocation identifier
- `bandit_config_id`: UUID - Reference to BanditConfiguration
- `timestamp`: Timestamp - Allocation time
- `arm_probabilities`: JSON - Probability per arm
- `selected_arm`: String - Chosen arm for this round
- `reward`: Float - Observed reward
- `context`: JSON - Context at decision time

### OptimizationIteration
Single iteration of Bayesian optimization.

**Fields:**
- `id`: UUID - Iteration identifier
- `model_id`: UUID - Reference to BayesianModel
- `iteration_number`: Integer - Sequential iteration
- `suggested_point`: JSON - Parameter values to test
- `observed_value`: Float - Observed objective value
- `acquisition_value`: Float - Acquisition function value
- `improvement`: Float - Improvement over best

### SpilloverMeasurement
Measurement of network spillover effects.

**Fields:**
- `id`: UUID - Measurement identifier
- `graph_id`: UUID - Reference to NetworkGraph
- `timestamp`: Timestamp - Measurement time
- `direct_effect`: Float - Direct treatment effect
- `indirect_effect`: Float - Spillover effect
- `total_effect`: Float - Combined effect
- `affected_nodes`: Array<String> - Nodes showing spillover

## Relationships Diagram

```
MultivariateExperiment
    ├── BanditConfiguration
    │   └── BanditAllocation
    ├── BayesianModel
    │   └── OptimizationIteration
    ├── NetworkGraph
    │   └── SpilloverMeasurement
    └── StatisticalModel
        └── ModelPredictions

Integration with A/B Testing:
    MultivariateExperiment extends Experiment
    Uses ExperimentAssignment for user allocation
    Shares ExperimentResult for basic metrics
```

## Data Constraints

### Performance Requirements
- Bandit allocation update: <100ms
- Bayesian posterior update: <5s
- Network spillover calculation: <10s
- Statistical model fitting: <30s

### Storage Requirements
- Multivariate experiments: ~20KB per experiment
- Bandit configurations: ~5KB per configuration
- Bayesian models: ~100KB per model (with posterior)
- Network graphs: ~1MB per 10K nodes
- Statistical models: ~50KB per model

### Retention Policies
- Experiments: Indefinite
- Bandit allocations: 90 days rolling window
- Optimization iterations: Indefinite
- Network graphs: Duration of experiment
- Model artifacts: 1 year after experiment end

### Scale Requirements
- 100+ concurrent multivariate experiments
- 1M+ bandit decisions per hour
- 10K+ node network graphs
- Real-time posterior updates for 50+ models