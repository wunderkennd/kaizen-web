# 🤖 Sub-Agent Creation System

## Overview

The Sub-Agent Creation System allows you to define and deploy specialized AI agents tailored to your project's specific needs. Each agent is configured with specific capabilities, task assignments, and collaboration patterns.

## Features

- **Intelligent Project Analysis**: Automatically analyzes your project to recommend appropriate agents
- **Interactive Approval Process**: Review and approve each agent before creation
- **Custom Configuration**: Each agent gets a tailored configuration file
- **Task Assignment**: Automatically assigns tasks to agents based on keywords and epics
- **Collaboration Patterns**: Defines how agents work together
- **Performance Tracking**: Built-in metrics and dashboard

## Quick Start

```bash
# Navigate to the agents directory
cd spec-kit-templates/06-agents/

# Run the agent creation wizard
./create-agents.sh

# Follow the interactive prompts to:
# 1. Review project analysis
# 2. Approve recommended agents
# 3. Select additional agents if needed
# 4. Generate configurations
```

## Available Agents

### Core Development

1. **Backend Development Specialist**
   - API development (REST/GraphQL/gRPC)
   - Database operations
   - Business logic implementation
   - Data modeling

2. **Frontend Development Specialist**
   - UI/UX implementation
   - React/Next.js components
   - State management
   - Responsive design

3. **DevOps & Infrastructure Engineer**
   - Terraform configurations
   - CI/CD pipelines
   - Cloud service setup
   - Monitoring and logging

### Quality & Testing

4. **Testing & QA Specialist**
   - Unit and integration tests
   - E2E test suites
   - TDD implementation
   - Coverage reporting

5. **Security & Compliance Specialist**
   - Authentication/authorization
   - Security audits
   - Compliance standards
   - Vulnerability scanning

### Data & Analytics

6. **Data & Analytics Engineer**
   - Data pipeline design
   - ETL/ELT processes
   - ML model deployment
   - Analytics dashboards

### Support & Operations

7. **Documentation Specialist**
   - Technical documentation
   - API documentation
   - User guides
   - Architecture diagrams

8. **Performance Optimization Engineer**
   - Performance profiling
   - Query optimization
   - Caching strategies
   - Load balancing

### Specialized Roles

9. **Migration & Modernization Specialist**
   - Legacy system migrations
   - Technology upgrades
   - Refactoring strategies
   - Compatibility layers

10. **Integration & API Specialist**
    - Third-party integrations
    - Webhook handlers
    - API gateway management
    - Event streaming

## Agent Selection Process

### Automatic Recommendations

The system analyzes your project for:
- Technology stack (backend, frontend, database)
- Architecture patterns (microservices, monolith)
- Infrastructure needs (cloud, on-premise)
- Special requirements (ML, security, legacy)

### Interactive Approval

For each recommended agent:
1. **Review** agent capabilities and assigned tasks
2. **Approve** (y), **Skip** (n), or get **Details** (d)
3. **Configure** agent settings if approved
4. **Assign** tasks based on epics and keywords

### Manual Selection

After reviewing recommendations, you can:
- Add additional specialized agents
- Remove agents that aren't needed
- Customize agent configurations

## Configuration Files

Each approved agent gets:

### `agent-config-{agent-id}.yaml`
```yaml
agent:
  id: backend-specialist
  name: Backend Development Specialist
  created: 2024-01-20
  project: KAIZEN Platform
  
settings:
  auto_assign_tasks: true
  priority_level: normal
  max_concurrent_tasks: 3
  
capabilities:
  - API development
  - Database design
  - Business logic
  
assigned_epics:
  - epic:data-layer
  - epic:core-services
  
task_filters:
  labels:
    - backend
    - api
    - database
  keywords:
    - API
    - service
    - database
```

## Generated Outputs

### 1. Agent Configurations
Individual YAML files for each agent with:
- Capabilities and skills
- Epic assignments
- Task filtering rules
- Performance metrics
- Collaboration settings

### 2. Task Assignments
`agent-task-assignments.md` containing:
- Agent-to-epic mapping
- Task keywords for auto-assignment
- Collaboration patterns
- Workload distribution

### 3. Agent Dashboard
`agent-dashboard.md` featuring:
- Active agent overview
- Collaboration matrix
- Performance metrics
- Quick action links

## Collaboration Patterns

Agents work together in defined patterns:

### API Development Pattern
- Backend Specialist (lead)
- Documentation Specialist (API docs)
- Testing Specialist (contract tests)

### Full-Stack Feature Pattern
- Backend Specialist (APIs)
- Frontend Specialist (UI)
- Testing Specialist (E2E tests)

### Infrastructure Setup Pattern
- DevOps Engineer (infrastructure)
- Security Specialist (security config)
- Performance Engineer (optimization)

## Best Practices

### Agent Selection
- Start with core agents (backend, frontend, devops)
- Add specialized agents as needed
- Consider project size and complexity
- Balance specialization with overhead

### Task Assignment
- Use clear, descriptive task titles
- Include relevant keywords for auto-assignment
- Group related tasks under epics
- Define dependencies explicitly

### Performance Monitoring
- Review agent metrics weekly
- Adjust task assignments based on velocity
- Monitor collaboration effectiveness
- Update configurations as needed

## Integration with Spec-Kit

The agent system integrates seamlessly with the spec-kit workflow:

1. **After Phase 5** (Issue Enhancement)
2. **Before Phase 6** (Automation Pipeline)
3. Agents are assigned to created issues
4. Task filtering based on epics and labels
5. Automatic workload distribution

## Advanced Configuration

### Custom Agent Definition

Add new agents to `agent-definitions.yaml`:

```yaml
agents:
  - id: custom-specialist
    name: "Custom Specialist"
    description: "Specialized role description"
    capabilities:
      - "Custom capability 1"
      - "Custom capability 2"
    recommended_for:
      - "Specific use cases"
    tools_required:
      - "Required tools"
    epic_associations:
      - "relevant-epic"
```

### Auto-Recommendation Rules

Modify `selection_rules` in `agent-definitions.yaml`:

```yaml
selection_rules:
  auto_recommendations:
    - condition: "has_custom_requirement"
      recommend: ["custom-specialist", "related-specialist"]
```

## Troubleshooting

### No Agents Recommended
- Check if specs/001-main/tasks.md exists
- Ensure task descriptions include technology keywords
- Run with verbose mode: `./create-agents.sh -v`

### Agent Not Assigning Tasks
- Verify epic labels match configuration
- Check task keywords in descriptions
- Review task_filters in agent config

### Configuration Errors
- Validate YAML syntax
- Ensure all required fields present
- Check file permissions

## Metrics & Monitoring

Track agent effectiveness with:

- **Task Completion Rate**: Tasks completed per week
- **Quality Score**: Tests passing, bugs found
- **Collaboration Score**: Cross-agent task success
- **Velocity Trend**: Story points over time

## Future Enhancements

Planned improvements:
- [ ] Auto-scaling agents based on workload
- [ ] ML-based task assignment optimization
- [ ] Real-time collaboration features
- [ ] Integration with IDE plugins
- [ ] Natural language agent instructions

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review agent configurations
3. Consult the main spec-kit documentation
4. Submit issues to the repository

---

*The Sub-Agent Creation System - Specialized AI assistance for every aspect of your project*