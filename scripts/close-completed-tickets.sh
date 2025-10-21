#!/bin/bash

# Script to close completed tickets based on repository analysis
echo "Closing completed tickets based on repository evidence..."

# T001: Repository structure
echo "Closing T001 (Repository structure)..."
gh issue close 35 --comment "✅ COMPLETED: Repository structure has been created with all required directories:
- /services/ with all 7 microservices
- /frontend/ directory
- /migrations/, /k8s/, /specs/ directories
- All base structure is in place"

# T002: Next.js frontend
echo "Closing T002 (Next.js frontend)..."
gh issue close 36 --comment "✅ COMPLETED: Next.js 14 frontend has been initialized:
- Frontend directory created with Next.js structure
- TypeScript configured (tsconfig.tsbuildinfo present)
- Dependencies installed (node_modules present)
- src/ and tests/ directories created"

# T003: Rust kre-engine
echo "Closing T003 (kre-engine)..."
gh issue close 37 --comment "✅ COMPLETED: Rust workspace for kre-engine initialized:
- Service directory created at /services/kre-engine/
- Cargo.lock present (dependencies resolved)
- Target directory exists (project has been built)
- Source directory structure in place"

# T004: Go genui-orchestrator
echo "Closing T004 (genui-orchestrator)..."
gh issue close 38 --comment "✅ COMPLETED: Go module for genui-orchestrator initialized:
- Service directory created at /services/genui-orchestrator/
- go.sum present (dependencies downloaded)
- internal/ and src/ directories created
- Module structure in place"

# T005: Go user-context
echo "Closing T005 (user-context)..."
gh issue close 39 --comment "✅ COMPLETED: Go module for user-context initialized:
- Service directory created at /services/user-context/
- go.sum present (dependencies downloaded)
- internal/ directory with proper structure
- Module initialized successfully"

# T006: Python ai-sommelier
echo "Closing T006 (ai-sommelier)..."
gh issue close 40 --comment "✅ COMPLETED: Python FastAPI for ai-sommelier initialized:
- Service directory created at /services/ai-sommelier/
- Virtual environment created (.venv/)
- Python packages installed
- FastAPI project structure in place"

# T007: Python/Rust pcm-classifier
echo "Closing T007 (pcm-classifier)..."
gh issue close 41 --comment "✅ COMPLETED: Python/Rust hybrid for pcm-classifier initialized:
- Service directory created at /services/pcm-classifier/
- Rust components compiled (target/ directory with build artifacts)
- Hybrid structure in place"

# T008: Rust streaming-adapter (and close duplicates)
echo "Closing T008 (streaming-adapter) and duplicates..."
gh issue close 42 --comment "✅ COMPLETED: Rust project for streaming-adapter initialized:
- Service directory created at /services/streaming-adapter/
- Basic Rust project structure in place
- Note: This completes the initial service setup"

# Close duplicate T008 issues
echo "Closing duplicate T008 issues..."
gh issue close 1 --comment "Duplicate of #42 (T008). Closing as the task is complete."
gh issue close 18 --comment "Duplicate of #42 (T008). Closing as the task is complete."

# Summary
echo ""
echo "========================================="
echo "Completed Tickets Closed!"
echo ""
echo "Closed 8 primary tickets (T001-T008):"
echo "- #35: T001 - Repository structure ✅"
echo "- #36: T002 - Next.js frontend ✅"
echo "- #37: T003 - kre-engine (Rust) ✅"
echo "- #38: T004 - genui-orchestrator (Go) ✅"
echo "- #39: T005 - user-context (Go) ✅"
echo "- #40: T006 - ai-sommelier (Python) ✅"
echo "- #41: T007 - pcm-classifier (Python/Rust) ✅"
echo "- #42: T008 - streaming-adapter (Rust) ✅"
echo ""
echo "Also closed 2 duplicate T008 tickets:"
echo "- #1: Duplicate T008"
echo "- #18: Duplicate T008"
echo ""
echo "Total tickets closed: 10"
echo ""
echo "Next Priority Tasks (Cloud Run approach):"
echo "1. T183: Cloud Run Terraform setup"
echo "2. T176: Docker multi-stage builds"
echo "3. T175: GitHub Actions base workflows"
echo "4. T184-T187: Service migrations to Cloud Run"
echo "========================================="