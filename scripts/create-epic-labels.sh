#!/bin/bash

# Script to create epic labels for issue organization
echo "Creating Epic Labels for GitHub Issues..."

# Epic labels with colors
declare -A EPICS=(
  ["epic:foundation"]="0052cc:Foundation & Infrastructure"
  ["epic:data-layer"]="5319e7:Data Layer & Models"
  ["epic:core-services"]="b60205:Core Services Implementation"
  ["epic:frontend"]="f9d0c4:Frontend & UI Components"
  ["epic:testing"]="1d76db:Testing & Quality Assurance"
  ["epic:cicd"]="006b75:CI/CD & DevOps"
  ["epic:operations"]="fbca04:Platform Operations"
  ["epic:experimentation"]="c5def5:Experimentation Platform"
)

# Priority labels
declare -A PRIORITIES=(
  ["P0-critical"]="d73a4a:Critical - Must Have"
  ["P1-high"]="e99695:High Priority"
  ["P2-medium"]="fef2c0:Medium Priority"
  ["P3-low"]="c2e0c6:Low Priority"
)

# Size labels
declare -A SIZES=(
  ["size:XS"]="ffffff:1-2 story points"
  ["size:S"]="c2e0c6:3-5 story points"
  ["size:M"]="fef2c0:5-8 story points"
  ["size:L"]="f9d0c4:8-13 story points"
  ["size:XL"]="e99695:13+ story points"
)

# Status labels
declare -A STATUSES=(
  ["status:blocked"]="d73a4a:Blocked by dependencies"
  ["status:ready"]="0e8a16:Ready to start"
  ["status:in-progress"]="1d76db:Currently being worked on"
  ["status:review"]="5319e7:In review"
  ["status:done"]="6f42c1:Completed"
)

# Create epic labels
echo "Creating Epic labels..."
for label in "${!EPICS[@]}"; do
  IFS=':' read -r color description <<< "${EPICS[$label]}"
  gh label create "$label" --description "$description" --color "$color" --force 2>/dev/null && \
    echo "✓ Created label: $label" || echo "⚠ Label exists: $label"
done

# Create priority labels
echo ""
echo "Creating Priority labels..."
for label in "${!PRIORITIES[@]}"; do
  IFS=':' read -r color description <<< "${PRIORITIES[$label]}"
  gh label create "$label" --description "$description" --color "$color" --force 2>/dev/null && \
    echo "✓ Created label: $label" || echo "⚠ Label exists: $label"
done

# Create size labels
echo ""
echo "Creating Size labels..."
for label in "${!SIZES[@]}"; do
  IFS=':' read -r color description <<< "${SIZES[$label]}"
  gh label create "$label" --description "$description" --color "$color" --force 2>/dev/null && \
    echo "✓ Created label: $label" || echo "⚠ Label exists: $label"
done

# Create status labels
echo ""
echo "Creating Status labels..."
for label in "${!STATUSES[@]}"; do
  IFS=':' read -r color description <<< "${STATUSES[$label]}"
  gh label create "$label" --description "$description" --color "$color" --force 2>/dev/null && \
    echo "✓ Created label: $label" || echo "⚠ Label exists: $label"
done

# Create additional useful labels
echo ""
echo "Creating Additional labels..."
gh label create "cloud-run" --description "Cloud Run related" --color "0366d6" --force 2>/dev/null
gh label create "terraform" --description "Infrastructure as Code" --color "7e3d9f" --force 2>/dev/null
gh label create "migration" --description "Migration task" --color "ff9800" --force 2>/dev/null
gh label create "documentation" --description "Documentation needed" --color "0075ca" --force 2>/dev/null
gh label create "security" --description "Security related" --color "d73a4a" --force 2>/dev/null
gh label create "performance" --description "Performance optimization" --color "a2eeef" --force 2>/dev/null
gh label create "tech-debt" --description "Technical debt" --color "ffd700" --force 2>/dev/null
gh label create "quick-win" --description "Can be done quickly" --color "7fe830" --force 2>/dev/null

echo ""
echo "========================================="
echo "GitHub Labels Created!"
echo ""
echo "Label Categories:"
echo "- 8 Epic labels (epic:*)"
echo "- 4 Priority labels (P0-P3)"
echo "- 5 Size labels (size:XS-XL)"
echo "- 5 Status labels (status:*)"
echo "- 8 Additional labels"
echo ""
echo "Total: 30 labels created"
echo "========================================="