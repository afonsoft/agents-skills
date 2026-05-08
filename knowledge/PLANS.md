# Planning Templates

This document contains planning templates and methodologies for the agents-skills repository.

## Plan Types

### Implementation Plans

For new features, refactoring, upgrades, architecture changes, or infrastructure work.

**Template Structure:**
```markdown
---
goal: [Concise Title]
version: [version]
date_created: [YYYY-MM-DD]
last_updated: [Optional: YYYY-MM-DD]
owner: [Optional: Team/Individual]
status: 'Completed'|'In progress'|'Planned'|'Deprecated'|'On Hold'
tags: [feature, upgrade, chore, architecture, migration, bug]
---

# Introduction

## 1. Requirements & Constraints
- **REQ-001**: Requirement
- **SEC-001**: Security Requirement
- **CON-001**: Constraint
- **GUD-001**: Guideline
- **PAT-001**: Pattern to follow

## 2. Implementation Steps
### Phase 1
- GOAL-001: [Phase goal]
| Task | Description | Completed | Date |

## 3. Alternatives
## 4. Dependencies
## 5. Files
## 6. Testing
## 7. Risks & Assumptions
## 8. Related Specifications
```

**Storage:** `knowledge/exec-plans/active/` for ongoing plans, `knowledge/exec-plans/completed/` for finished plans.

### Architectural Decision Records (ADRs)

For significant architectural decisions.

**Template Structure:**
```markdown
# ADR-[Number]: [Title]

## Status
Accepted | Superseded by [ADR-number] | Deprecated

## Context
[Problem description and context]

## Decision
[Decision made]

## Consequences
[Positive and negative consequences]
```

### Quick Plans

For small changes that don't need full implementation plans.

**Template Structure:**
```markdown
# Quick Plan: [Title]

## Goal
[Brief description]

## Tasks
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Notes
[Any relevant notes]
```

## Planning Methodology

### Progressive Planning

1. **Start Small**: Begin with quick plan for exploration
2. **Escalate as Needed**: Move to full implementation plan for complex work
3. **Version Control**: All plans are versioned in repository
4. **Track Progress**: Update status and completion dates
5. **Archive Completed**: Move to exec-plans/completed/ when done

### Plan Quality Criteria

- **Specific**: Clear, unambiguous tasks
- **Measurable**: Completion criteria for each task
- **Atomic**: Tasks can be completed independently
- **Prioritized**: Critical path identified
- **Time-Bound**: Estimated completion dates

## Technical Debt Tracking

Track technical debt in `knowledge/exec-plans/tech-debt-tracker.md`.

**Template:**
```markdown
# Technical Debt Tracker

| ID | Area | Description | Severity | Estimated Effort | Status |
|----|------|-------------|----------|------------------|--------|
| TD-001 | Performance | Database query optimization | High | 2 days | Planned |
| TD-002 | Security | Update deprecated dependencies | Critical | 1 day | In Progress |
```

## Plan Automation

### Plan Validation

Linters and CI checks validate:
- All required sections present
- Proper front matter format
- Identifier prefixes follow conventions
- No placeholder text remains
- Links are valid

### Plan Generation

Agents can generate plans from:
- User requirements
- Issue descriptions
- Feature specifications
- Architecture proposals

### Plan Execution

Agents execute plans by:
- Reading plan from repository
- Processing tasks in order
- Updating completion status
- Creating PRs for each phase
- Handling dependencies between tasks
