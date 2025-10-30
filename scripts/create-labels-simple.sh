#!/bin/bash

# Simplified script to create GitHub labels
echo "Creating GitHub Labels..."

# Epic labels
echo "Creating Epic labels..."
gh label create "epic:foundation" --description "Foundation & Infrastructure" --color "0052cc" --force 2>/dev/null || echo "Label exists"
gh label create "epic:data-layer" --description "Data Layer & Models" --color "5319e7" --force 2>/dev/null || echo "Label exists"
gh label create "epic:core-services" --description "Core Services Implementation" --color "b60205" --force 2>/dev/null || echo "Label exists"
gh label create "epic:frontend" --description "Frontend & UI Components" --color "f9d0c4" --force 2>/dev/null || echo "Label exists"
gh label create "epic:testing" --description "Testing & QA" --color "1d76db" --force 2>/dev/null || echo "Label exists"
gh label create "epic:cicd" --description "CI/CD & DevOps" --color "006b75" --force 2>/dev/null || echo "Label exists"
gh label create "epic:operations" --description "Platform Operations" --color "fbca04" --force 2>/dev/null || echo "Label exists"
gh label create "epic:experimentation" --description "Experimentation Platform" --color "c5def5" --force 2>/dev/null || echo "Label exists"
echo "✓ Epic labels created"

# Priority labels
echo "Creating Priority labels..."
gh label create "P0-critical" --description "Critical Priority" --color "d73a4a" --force 2>/dev/null || echo "Label exists"
gh label create "P1-high" --description "High Priority" --color "e99695" --force 2>/dev/null || echo "Label exists"
gh label create "P2-medium" --description "Medium Priority" --color "fef2c0" --force 2>/dev/null || echo "Label exists"
gh label create "P3-low" --description "Low Priority" --color "c2e0c6" --force 2>/dev/null || echo "Label exists"
echo "✓ Priority labels created"

# Size labels
echo "Creating Size labels..."
gh label create "size:XS" --description "1-2 story points" --color "ffffff" --force 2>/dev/null || echo "Label exists"
gh label create "size:S" --description "3-5 story points" --color "c2e0c6" --force 2>/dev/null || echo "Label exists"
gh label create "size:M" --description "5-8 story points" --color "fef2c0" --force 2>/dev/null || echo "Label exists"
gh label create "size:L" --description "8-13 story points" --color "f9d0c4" --force 2>/dev/null || echo "Label exists"
gh label create "size:XL" --description "13+ story points" --color "e99695" --force 2>/dev/null || echo "Label exists"
echo "✓ Size labels created"

echo ""
echo "========================================="
echo "Labels Created Successfully!"
echo "========================================="