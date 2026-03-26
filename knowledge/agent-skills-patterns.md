# Agent Skills Patterns and Templates

This document contains common patterns and templates identified across the agent skills repository.

## Skill Structure Patterns

### Standard Front Matter
All skills follow this front matter structure:
```yaml
---
name: skill-name
description: 'Brief description of the skill purpose'
---
```

### Common Skill Categories

#### 1. Implementation Planning Skills
- **Pattern**: Create structured plans for development work
- **Examples**: `create-implementation-plan`, `create-github-action-workflow-specification`
- **Structure**:
  - Primary directive with machine-readable focus
  - Execution context for AI-to-AI communication
  - Template requirements with specific sections
  - Validation rules and quality gates

#### 2. GitHub Management Skills
- **Pattern**: Manage GitHub resources using MCP tools
- **Examples**: `github-issues`, `create-github-pull-request-from-specification`
- **Structure**:
  - Available tools table (MCP vs CLI/REST API)
  - Workflow steps
  - Command examples with `gh api`
  - Template references

#### 3. Language-Specific Best Practices
- **Pattern**: Provide coding standards for specific languages
- **Examples**: `csharp-async`, `javascript-typescript-jest`
- **Structure**:
  - Naming conventions
  - Return types/Patterns
  - Exception handling
  - Performance considerations
  - Common pitfalls

#### 4. Code Review Skills
- **Pattern**: Systematic code review guidelines
- **Examples**: `sql-code-review`, `postgresql-code-review`
- **Structure**:
  - Review priorities (Critical/Important/Suggestion)
  - Security considerations
  - Performance patterns
  - Quality checklists

## Template Patterns

### Implementation Plan Template
```markdown
---
goal: [Concise Title]
version: [version]
date_created: [YYYY-MM-DD]
status: [Completed|In progress|Planned|Deprecated|On Hold]
tags: [feature, upgrade, chore, architecture, migration, bug]
---

# Introduction

## 1. Requirements & Constraints
- **REQ-001**: Requirement
- **SEC-001**: Security Requirement
- **CON-001**: Constraint

## 2. Implementation Steps
### Phase 1
- GOAL-001: [Phase goal]
| Task | Description | Completed | Date |
|------|-------------|-----------|------|

## 3. Alternatives
## 4. Dependencies
## 5. Files
## 6. Testing
## 7. Risks & Assumptions
## 8. Related Specifications
```

### GitHub Issue Template
```markdown
## Description
[Brief description]

## Steps to Reproduce
1. Step 1
2. Step 2

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]
```

## Common Command Patterns

### GitHub API Commands
```bash
# Create issue
gh api repos/{owner}/{repo}/issues -X POST -f title=... -f body=...

# Update issue  
gh api repos/{owner}/{repo}/issues/{number} -X PATCH -f state=...

# Add comment
gh api repos/{owner}/{repo}/issues/{number}/comments -X POST -f body=...
```

### Naming Conventions
- **Skills**: kebab-case (e.g., `create-implementation-plan`)
- **Methods**: PascalCase with Async suffix for async methods
- **Variables**: camelCase for private/local, PascalCase for public
- **Interfaces**: Prefix with 'I' (e.g., `IUserService`)

## File Organization Patterns

### Skill Directory Structure
```
skill-name/
├── SKILL.md (main skill definition)
├── references/ (optional - detailed docs)
│   ├── templates.md
│   ├── search.md
│   └── sub-issues.md
└── assets/ (optional - bundled files)
```

### Rules File Structure
```
rules/
├── language.instructions.md (per language)
├── domain.instructions.md (per domain)
└── generic.instructions.md (cross-cutting concerns)
```

## Quality Assurance Patterns

### Mandatory Verification Process
- Domain model validation
- SOLID principles adherence
- Test coverage requirements
- Security considerations
- Performance implications

### Test Naming Convention
```
MethodName_Condition_ExpectedResult()
```

### Code Review Priority Levels
1. **🔴 CRITICAL**: Security, correctness, breaking changes, data loss
2. **🟡 IMPORTANT**: Code quality, test coverage, performance, architecture
3. **🟢 SUGGESTION**: Readability, optimization, best practices, documentation

## Integration Patterns

### MCP Server Integration
- Use `mcp__` prefixed tools for read operations
- Use CLI/REST API for write operations
- Provide tool availability tables
- Include workflow steps

### Multi-IDE Support
- Support VS Code, Windsurf, Cursor, Devin, Claude, Gemini
- Use consistent directory structures
- Provide installation scripts
- Handle platform-specific differences

## Documentation Patterns

### Comment Structure
```markdown
**[PRIORITY] Category: Brief title**

Detailed description.

**Why this matters:**
Impact explanation.

**Suggested fix:**
[code example]

**Reference:** [link]
```

### Template References
- Cross-link to related templates
- Use consistent naming for template files
- Provide examples for each template type
- Include customization guidelines
