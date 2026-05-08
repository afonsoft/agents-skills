# Design Principles

This document outlines the design principles and patterns used throughout the agents-skills repository.

## Agent-First Design

All design decisions prioritize agent readability and comprehension over human convenience. The repository is optimized for autonomous agent operations.

### Repository Structure

```
agents-skills/
├── skills/           # Agent Skills (SKILL.md format)
├── rules/            # Path-specific coding standards (.instructions.md)
├── agents/           # GitHub Copilot agent definitions
├── workflows/        # Agentic workflows for automation
├── knowledge/        # Memory documents and guides
│   ├── design-docs/  # Design patterns and principles
│   ├── exec-plans/   # Execution plans (active/completed)
│   ├── generated/    # Auto-generated documentation
│   ├── product-specs/ # Product specifications
│   ├── references/   # Framework-specific guides
│   ├── DESIGN.md     # This file
│   ├── FRONTEND.md   # Frontend design patterns
│   ├── PLANS.md      # Planning templates
│   ├── PRODUCT_SENSE.md # Product principles
│   ├── QUALITY_SCORE.md # Quality metrics
│   ├── RELIABILITY.md # Reliability requirements
│   └── SECURITY.md   # Security guidelines
├── .agents/          # Agent conventions and documentation
├── install.sh        # Multi-IDE/CLI installation script
└── llms.txt          # LLM discoverability
```

## Design Patterns

### Skill Structure

Each skill follows the standard structure:
```
skill-name/
├── SKILL.md (main skill definition)
├── references/ (optional - detailed docs)
│   ├── templates.md
│   ├── patterns.md
│   └── examples.md
└── assets/ (optional - bundled files)
```

### Rule Structure

Rules are path-specific with YAML frontmatter:
```yaml
---
applyTo: '**/*.cs,**/*.csproj'
description: 'C# coding standards'
---
```

## Architectural Principles

### Layered Architecture

For framework-specific skills (ABP, Angular, etc.), follow layered patterns:
- **Types** → **Config** → **Repo** → **Service** → **Runtime** → **UI**
- Cross-cutting concerns via **Providers** interface
- Forward-only dependencies

### Cross-Platform Compatibility

All skills and rules must work across:
- VS Code (GitHub Copilot)
- Windsurf (Cascade)
- Cursor
- Devin CLI
- Claude Code
- Gemini CLI

## Design Quality Metrics

- **Agent Readability**: Can agents understand and execute without human interpretation?
- **Self-Contained**: No external dependencies for understanding
- **Mechanically Validatable**: Can be checked via linters/tests
- **Progressive Disclosure**: Small entry point, deeper context on demand
- **Versioned**: All plans and specs are versioned in repository

## Design Review Process

Before adding new skills/rules:
1. Check if similar exists in design-docs/
2. Follow established patterns
3. Ensure cross-platform compatibility
4. Validate mechanical checkability
5. Update relevant index files
