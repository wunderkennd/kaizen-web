#!/bin/bash

# Script to create GitHub milestones for the KAIZEN platform
echo "Creating GitHub Milestones for KAIZEN Platform..."

# Milestone 1: MVP Foundation
echo "Creating Milestone 1: MVP Foundation..."
gh api repos/wunderkennd/kaizen-web/milestones \
  --method POST \
  -f title="M1: MVP Foundation" \
  -f description="Basic infrastructure and service scaffolding with Cloud Run deployment. Includes: Cloud Run setup (T183-T190), Docker configs (T176), Basic CI/CD (T175, T188), Database setup (T011-T015, T167-T168)" \
  -f due_on="2025-11-18T23:59:59Z" \
  -f state="open" \
  2>/dev/null && echo "✓ Created M1: MVP Foundation" || echo "⚠ M1 may already exist"

# Milestone 2: Core Platform
echo "Creating Milestone 2: Core Platform..."
gh api repos/wunderkennd/kaizen-web/milestones \
  --method POST \
  -f title="M2: Core Platform" \
  -f description="Functional adaptive UI generation with rule engine. Includes: Data Models (T026-T036), Rule Engine (T035-T037), GenUI Orchestrator (T038-T042), Basic Frontend (T051-T054)" \
  -f due_on="2025-12-30T23:59:59Z" \
  -f state="open" \
  2>/dev/null && echo "✓ Created M2: Core Platform" || echo "⚠ M2 may already exist"

# Milestone 3: User Experience
echo "Creating Milestone 3: User Experience..."
gh api repos/wunderkennd/kaizen-web/milestones \
  --method POST \
  -f title="M3: User Experience" \
  -f description="Complete frontend with adaptive features and PCM integration. Includes: Templates (T055-T057), Integration Tests (T058-T062), User Context (T043-T045), AI Sommelier (T046-T048)" \
  -f due_on="2026-01-27T23:59:59Z" \
  -f state="open" \
  2>/dev/null && echo "✓ Created M3: User Experience" || echo "⚠ M3 may already exist"

# Milestone 4: Production Ready
echo "Creating Milestone 4: Production Ready..."
gh api repos/wunderkennd/kaizen-web/milestones \
  --method POST \
  -f title="M4: Production Ready" \
  -f description="Production deployment with full monitoring and security. Includes: Monitoring (T180, T189), Security (T178), Documentation (T073-T075), Progressive Delivery (T179)" \
  -f due_on="2026-02-24T23:59:59Z" \
  -f state="open" \
  2>/dev/null && echo "✓ Created M4: Production Ready" || echo "⚠ M4 may already exist"

# Milestone 5: Experimentation Platform
echo "Creating Milestone 5: Experimentation Platform..."
gh api repos/wunderkennd/kaizen-web/milestones \
  --method POST \
  -f title="M5: Experimentation Platform" \
  -f description="A/B testing and ML optimization capabilities. Includes: A/B Testing (T099-T110), Experiment UI (T105, T107), Basic MAB (T123-T130)" \
  -f due_on="2026-04-07T23:59:59Z" \
  -f state="open" \
  2>/dev/null && echo "✓ Created M5: Experimentation Platform" || echo "⚠ M5 may already exist"

echo ""
echo "========================================="
echo "GitHub Milestones Created!"
echo ""
echo "5 Milestones:"
echo "1. M1: MVP Foundation (Due: 4 weeks)"
echo "2. M2: Core Platform (Due: 10 weeks)"
echo "3. M3: User Experience (Due: 14 weeks)"
echo "4. M4: Production Ready (Due: 18 weeks)"
echo "5. M5: Experimentation Platform (Due: 24 weeks)"
echo ""
echo "Next: Run assign-issues-to-milestones.sh"
echo "========================================="