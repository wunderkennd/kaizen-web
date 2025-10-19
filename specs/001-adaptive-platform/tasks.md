# Tasks: KAIZEN Adaptive Platform Core

**Input**: Core platform requirements  
**Prerequisites**: None (foundational system)  
**Task Count**: 98 total (T001-T098 main tasks + T050a auth + T060a-d sub-tasks)

## Execution Flow

```
1. Infrastructure Setup (T001-T010)
   → Service initialization and shared infrastructure
2. Database & Migrations (T011-T015)
   → Core entity storage setup
3. Contract Tests - TDD (T016-T025)
   → API contracts MUST fail before implementation
4. Data Models (T026-T036)
   → Core entities and relationships
5. Core Services (T037-T050a)
   → KRE, GenUI, Context, AI Sommelier, PCM, Streaming
6. Frontend Components (T051-T060d)
   → KDS components and V-CRUNCH social features
7. Integration Tests (T061-T068)
   → End-to-end user scenarios
8. RMI Designer (T069-T072)
   → Rule management interface
9. Deployment (T073-T080)
   → Production infrastructure
10. Ecosystem Features (T081-T098)
    → Commerce, Gaming, AR, Privacy compliance
```

## Phase 3.1: Project Setup & Infrastructure (T001-T010)

- [x] T001 Create repository structure per plan.md microservices layout
- [x] T002 [P] Initialize Next.js 14 frontend with TypeScript in `frontend/`
- [x] T003 [P] Initialize Rust workspace for kre-engine in `services/kre-engine/`
- [x] T004 [P] Initialize Go module for genui-orchestrator in `services/genui-orchestrator/`
- [x] T005 [P] Initialize Go module for user-context in `services/user-context/`
- [x] T006 [P] Initialize Python FastAPI project for ai-sommelier in `services/ai-sommelier/`
- [x] T007 [P] Initialize Python/Rust hybrid for pcm-classifier in `services/pcm-classifier/`
- [ ] T008 [P] Initialize Rust project for streaming-adapter in `services/streaming-adapter/`
- [ ] T009 Create docker-compose.yml with PostgreSQL, Redis, and service definitions
- [ ] T010 [P] Setup shared contracts and protos directories with build scripts
- [ ] T010a [P] Setup Pinecone vector database for semantic search embeddings

## Phase 3.2: Database & Migrations (T011-T015)

- [ ] T011 Create PostgreSQL schema migrations for all 11 entities in `migrations/`
- [ ] T012 [P] Create migration for UserProfile table with PCM stages
- [ ] T013 [P] Create migration for ContextSnapshot and UIConfiguration tables
- [ ] T014 [P] Create migration for AdaptationRule and RuleSetVersion tables
- [ ] T015 [P] Create migration for ContentItem and DiscoveryQuery tables

## Phase 3.3: Contract Tests (TDD - MUST FAIL FIRST) (T016-T025)

**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [ ] T016 [P] GraphQL schema test for generateUI query in `frontend/tests/contract/test_genui_query.ts`
- [ ] T017 [P] GraphQL schema test for searchContent query in `frontend/tests/contract/test_search_query.ts`
- [ ] T018 [P] GraphQL schema test for rerankComponents mutation in `frontend/tests/contract/test_rerank_mutation.ts`
- [ ] T019 [P] OpenAPI contract test for POST /ui/generate in `services/genui-orchestrator/tests/contract_test.go`
- [ ] T020 [P] OpenAPI contract test for POST /ui/rerank in `services/genui-orchestrator/tests/rerank_test.go`
- [ ] T021 [P] OpenAPI contract test for POST /ui/morph in `services/genui-orchestrator/tests/morph_test.go`
- [ ] T022 [P] OpenAPI contract test for POST /context/capture in `services/user-context/tests/context_test.go`
- [ ] T023 [P] OpenAPI contract test for POST /rules/evaluate in `services/kre-engine/tests/rules_test.rs`
- [ ] T024 [P] OpenAPI contract test for POST /discovery/search in `services/ai-sommelier/tests/test_search.py`
- [ ] T025 [P] gRPC contract test for inter-service communication in `shared/protos/tests/`

## Phase 3.4: Data Models (T026-T036)

- [ ] T026 [P] UserProfile model with PCM stages in `services/user-context/internal/models/user.go`
- [ ] T027 [P] ContextSnapshot model in `services/user-context/internal/models/context.go`
- [ ] T028 [P] UIConfiguration model in `services/genui-orchestrator/internal/models/ui_config.go`
- [ ] T029 [P] KDSComponent model in `services/genui-orchestrator/internal/models/component.go`
- [ ] T030 [P] ComponentInstance model in `services/genui-orchestrator/internal/models/instance.go`
- [ ] T031 [P] AdaptationRule model in `services/kre-engine/src/models/rule.rs`
- [ ] T032 [P] RuleSetVersion model in `services/kre-engine/src/models/ruleset.rs`
- [ ] T033 [P] ContentItem model in `services/ai-sommelier/src/models/content.py`
- [ ] T034 [P] DiscoveryQuery model in `services/ai-sommelier/src/models/query.py`
- [ ] T035 [P] MasteryTrack model in `services/user-context/internal/models/mastery.go`
- [ ] T036 [P] LayoutPerformance model in `services/genui-orchestrator/internal/models/performance.go`

## Phase 3.5: Core Services Implementation (T037-T050a)

### KRE Engine (Rules)
- [ ] T037 Rule evaluation engine in `services/kre-engine/src/engine/evaluator.rs`
- [ ] T038 Rule priority resolver in `services/kre-engine/src/engine/resolver.rs`
- [ ] T039 Rule conflict detection in `services/kre-engine/src/engine/conflicts.rs`

### GenUI Orchestrator (UI Assembly)
- [ ] T040 UI assembly pipeline in `services/genui-orchestrator/internal/assembly/pipeline.go`
- [ ] T041 Component selection logic in `services/genui-orchestrator/internal/assembly/selector.go`
- [ ] T042 Layout optimization engine in `services/genui-orchestrator/internal/assembly/optimizer.go`

### User Context Service
- [ ] T043 Context capture service in `services/user-context/internal/capture/collector.go`
- [ ] T044 PCM stage classifier integration in `services/user-context/internal/pcm/classifier.go`
- [ ] T045 Real-time context updates in `services/user-context/internal/realtime/updater.go`

### AI Sommelier (Discovery)
- [ ] T046 Natural language query processor in `services/ai-sommelier/src/nlp/processor.py`
- [ ] T047 Mood-based recommendation engine in `services/ai-sommelier/src/mood/recommender.py`
- [ ] T048 Content semantic search in `services/ai-sommelier/src/search/semantic.py`

### Supporting Services
- [ ] T049 [P] PCM classification service in `services/pcm-classifier/src/main.rs`
- [ ] T050 [P] Streaming adapter service in `services/streaming-adapter/src/main.rs`
- [ ] T050a Authentication service integration in `services/user-context/internal/auth/handler.go`

## Phase 3.6: Frontend KDS Components (T051-T060d)

### Atomic Components
- [ ] T051 [P] Button atom variations in `frontend/src/components/kds/atoms/button.tsx`
- [ ] T052 [P] Input atom with adaptive density in `frontend/src/components/kds/atoms/input.tsx`
- [ ] T053 [P] Card molecule with dynamic properties in `frontend/src/components/kds/molecules/card.tsx`

### Adaptive Components
- [ ] T054 [P] Hero banner component in `frontend/src/components/adaptive/hero-banner.tsx`
- [ ] T055 [P] Content grid with reranking in `frontend/src/components/adaptive/content-grid.tsx`
- [ ] T056 [P] Navigation with PCM adaptation in `frontend/src/components/adaptive/navigation.tsx`

### Organisms & Layouts
- [ ] T057 [P] Page layout orchestrator in `frontend/src/components/adaptive/page-layout.tsx`
- [ ] T058 [P] Dynamic sidebar component in `frontend/src/components/adaptive/sidebar.tsx`
- [ ] T059 [P] Search interface with AI Sommelier in `frontend/src/components/adaptive/search.tsx`
- [ ] T060 [P] Recommendation carousel in `frontend/src/components/adaptive/carousel.tsx`

### V-CRUNCH Social Features
- [ ] T060a [P] V-CRUNCH vertical feed in `frontend/src/components/social/v-crunch-feed.tsx`
- [ ] T060b [P] Social interaction buttons in `frontend/src/components/social/interaction-panel.tsx`
- [ ] T060c [P] Community comment system in `frontend/src/components/social/comments.tsx`
- [ ] T060d [P] Co-watching optimization UI in `frontend/src/components/social/co-watch.tsx`

## Phase 3.7: Integration Tests (T061-T068)

- [ ] T061 [P] Integration test: New User Onboarding in `frontend/tests/e2e/onboarding.spec.ts`
- [ ] T062 [P] Integration test: PCM Stage Adaptation in `frontend/tests/e2e/pcm-adaptation.spec.ts`
- [ ] T063 [P] Integration test: Cross-device sync in `frontend/tests/e2e/device-sync.spec.ts`
- [ ] T064 [P] Integration test: AI Sommelier Discovery in `frontend/tests/e2e/ai-discovery.spec.ts`
- [ ] T065 [P] Integration test: Dynamic Component Reranking in `frontend/tests/e2e/reranking.spec.ts`
- [ ] T066 [P] Integration test: Rule conflict resolution in `frontend/tests/e2e/rule-conflicts.spec.ts`
- [ ] T067 [P] Integration test: Context-aware adaptation in `frontend/tests/e2e/context-adaptation.spec.ts`
- [ ] T068 [P] Integration test: Social feature integration in `frontend/tests/e2e/social-features.spec.ts`

## Phase 3.8: RMI Designer Tool (T069-T072)

- [ ] T069 Rule designer interface in `rmi-designer/src/pages/rules/designer.tsx`
- [ ] T070 [P] Rule simulation playground in `rmi-designer/src/components/simulation/playground.tsx`
- [ ] T071 [P] Component property editor in `rmi-designer/src/components/editor/property-editor.tsx`
- [ ] T072 [P] Rule conflict visualizer in `rmi-designer/src/components/visualization/conflicts.tsx`

## Phase 3.9: Deployment & Operations (T073-T080)

- [ ] T073 Kubernetes manifests in `k8s/`
- [ ] T074 [P] CI/CD pipeline configuration in `.github/workflows/`
- [ ] T075 [P] Monitoring setup (Prometheus/Grafana) in `monitoring/`
- [ ] T076 [P] Logging configuration in `logging/`
- [ ] T077 Performance benchmarking suite in `benchmarks/`
- [ ] T078 [P] Health check endpoints across all services
- [ ] T079 [P] Load balancer configuration
- [ ] T080 Manual testing following quickstart.md scenarios

## Phase 3.10: Ecosystem Integration Features (T081-T098)

### Commerce Integration
- [ ] T081 Shop the Scene detection service in `services/ai-sommelier/src/commerce/scene_detector.py`
- [ ] T082 Merchandise matching engine in `services/ai-sommelier/src/commerce/product_matcher.py`
- [ ] T083 [P] Shop the Scene UI overlay in `frontend/src/components/commerce/shop-overlay.tsx`
- [ ] T084 [P] Commerce API client in `frontend/src/services/commerce-client.ts`

### Gaming Integration (Watch-to-Earn)
- [ ] T085 Watch tracking service in `services/user-context/internal/gaming/watch_tracker.go`
- [ ] T086 Reward calculation engine in `services/user-context/internal/gaming/rewards.go`
- [ ] T087 [P] Gaming integration UI in `frontend/src/components/gaming/rewards-panel.tsx`

### AR Visualization
- [ ] T088 [P] AR component for mobile in `frontend/src/components/ar/ar-viewer.tsx`
- [ ] T089 [P] 3D model loader service in `frontend/src/services/model-loader.ts`
- [ ] T090 [P] AR placement controls in `frontend/src/components/ar/placement-controls.tsx`

### Privacy & Compliance Features
- [ ] T091 Privacy settings UI in `frontend/src/components/privacy/settings-panel.tsx`
- [ ] T092 Data export service (GDPR) in `services/user-context/internal/privacy/data_export.go`
- [ ] T093 Data deletion service (GDPR) in `services/user-context/internal/privacy/data_deletion.go`
- [ ] T094 [P] Cookie consent banner in `frontend/src/components/privacy/cookie-consent.tsx`
- [ ] T095 [P] AI disclosure indicators in `frontend/src/components/ui/ai-indicator.tsx`
- [ ] T096 Age verification service (COPPA) in `services/user-context/internal/privacy/age_verify.go`
- [ ] T097 [P] Privacy policy display in `frontend/src/pages/privacy-policy.tsx`
- [ ] T098 Accessibility audit task for WCAG 2.1 AA compliance in `frontend/tests/a11y/`

## Dependencies

Key Dependencies:
- ALL contract tests (T016-T025) MUST be written and failing before implementation
- Integration tests require all components complete
- RMI Designer requires core services running
- Ecosystem features can start after core services (T037-T050)

## Validation Checklist
*GATE: Checked before execution*

- [x] All 2 contracts have corresponding test tasks (T016-T025)
- [x] All 11 entities have model tasks (T026-T036)
- [x] Total 98 tasks for comprehensive core platform coverage
- [x] Authentication covered in T050a
- [x] All tests come before implementation (Phase 3.3 before 3.5)
- [x] Parallel tasks are truly independent (different files)
- [x] Each task specifies exact file path
- [x] V-CRUNCH social features included (T060a-T060d)
- [x] Commerce integration included (T081-T084)
- [x] Gaming integration included (T085-T087)
- [x] AR features included (T088-T090)
- [x] Privacy & compliance features included (T091-T098)
- [x] Vector database setup included (T010a)