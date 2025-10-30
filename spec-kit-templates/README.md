# Spec-Kit Templates

## 🎯 Complete GitHub Project Setup Toolkit

Transform any specification into a fully organized GitHub project with issues, epics, milestones, and labels.

---

## 📁 Template Structure

```
spec-kit-templates/
├── README.md                    # This file
├── 01-specification/           # Spec templates
│   ├── spec-template.md
│   ├── tasks-template.md
│   └── data-model-template.md
├── 02-extraction/             # Task extraction scripts
│   ├── extract-tasks.sh
│   └── parse-dependencies.sh
├── 03-github-setup/           # GitHub automation
│   ├── create-labels.sh
│   ├── create-milestones.sh
│   ├── create-issues.sh
│   └── enrich-issues.sh
├── 04-organization/           # Epic and milestone mapping
│   ├── epics.yaml
│   ├── milestones.yaml
│   └── assign-to-epics.sh
├── 05-reporting/              # Progress tracking
│   ├── generate-roadmap.sh
│   ├── epic-progress.sh
│   └── weekly-status.sh
└── setup.sh                   # Master orchestration script
```

---

## 🚀 Quick Start

### Step 1: Setup and Validation
```bash
# Copy the spec-kit templates to your project
cp -r spec-kit-templates/ your-project/
cd your-project/spec-kit-templates/

# Validate the setup
./validate-setup.sh

# Fix any issues found in validation
```

### Step 2: Configure Your Project
```bash
# Create your configuration file
cp config.example.sh config.sh

# Edit config.sh with your project details
nano config.sh

# Required settings:
export GITHUB_OWNER="your-username"
export GITHUB_REPO="your-repo"
export PROJECT_NAME="Your Project Name"
```

### Step 3: Authenticate with GitHub
```bash
# Install GitHub CLI if not already installed
# macOS: brew install gh
# Linux: https://cli.github.com/manual/installation

# Authenticate with GitHub
gh auth login

# Verify authentication
gh auth status
```

### Step 4: Write Your Specification
```bash
# Create specs directory
mkdir -p ../specs/001-main

# Use the templates to create your spec
cp 01-specification/spec-template.md ../specs/001-main/spec.md
cp 01-specification/tasks-template.md ../specs/001-main/tasks.md
cp 01-specification/data-model-template.md ../specs/001-main/data-model.md

# Edit with your project details
nano ../specs/001-main/tasks.md
```

### Step 5: Run the Complete Setup
```bash
# Run the automated setup (recommended)
./setup.sh

# This will:
# 1. Validate your setup
# 2. Extract tasks from specifications
# 3. Create GitHub labels
# 4. Create milestones  
# 5. Create GitHub issues
# 6. Enrich issues with context
# 7. Assign issues to epics
# 8. Assign issues to milestones
# 9. Generate documentation
```

### Alternative: Run Individual Components
```bash
# Extract tasks from specifications
./02-extraction/extract-tasks.sh

# Parse task dependencies
./02-extraction/parse-dependencies.sh

# Create GitHub structure
./03-github-setup/create-labels.sh
./03-github-setup/create-milestones.sh
./03-github-setup/create-issues.sh
./03-github-setup/enrich-issues.sh

# Organize work
./04-organization/assign-to-epics.sh
./04-organization/assign-to-milestones.sh

# Generate reports
./05-reporting/generate-roadmap.sh
./05-reporting/epic-progress.sh
./05-reporting/weekly-status.sh
```

---

## 📝 Task Format

Tasks should follow this format in your `tasks.md`:

```markdown
### T001: Initialize repository structure
**Component**: Infrastructure
**Dependencies**: None
**Effort**: 3 story points
**Priority**: P0
**Epic**: foundation

### T002: Setup Docker containers
**Component**: Infrastructure  
**Dependencies**: T001
**Effort**: 5 story points
**Priority**: P0
**Epic**: foundation
```

---

## 🏷️ Label System

The toolkit creates these label categories:

### Epic Labels
- `epic:foundation` - Infrastructure and setup
- `epic:data-layer` - Database and models
- `epic:core-services` - Business logic
- `epic:frontend` - UI components
- `epic:testing` - QA and testing
- `epic:cicd` - Automation
- `epic:operations` - Production ops
- `epic:experimentation` - A/B testing

### Priority Labels
- `P0-critical` - Must have
- `P1-high` - Should have
- `P2-medium` - Nice to have
- `P3-low` - Future consideration

### Size Labels  
- `size:XS` - 1-2 points
- `size:S` - 3-5 points
- `size:M` - 5-8 points
- `size:L` - 8-13 points
- `size:XL` - 13+ points

---

## 📅 Milestone Structure

Default milestone template (customizable):

1. **M1: Foundation** (Week 4)
   - Infrastructure setup
   - Development environment
   - Basic CI/CD

2. **M2: Core Features** (Week 10)
   - Core business logic
   - Data models
   - Basic UI

3. **M3: User Experience** (Week 14)
   - Complete UI
   - User flows
   - Testing

4. **M4: Production** (Week 18)
   - Deployment
   - Monitoring
   - Documentation

5. **M5: Enhancement** (Week 24)
   - Advanced features
   - Optimization
   - Experimentation

---

## 🔧 Customization

### Custom Epics
Edit `04-organization/epics.yaml`:
```yaml
custom_epics:
  - id: security
    name: "Security & Compliance"
    color: "d73a4a"
    task_pattern: "T200-T220"
```

### Custom Labels
Add to `03-github-setup/create-labels.sh`:
```bash
gh label create "needs-design" --color "7057ff"
gh label create "tech-debt" --color "ffd700"
```

### Custom Milestones
Edit `04-organization/milestones.yaml`:
```yaml
milestones:
  - title: "Beta Release"
    weeks_from_start: 12
    description: "Public beta launch"
```

---

## 📊 Reports

Generate various reports:

```bash
# Epic progress
./05-reporting/epic-progress.sh

# Milestone burndown
./05-reporting/burndown.sh

# Weekly status
./05-reporting/weekly-status.sh

# Full roadmap
./05-reporting/generate-roadmap.sh > docs/roadmap.md
```

---

## 🤖 Automation

### GitHub Actions Integration
```yaml
# .github/workflows/sync-tasks.yml
name: Sync Tasks from Spec
on:
  push:
    paths:
      - 'specs/**/tasks.md'
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Sync new tasks
        run: |
          ./spec-kit-templates/02-extraction/extract-tasks.sh
          ./spec-kit-templates/03-github-setup/create-issues.sh --new-only
```

---

## 💡 Best Practices

1. **Number tasks sequentially**: T001, T002, etc.
2. **Group by tens**: 
   - T001-T010: Infrastructure
   - T011-T020: Database
   - T021-T030: API
3. **Size consistently**: Use Fibonacci sequence
4. **Update weekly**: Sync spec changes regularly
5. **Review quarterly**: Adjust epics and milestones

---

## 📈 Success Metrics

Track these KPIs:
- Epic completion rate
- Milestone on-time delivery
- Issue cycle time
- Team velocity (points/sprint)
- Bug escape rate

---

## 🆘 Troubleshooting

### Common Issues

**Issue**: "Label already exists"
```bash
# Force update existing labels
./03-github-setup/create-labels.sh --force
```

**Issue**: "Too many API requests"
```bash
# Add delay between requests
export GITHUB_API_DELAY=2  # seconds
./setup.sh
```

**Issue**: "Permission denied"
```bash
# Check GitHub token permissions
gh auth status
gh auth refresh -s project,repo,write:org
```

---

## 📚 Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [GitHub Projects Guide](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Agile Epic Management](https://www.atlassian.com/agile/project-management/epics)

---

## 🤝 Contributing

Improvements welcome! Please:
1. Fork this repository
2. Create a feature branch
3. Submit a pull request

---

## 📜 License

MIT License - Use freely in your projects

---

*Spec-Kit Templates - From specification to production-ready GitHub project*