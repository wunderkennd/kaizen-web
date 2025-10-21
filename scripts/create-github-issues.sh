#!/bin/bash

# Script to create GitHub issues for all KAIZEN platform tasks
# These can then be imported into a GitHub Project for tracking

echo "Creating GitHub issues for KAIZEN Platform tasks..."

# Function to create issues from tasks
create_issues_from_spec() {
    local spec_name=$1
    local spec_path=$2
    local label=$3
    local milestone=$4
    
    echo "Processing $spec_name..."
    
    # Extract tasks and create issues
    while IFS= read -r line; do
        if [[ $line =~ ^-\ \[\ \]\ (T[0-9]+[a-z]?)\ (\[P\]\ )?(.+)\ in\ \`(.+)\`$ ]]; then
            task_id="${BASH_REMATCH[1]}"
            is_parallel="${BASH_REMATCH[2]}"
            description="${BASH_REMATCH[3]}"
            file_path="${BASH_REMATCH[4]}"
            
            # Determine if task is parallel
            if [[ -n "$is_parallel" ]]; then
                parallel_label="parallel"
            else
                parallel_label=""
            fi
            
            # Create title
            title="[$task_id] $description"
            
            # Create body
            body="## Task: $task_id

**Description**: $description
**File Path**: \`$file_path\`
**Specification**: $spec_name
**Can Run in Parallel**: ${is_parallel:-No}

### Acceptance Criteria
- [ ] Implementation complete
- [ ] Unit tests passing
- [ ] Contract tests passing (if applicable)
- [ ] Code reviewed
- [ ] Documentation updated

### Dependencies
Check tasks.md for specific dependencies

### Labels
- $label
${parallel_label:+- $parallel_label}"

            # Create the issue
            echo "Creating issue: $title"
            gh issue create \
                --title "$title" \
                --body "$body" \
                --label "$label" \
                ${parallel_label:+--label "$parallel_label"} \
                ${milestone:+--milestone "$milestone"} \
                2>/dev/null || echo "  Failed to create issue $task_id (may already exist)"
        fi
    done < "$spec_path"
}

# Check if gh CLI is authenticated properly
if ! gh auth status >/dev/null 2>&1; then
    echo "Error: GitHub CLI not authenticated. Run 'gh auth login' first."
    exit 1
fi

# Create labels if they don't exist
echo "Creating labels..."
gh label create "001-adaptive-platform" --description "Core adaptive platform tasks" --color "0052CC" 2>/dev/null
gh label create "002-ab-testing" --description "A/B testing infrastructure tasks" --color "00875A" 2>/dev/null
gh label create "003-multivariate" --description "Multivariate experimentation tasks" --color "5319E7" 2>/dev/null
gh label create "parallel" --description "Can be executed in parallel" --color "FBCA04" 2>/dev/null
gh label create "blocked" --description "Blocked by dependencies" --color "D93F0B" 2>/dev/null
gh label create "in-progress" --description "Currently being worked on" --color "0E8A16" 2>/dev/null

# Create milestones
echo "Creating milestones..."
gh api repos/:owner/:repo/milestones \
    --method POST \
    --field title="Phase 1: Core Platform" \
    --field description="Core adaptive platform implementation (T001-T098)" \
    --field due_on="2025-02-01T00:00:00Z" 2>/dev/null

gh api repos/:owner/:repo/milestones \
    --method POST \
    --field title="Phase 2: A/B Testing" \
    --field description="A/B testing infrastructure (T105-T122)" \
    --field due_on="2025-03-01T00:00:00Z" 2>/dev/null

gh api repos/:owner/:repo/milestones \
    --method POST \
    --field title="Phase 3: Advanced Experimentation" \
    --field description="Multivariate and ML optimization (T123-T164)" \
    --field due_on="2025-04-01T00:00:00Z" 2>/dev/null

# Process each specification
create_issues_from_spec \
    "001-adaptive-platform" \
    "specs/001-adaptive-platform/tasks.md" \
    "001-adaptive-platform" \
    "Phase 1: Core Platform"

create_issues_from_spec \
    "002-ab-testing" \
    "specs/002-ab-testing/tasks.md" \
    "002-ab-testing" \
    "Phase 2: A/B Testing"

create_issues_from_spec \
    "003-multivariate-experiments" \
    "specs/003-multivariate-experiments/tasks.md" \
    "003-multivariate" \
    "Phase 3: Advanced Experimentation"

echo "Issue creation complete!"
echo ""
echo "Next steps:"
echo "1. Go to https://github.com/users/$(gh api user --jq .login)/projects/new"
echo "2. Create a new project called 'KAIZEN Adaptive Platform'"
echo "3. Add repository and select all issues with labels: 001-adaptive-platform, 002-ab-testing, 003-multivariate"
echo "4. Set up project views:"
echo "   - Board view: Group by Milestone, Status columns (To Do, In Progress, Done)"
echo "   - Table view: All tasks with filters for labels and assignees"
echo "   - Gantt view: Timeline by milestone"
echo ""
echo "You can also use GitHub Projects automation:"
echo "- Auto-add issues with specific labels"
echo "- Auto-move to 'In Progress' when assigned"
echo "- Auto-move to 'Done' when issue closed"