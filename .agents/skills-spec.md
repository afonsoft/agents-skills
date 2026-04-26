# Skills Specification

This document details the Agent Skills specification as implemented in this repository, following the official [agentskills.io](https://agentskills.io) standard.

## SKILL.md Format

### Required Frontmatter Fields

```yaml
---
name: skill-name                    # Lowercase with hyphens, max 64 chars
description: Skill description     # 10-1024 chars, single quotes
tools:                            # Optional: allowed tools
  - read
  - write
  - bash
triggers:                         # Optional: activation triggers
  - user
  - model
---
```

### Standard Structure

```
skill-name/
├── SKILL.md          # Main skill file with frontmatter
├── scripts/          # Optional bundled scripts
├── templates/        # Optional code templates  
├── assets/           # Other supporting files
└── references/       # Documentation and examples
```

## Naming Conventions

### Folder Names
- Lowercase with hyphens: `angular-component`, `create-github-issue`
- Maximum 64 characters
- Must match `name` field in SKILL.md

### Description Guidelines
- 10-1024 characters
- Clear, concise purpose statement
- Include trigger conditions when helpful
- Use single quotes in YAML

## Best Practices

### Content Organization
- Use `---` separators for logical sections
- Include step-by-step workflows
- Provide code examples where relevant
- Reference external documentation

### Resource Bundling
- Keep assets under 5MB per file
- Reference bundled files in instructions
- Use relative paths from skill root
- Include templates for common patterns

### Trigger Design
- `user` - Agent can suggest skill to user
- `model` - Agent activates automatically
- Be specific about when skill should trigger

## Installation Paths

### Universal Paths
- `.agents/skills/` - Workspace skills (highest priority)
- `~/.agents/skills/` - User skills (medium priority)

### Tool-Specific Paths
- `~/.github/skills/` - GitHub Copilot
- `~/.windsurf/skills/` - Windsurf Cascade
- `~/.cursor/skills/` - Cursor
- `~/.claude/skills/` - Claude Code
- `~/.gemini/skills/` - Gemini CLI
- `~/.config/cognition/skills/` - Devin CLI

## Examples from Repository

### Framework-Specific Skills
- `abp-angular` - ABP Framework Angular patterns
- `angular-component` - Modern Angular standalone components
- `aspnet-core-api` - Complete ASP.NET Core API development

### Workflow Skills  
- `create-github-issue-feature-from-specification`
- `create-github-pull-request-from-specification`
- `create-implementation-plan`

### Code Quality Skills
- `security-jwt` - JWT authentication implementation
- `sql-optimization` - Universal SQL performance tuning
- `web-design-reviewer` - Visual design inspection and fixes

## Validation

Use the installation script for validation:
```bash
./install.sh --all --verbose
```

Skills are automatically discovered by supported agents based on:
1. Directory structure compliance
2. Valid SKILL.md frontmatter
3. Proper naming conventions
4. Resource file organization

## References

- [Agent Skills Specification](https://agentskills.io)
- [Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Awesome Agent Skills](https://github.com/VoltAgent/awesome-agent-skills)
