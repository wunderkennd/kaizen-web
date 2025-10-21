#!/bin/bash

# Complete script to create ALL 158 GitHub issues for KAIZEN Platform
# This creates every single task from T001 to T164

echo "Creating ALL 158 GitHub issues for KAIZEN Platform..."
echo "This will take a few minutes to complete..."

# Create labels first (will skip if they exist)
echo "Creating labels..."
gh label create "001-adaptive-platform" --description "Core adaptive platform tasks" --color "0052CC" 2>/dev/null || true
gh label create "002-ab-testing" --description "A/B testing infrastructure tasks" --color "00875A" 2>/dev/null || true
gh label create "003-multivariate" --description "Multivariate experimentation tasks" --color "5319E7" 2>/dev/null || true
gh label create "parallel" --description "Can be executed in parallel" --color "FBCA04" 2>/dev/null || true
gh label create "blocked" --description "Blocked by dependencies" --color "D93F0B" 2>/dev/null || true
gh label create "done" --description "Task completed" --color "0E8A16" 2>/dev/null || true

# Counter for tracking
CREATED=0
FAILED=0

# Function to create issue
create_issue() {
    local task_id="$1"
    local desc="$2"
    local path="$3"
    local labels="$4"
    local deps="$5"
    local status="$6"
    
    local title="[${task_id}] ${desc}"
    
    # Add status label if done
    if [[ "$status" == "done" ]]; then
        labels="${labels},done"
    fi
    
    echo "Creating issue ${task_id}..."
    
    gh issue create \
        --title "${title}" \
        --body "## Task: ${task_id}

**Description**: ${desc}
**File Path**: \`${path}\`
**Labels**: ${labels}
${deps:+**Dependencies**: ${deps}}
**Status**: ${status}

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated

### Notes
Part of the KAIZEN Adaptive Platform implementation." \
        --label "${labels}" 2>/dev/null && ((CREATED++)) || ((FAILED++))
}

echo ""
echo "=== Phase 3.1: Project Setup & Infrastructure (T001-T010) ==="

create_issue "T001" "Create repository structure per plan.md microservices layout" "root" "001-adaptive-platform" "" "done"
create_issue "T002" "Initialize Next.js 14 frontend with TypeScript" "frontend/" "001-adaptive-platform,parallel" "T001" "done"
create_issue "T003" "Initialize Rust workspace for kre-engine" "services/kre-engine/" "001-adaptive-platform,parallel" "T001" "done"
create_issue "T004" "Initialize Go module for genui-orchestrator" "services/genui-orchestrator/" "001-adaptive-platform,parallel" "T001" "done"
create_issue "T005" "Initialize Go module for user-context" "services/user-context/" "001-adaptive-platform,parallel" "T001" "done"
create_issue "T006" "Initialize Python FastAPI project for ai-sommelier" "services/ai-sommelier/" "001-adaptive-platform,parallel" "T001" "done"
create_issue "T007" "Initialize Python/Rust hybrid for pcm-classifier" "services/pcm-classifier/" "001-adaptive-platform,parallel" "T001" "done"
create_issue "T008" "Initialize Rust project for streaming-adapter" "services/streaming-adapter/" "001-adaptive-platform,parallel" "T001" "todo"
create_issue "T009" "Create docker-compose.yml with PostgreSQL, Redis, and service definitions" "root" "001-adaptive-platform" "T001-T008" "todo"
create_issue "T010" "Setup shared contracts and protos directories with build scripts" "shared/" "001-adaptive-platform,parallel" "T001" "todo"
create_issue "T010a" "Setup Pinecone vector database for semantic search embeddings" "infrastructure/" "001-adaptive-platform,parallel" "T010" "todo"

echo ""
echo "=== Phase 3.2: Database & Migrations (T011-T015) ==="

create_issue "T011" "Create PostgreSQL schema migrations for all 11 entities" "migrations/" "001-adaptive-platform" "T009" "todo"
create_issue "T012" "Create migration for UserProfile table with PCM stages" "migrations/" "001-adaptive-platform,parallel" "T011" "todo"
create_issue "T013" "Create migration for ContextSnapshot and UIConfiguration tables" "migrations/" "001-adaptive-platform,parallel" "T011" "todo"
create_issue "T014" "Create migration for AdaptationRule and RuleSetVersion tables" "migrations/" "001-adaptive-platform,parallel" "T011" "todo"
create_issue "T015" "Create migration for ContentItem and DiscoveryQuery tables" "migrations/" "001-adaptive-platform,parallel" "T011" "todo"

echo ""
echo "=== Phase 3.3: Contract Tests (T016-T025) ==="

create_issue "T016" "GraphQL schema test for generateUI query" "frontend/tests/contract/test_genui_query.ts" "001-adaptive-platform,parallel" "T002" "todo"
create_issue "T017" "GraphQL schema test for searchContent query" "frontend/tests/contract/test_search_query.ts" "001-adaptive-platform,parallel" "T002" "todo"
create_issue "T018" "GraphQL schema test for rerankComponents mutation" "frontend/tests/contract/test_rerank_mutation.ts" "001-adaptive-platform,parallel" "T002" "todo"
create_issue "T019" "OpenAPI contract test for POST /ui/generate" "services/genui-orchestrator/tests/contract_test.go" "001-adaptive-platform,parallel" "T004" "todo"
create_issue "T020" "OpenAPI contract test for POST /ui/rerank" "services/genui-orchestrator/tests/rerank_test.go" "001-adaptive-platform,parallel" "T004" "todo"
create_issue "T021" "OpenAPI contract test for POST /ui/morph" "services/genui-orchestrator/tests/morph_test.go" "001-adaptive-platform,parallel" "T004" "todo"
create_issue "T022" "OpenAPI contract test for POST /context/capture" "services/user-context/tests/context_test.go" "001-adaptive-platform,parallel" "T005" "todo"
create_issue "T023" "OpenAPI contract test for POST /rules/evaluate" "services/kre-engine/tests/rules_test.rs" "001-adaptive-platform,parallel" "T003" "todo"
create_issue "T024" "OpenAPI contract test for POST /discovery/search" "services/ai-sommelier/tests/test_search.py" "001-adaptive-platform,parallel" "T006" "todo"
create_issue "T025" "gRPC contract test for inter-service communication" "shared/protos/tests/" "001-adaptive-platform,parallel" "T010" "todo"

echo ""
echo "=== Phase 3.4: Data Models (T026-T036) ==="

create_issue "T026" "UserProfile model with PCM stages" "services/user-context/internal/models/user.go" "001-adaptive-platform,parallel" "T012" "todo"
create_issue "T027" "ContextSnapshot model" "services/user-context/internal/models/context.go" "001-adaptive-platform,parallel" "T013" "todo"
create_issue "T028" "UIConfiguration model" "services/genui-orchestrator/internal/models/ui_config.go" "001-adaptive-platform,parallel" "T013" "todo"
create_issue "T029" "KDSComponent model" "services/genui-orchestrator/internal/models/component.go" "001-adaptive-platform,parallel" "T028" "todo"
create_issue "T030" "ComponentInstance model" "services/genui-orchestrator/internal/models/instance.go" "001-adaptive-platform,parallel" "T029" "todo"
create_issue "T031" "AdaptationRule model" "services/kre-engine/src/models/rule.rs" "001-adaptive-platform,parallel" "T014" "todo"
create_issue "T032" "RuleSetVersion model" "services/kre-engine/src/models/ruleset.rs" "001-adaptive-platform,parallel" "T031" "todo"
create_issue "T033" "ContentItem model" "services/ai-sommelier/src/models/content.py" "001-adaptive-platform,parallel" "T015" "todo"
create_issue "T034" "DiscoveryQuery model" "services/ai-sommelier/src/models/query.py" "001-adaptive-platform,parallel" "T015" "todo"
create_issue "T035" "MasteryTrack model" "services/user-context/internal/models/mastery.go" "001-adaptive-platform,parallel" "T026" "todo"
create_issue "T036" "LayoutPerformance model" "services/genui-orchestrator/internal/models/performance.go" "001-adaptive-platform,parallel" "T028" "todo"

echo ""
echo "=== Phase 3.5: Core Services Implementation (T037-T050a) ==="

create_issue "T037" "Rule evaluation engine" "services/kre-engine/src/engine/evaluator.rs" "001-adaptive-platform" "T031,T032" "todo"
create_issue "T038" "Rule priority resolver" "services/kre-engine/src/engine/resolver.rs" "001-adaptive-platform" "T037" "todo"
create_issue "T039" "Rule conflict detection" "services/kre-engine/src/engine/conflicts.rs" "001-adaptive-platform" "T038" "todo"
create_issue "T040" "UI assembly pipeline" "services/genui-orchestrator/internal/assembly/pipeline.go" "001-adaptive-platform" "T028,T029,T030" "todo"
create_issue "T041" "Component selection logic" "services/genui-orchestrator/internal/assembly/selector.go" "001-adaptive-platform" "T040" "todo"
create_issue "T042" "Layout optimization engine" "services/genui-orchestrator/internal/assembly/optimizer.go" "001-adaptive-platform" "T041" "todo"
create_issue "T043" "Context capture service" "services/user-context/internal/capture/collector.go" "001-adaptive-platform" "T026,T027" "todo"
create_issue "T044" "PCM stage classifier integration" "services/user-context/internal/pcm/classifier.go" "001-adaptive-platform" "T043" "todo"
create_issue "T045" "Real-time context updates" "services/user-context/internal/realtime/updater.go" "001-adaptive-platform" "T043" "todo"
create_issue "T046" "Natural language query processor" "services/ai-sommelier/src/nlp/processor.py" "001-adaptive-platform" "T033,T034" "todo"
create_issue "T047" "Mood-based recommendation engine" "services/ai-sommelier/src/mood/recommender.py" "001-adaptive-platform" "T046" "todo"
create_issue "T048" "Content semantic search" "services/ai-sommelier/src/search/semantic.py" "001-adaptive-platform" "T046,T010a" "todo"
create_issue "T049" "PCM classification service" "services/pcm-classifier/src/main.rs" "001-adaptive-platform,parallel" "T007" "todo"
create_issue "T050" "Streaming adapter service" "services/streaming-adapter/src/main.rs" "001-adaptive-platform,parallel" "T008" "todo"
create_issue "T050a" "Authentication service integration" "services/user-context/internal/auth/handler.go" "001-adaptive-platform" "T043" "todo"

echo ""
echo "=== Phase 3.6: Frontend KDS Components (T051-T060d) ==="

create_issue "T051" "Button atom variations" "frontend/src/components/kds/atoms/button.tsx" "001-adaptive-platform,parallel" "T002" "todo"
create_issue "T052" "Input atom with adaptive density" "frontend/src/components/kds/atoms/input.tsx" "001-adaptive-platform,parallel" "T002" "todo"
create_issue "T053" "Card molecule with dynamic properties" "frontend/src/components/kds/molecules/card.tsx" "001-adaptive-platform,parallel" "T051,T052" "todo"
create_issue "T054" "Hero banner component" "frontend/src/components/adaptive/hero-banner.tsx" "001-adaptive-platform,parallel" "T053" "todo"
create_issue "T055" "Content grid with reranking" "frontend/src/components/adaptive/content-grid.tsx" "001-adaptive-platform,parallel" "T053" "todo"
create_issue "T056" "Navigation with PCM adaptation" "frontend/src/components/adaptive/navigation.tsx" "001-adaptive-platform,parallel" "T051" "todo"
create_issue "T057" "Page layout orchestrator" "frontend/src/components/adaptive/page-layout.tsx" "001-adaptive-platform,parallel" "T054,T055,T056" "todo"
create_issue "T058" "Dynamic sidebar component" "frontend/src/components/adaptive/sidebar.tsx" "001-adaptive-platform,parallel" "T056" "todo"
create_issue "T059" "Search interface with AI Sommelier" "frontend/src/components/adaptive/search.tsx" "001-adaptive-platform,parallel" "T052" "todo"
create_issue "T060" "Recommendation carousel" "frontend/src/components/adaptive/carousel.tsx" "001-adaptive-platform,parallel" "T053" "todo"
create_issue "T060a" "V-CRUNCH vertical feed" "frontend/src/components/social/v-crunch-feed.tsx" "001-adaptive-platform,parallel" "T055" "todo"
create_issue "T060b" "Social interaction buttons" "frontend/src/components/social/interaction-panel.tsx" "001-adaptive-platform,parallel" "T051" "todo"
create_issue "T060c" "Community comment system" "frontend/src/components/social/comments.tsx" "001-adaptive-platform,parallel" "T052" "todo"
create_issue "T060d" "Co-watching optimization UI" "frontend/src/components/social/co-watch.tsx" "001-adaptive-platform,parallel" "T060a" "todo"

echo ""
echo "=== Phase 3.7: Integration Tests (T061-T068) ==="

create_issue "T061" "Integration test: New User Onboarding" "frontend/tests/e2e/onboarding.spec.ts" "001-adaptive-platform,parallel" "T057" "todo"
create_issue "T062" "Integration test: PCM Stage Adaptation" "frontend/tests/e2e/pcm-adaptation.spec.ts" "001-adaptive-platform,parallel" "T044" "todo"
create_issue "T063" "Integration test: Cross-device sync" "frontend/tests/e2e/device-sync.spec.ts" "001-adaptive-platform,parallel" "T045" "todo"
create_issue "T064" "Integration test: AI Sommelier Discovery" "frontend/tests/e2e/ai-discovery.spec.ts" "001-adaptive-platform,parallel" "T046,T047,T048" "todo"
create_issue "T065" "Integration test: Dynamic Component Reranking" "frontend/tests/e2e/reranking.spec.ts" "001-adaptive-platform,parallel" "T041" "todo"
create_issue "T066" "Integration test: Rule conflict resolution" "frontend/tests/e2e/rule-conflicts.spec.ts" "001-adaptive-platform,parallel" "T039" "todo"
create_issue "T067" "Integration test: Context-aware adaptation" "frontend/tests/e2e/context-adaptation.spec.ts" "001-adaptive-platform,parallel" "T043" "todo"
create_issue "T068" "Integration test: Social feature integration" "frontend/tests/e2e/social-features.spec.ts" "001-adaptive-platform,parallel" "T060a,T060b,T060c,T060d" "todo"

echo ""
echo "=== Phase 3.8: RMI Designer Tool (T069-T072) ==="

create_issue "T069" "Rule designer interface" "rmi-designer/src/pages/rules/designer.tsx" "001-adaptive-platform" "T037,T038,T039" "todo"
create_issue "T070" "Rule simulation playground" "rmi-designer/src/components/simulation/playground.tsx" "001-adaptive-platform,parallel" "T069" "todo"
create_issue "T071" "Component property editor" "rmi-designer/src/components/editor/property-editor.tsx" "001-adaptive-platform,parallel" "T069" "todo"
create_issue "T072" "Rule conflict visualizer" "rmi-designer/src/components/visualization/conflicts.tsx" "001-adaptive-platform,parallel" "T039,T069" "todo"

echo ""
echo "=== Phase 3.9: Deployment & Operations (T073-T080) ==="

create_issue "T073" "Kubernetes manifests" "k8s/" "001-adaptive-platform" "T009" "todo"
create_issue "T074" "CI/CD pipeline configuration" ".github/workflows/" "001-adaptive-platform,parallel" "T073" "todo"
create_issue "T075" "Monitoring setup (Prometheus/Grafana)" "monitoring/" "001-adaptive-platform,parallel" "T073" "todo"
create_issue "T076" "Logging configuration" "logging/" "001-adaptive-platform,parallel" "T073" "todo"
create_issue "T077" "Performance benchmarking suite" "benchmarks/" "001-adaptive-platform" "T040,T037" "todo"
create_issue "T078" "Health check endpoints across all services" "services/" "001-adaptive-platform,parallel" "T037,T040,T043,T046" "todo"
create_issue "T079" "Load balancer configuration" "infrastructure/" "001-adaptive-platform,parallel" "T073" "todo"
create_issue "T080" "Manual testing following quickstart.md scenarios" "docs/" "001-adaptive-platform" "T061-T068" "todo"

echo ""
echo "=== Phase 3.10: Ecosystem Integration Features (T081-T098) ==="

create_issue "T081" "Shop the Scene detection service" "services/ai-sommelier/src/commerce/scene_detector.py" "001-adaptive-platform" "T046" "todo"
create_issue "T082" "Merchandise matching engine" "services/ai-sommelier/src/commerce/product_matcher.py" "001-adaptive-platform" "T081" "todo"
create_issue "T083" "Shop the Scene UI overlay" "frontend/src/components/commerce/shop-overlay.tsx" "001-adaptive-platform,parallel" "T081,T082" "todo"
create_issue "T084" "Commerce API client" "frontend/src/services/commerce-client.ts" "001-adaptive-platform,parallel" "T083" "todo"
create_issue "T085" "Watch tracking service" "services/user-context/internal/gaming/watch_tracker.go" "001-adaptive-platform" "T043" "todo"
create_issue "T086" "Reward calculation engine" "services/user-context/internal/gaming/rewards.go" "001-adaptive-platform" "T085" "todo"
create_issue "T087" "Gaming integration UI" "frontend/src/components/gaming/rewards-panel.tsx" "001-adaptive-platform,parallel" "T086" "todo"
create_issue "T088" "AR component for mobile" "frontend/src/components/ar/ar-viewer.tsx" "001-adaptive-platform,parallel" "T002" "todo"
create_issue "T089" "3D model loader service" "frontend/src/services/model-loader.ts" "001-adaptive-platform,parallel" "T088" "todo"
create_issue "T090" "AR placement controls" "frontend/src/components/ar/placement-controls.tsx" "001-adaptive-platform,parallel" "T088" "todo"
create_issue "T091" "Privacy settings UI" "frontend/src/components/privacy/settings-panel.tsx" "001-adaptive-platform" "T051,T052" "todo"
create_issue "T092" "Data export service (GDPR)" "services/user-context/internal/privacy/data_export.go" "001-adaptive-platform" "T026" "todo"
create_issue "T093" "Data deletion service (GDPR)" "services/user-context/internal/privacy/data_deletion.go" "001-adaptive-platform" "T026" "todo"
create_issue "T094" "Cookie consent banner" "frontend/src/components/privacy/cookie-consent.tsx" "001-adaptive-platform,parallel" "T051" "todo"
create_issue "T095" "AI disclosure indicators" "frontend/src/components/ui/ai-indicator.tsx" "001-adaptive-platform,parallel" "T051" "todo"
create_issue "T096" "Age verification service (COPPA)" "services/user-context/internal/privacy/age_verify.go" "001-adaptive-platform" "T026" "todo"
create_issue "T097" "Privacy policy display" "frontend/src/pages/privacy-policy.tsx" "001-adaptive-platform,parallel" "T002" "todo"
create_issue "T098" "Accessibility audit task for WCAG 2.1 AA compliance" "frontend/tests/a11y/" "001-adaptive-platform" "T051-T060" "todo"

echo ""
echo "=== Phase 3.11: A/B Testing Infrastructure (T105-T122) ==="

create_issue "T105" "Initialize experiment-service Go module" "services/experiment-service/" "002-ab-testing,parallel" "" "todo"
create_issue "T106" "Create PostgreSQL schema for experiments" "migrations/experiment_tables.sql" "002-ab-testing" "T105" "todo"
create_issue "T107" "Experiment data models" "services/experiment-service/internal/models/experiment.go" "002-ab-testing,parallel" "T106" "todo"
create_issue "T108" "Assignment cache with Redis" "services/experiment-service/internal/cache/assignment.go" "002-ab-testing,parallel" "T106" "todo"
create_issue "T109" "Experiment CRUD API" "services/experiment-service/internal/handlers/experiments.go" "002-ab-testing,parallel" "T107" "todo"
create_issue "T110" "Experiment targeting rules API" "services/experiment-service/internal/handlers/targeting.go" "002-ab-testing,parallel" "T107" "todo"
create_issue "T111" "Experiment status management" "services/experiment-service/internal/handlers/status.go" "002-ab-testing,parallel" "T107" "todo"
create_issue "T112" "Experiment configuration validation" "services/experiment-service/internal/validation/config.go" "002-ab-testing,parallel" "T107" "todo"
create_issue "T113" "User assignment algorithm" "services/experiment-service/internal/assignment/algorithm.go" "002-ab-testing,parallel" "T108" "todo"
create_issue "T114" "Consistent hashing for assignment" "services/experiment-service/internal/assignment/hasher.go" "002-ab-testing,parallel" "T113" "todo"
create_issue "T115" "Targeting engine with user segments" "services/experiment-service/internal/targeting/engine.go" "002-ab-testing,parallel" "T110" "todo"
create_issue "T116" "Assignment conflict detection" "services/experiment-service/internal/assignment/conflicts.go" "002-ab-testing,parallel" "T113" "todo"
create_issue "T117" "Metrics collection service" "services/experiment-service/internal/metrics/collector.go" "002-ab-testing,parallel" "T107" "todo"
create_issue "T118" "Statistical significance calculator" "services/experiment-service/internal/stats/significance.go" "002-ab-testing,parallel" "T117" "todo"
create_issue "T119" "Bayesian analysis engine" "services/experiment-service/internal/stats/bayesian.go" "002-ab-testing,parallel" "T117" "todo"
create_issue "T120" "Real-time monitoring alerts" "services/experiment-service/internal/monitoring/alerts.go" "002-ab-testing,parallel" "T117" "todo"
create_issue "T121" "Feature flag service" "services/experiment-service/internal/flags/manager.go" "002-ab-testing,parallel" "T107" "todo"
create_issue "T122" "Gradual rollout engine" "services/experiment-service/internal/rollout/engine.go" "002-ab-testing,parallel" "T121" "todo"

echo ""
echo "=== Phase 3.12: Multivariate Experimentation Platform (T123-T164) ==="

create_issue "T123" "Factorial design generator" "services/experiment-service/internal/design/factorial.go" "003-multivariate,parallel" "T105" "todo"
create_issue "T124" "Fractional factorial optimizer" "services/experiment-service/internal/design/fractional.go" "003-multivariate,parallel" "T123" "todo"
create_issue "T125" "Latin square design generator" "services/experiment-service/internal/design/latin_square.go" "003-multivariate,parallel" "T123" "todo"
create_issue "T126" "Orthogonal array generator" "services/experiment-service/internal/design/orthogonal.go" "003-multivariate,parallel" "T123" "todo"
create_issue "T127" "Interaction effect detector" "services/experiment-service/internal/stats/interactions.go" "003-multivariate,parallel" "T118" "todo"
create_issue "T128" "Power analysis calculator" "services/experiment-service/internal/stats/power.go" "003-multivariate,parallel" "T118" "todo"
create_issue "T129" "Effect size estimator" "services/experiment-service/internal/stats/effect_size.go" "003-multivariate,parallel" "T118" "todo"
create_issue "T130" "Multivariate result analyzer" "services/experiment-service/internal/analysis/multivariate.go" "003-multivariate,parallel" "T127,T128,T129" "todo"
create_issue "T131" "Initialize bandit-service Python module" "services/bandit-service/" "003-multivariate,parallel" "" "todo"
create_issue "T132" "Epsilon-greedy algorithm" "services/bandit-service/src/algorithms/epsilon_greedy.py" "003-multivariate,parallel" "T131" "todo"
create_issue "T133" "Thompson sampling algorithm" "services/bandit-service/src/algorithms/thompson.py" "003-multivariate,parallel" "T131" "todo"
create_issue "T134" "UCB algorithm implementation" "services/bandit-service/src/algorithms/ucb.py" "003-multivariate,parallel" "T131" "todo"
create_issue "T135" "Contextual bandit engine" "services/bandit-service/src/algorithms/contextual.py" "003-multivariate,parallel" "T131" "todo"
create_issue "T136" "Non-stationary bandit handler" "services/bandit-service/src/algorithms/non_stationary.py" "003-multivariate,parallel" "T131" "todo"
create_issue "T137" "Regret calculation engine" "services/bandit-service/src/metrics/regret.py" "003-multivariate,parallel" "T132,T133,T134" "todo"
create_issue "T138" "Real-time allocation updater" "services/bandit-service/src/allocation/updater.py" "003-multivariate,parallel" "T132,T133,T134" "todo"
create_issue "T139" "Gaussian process model" "services/bandit-service/src/optimization/gaussian_process.py" "003-multivariate,parallel" "T131" "todo"
create_issue "T140" "Acquisition function library" "services/bandit-service/src/optimization/acquisition.py" "003-multivariate,parallel" "T139" "todo"
create_issue "T141" "Expected improvement calculator" "services/bandit-service/src/optimization/expected_improvement.py" "003-multivariate,parallel" "T140" "todo"
create_issue "T142" "Hyperparameter optimizer" "services/bandit-service/src/optimization/hyperopt.py" "003-multivariate,parallel" "T139" "todo"
create_issue "T143" "Response surface modeler" "services/bandit-service/src/optimization/response_surface.py" "003-multivariate,parallel" "T139" "todo"
create_issue "T144" "Bayesian inference engine" "services/bandit-service/src/inference/bayesian.py" "003-multivariate,parallel" "T139" "todo"
create_issue "T145" "Posterior update service" "services/bandit-service/src/inference/posterior.py" "003-multivariate,parallel" "T144" "todo"
create_issue "T146" "Uncertainty quantification" "services/bandit-service/src/inference/uncertainty.py" "003-multivariate,parallel" "T144" "todo"
create_issue "T147" "CUPED variance reduction" "services/experiment-service/internal/stats/cuped.go" "003-multivariate,parallel" "T118" "todo"
create_issue "T148" "Sequential testing engine" "services/experiment-service/internal/stats/sequential.go" "003-multivariate,parallel" "T118" "todo"
create_issue "T149" "Alpha spending function" "services/experiment-service/internal/stats/alpha_spending.go" "003-multivariate,parallel" "T148" "todo"
create_issue "T150" "Bootstrap inference engine" "services/experiment-service/internal/stats/bootstrap.go" "003-multivariate,parallel" "T118" "todo"
create_issue "T151" "Permutation test engine" "services/experiment-service/internal/stats/permutation.go" "003-multivariate,parallel" "T118" "todo"
create_issue "T152" "Hierarchical model analyzer" "services/experiment-service/internal/stats/hierarchical.go" "003-multivariate,parallel" "T118" "todo"
create_issue "T153" "Time series analysis" "services/experiment-service/internal/stats/timeseries.go" "003-multivariate,parallel" "T118" "todo"
create_issue "T154" "Robust inference toolkit" "services/experiment-service/internal/stats/robust.go" "003-multivariate,parallel" "T150,T151" "todo"
create_issue "T155" "Initialize social-experiment-service" "services/social-experiment-service/" "003-multivariate,parallel" "" "todo"
create_issue "T156" "Cluster randomization engine" "services/social-experiment-service/internal/randomization/cluster.go" "003-multivariate,parallel" "T155" "todo"
create_issue "T157" "Graph-based randomization" "services/social-experiment-service/internal/randomization/graph.go" "003-multivariate,parallel" "T155" "todo"
create_issue "T158" "Spillover effect detector" "services/social-experiment-service/internal/effects/spillover.go" "003-multivariate,parallel" "T156,T157" "todo"
create_issue "T159" "Network interference analyzer" "services/social-experiment-service/internal/effects/interference.go" "003-multivariate,parallel" "T156,T157" "todo"
create_issue "T160" "Social graph parser" "services/social-experiment-service/internal/graph/parser.go" "003-multivariate,parallel" "T155" "todo"
create_issue "T161" "Encouragement design engine" "services/social-experiment-service/internal/design/encouragement.go" "003-multivariate,parallel" "T156" "todo"
create_issue "T162" "V-CRUNCH experiment integration" "services/social-experiment-service/internal/integration/vcrunch.go" "003-multivariate,parallel" "T060a,T155" "todo"
create_issue "T163" "ML model optimizer" "services/bandit-service/src/ml/model_optimizer.py" "003-multivariate,parallel" "T142" "todo"
create_issue "T164" "Distributed inference engine" "services/bandit-service/src/distributed/inference.py" "003-multivariate,parallel" "T144,T145" "todo"

echo ""
echo "========================================="
echo "Issue Creation Summary:"
echo "Created: $CREATED issues"
echo "Failed: $FAILED issues (may already exist)"
echo "Total expected: 158 issues"
echo ""
echo "Next steps:"
echo "1. Go to: https://github.com/wunderkennd/kaizen-web/issues"
echo "2. Verify all issues are created"
echo "3. Create GitHub Project at: https://github.com/wunderkennd/kaizen-web/projects"
echo "4. Add all issues to the project using labels filter"
echo "========================================="