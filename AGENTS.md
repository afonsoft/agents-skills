# AGENTS.md

**agents-skills** - Community-driven collection of AI agent skills, rules, and knowledge following OpenAI harness engineering principles.

## Quick Start

```bash
./install.sh --all
```

## Repository Map

```
agents-skills/
├── skills/           # Agent Skills (SKILL.md format)
├── rules/            # Path-specific coding standards (.instructions.md)
├── agents/           # GitHub Copilot agent definitions
├── workflows/        # Agentic workflows for automation
├── knowledge/        # Knowledge base (structured docs)
├── .agents/          # Agent conventions
├── install.sh        # Installation script
└── llms.txt          # LLM discoverability
```

## Knowledge Base Structure

See [knowledge/](knowledge/) for detailed documentation:

- **knowledge/design-docs/** - Design patterns, core beliefs, architectural principles
- **knowledge/exec-plans/** - Active/completed execution plans, tech debt tracker
- **knowledge/generated/** - Auto-generated documentation
- **knowledge/product-specs/** - Product specifications
- **knowledge/references/** - Framework-specific guides
- **knowledge/DESIGN.md** - Design principles and patterns
- **knowledge/FRONTEND.md** - Frontend design patterns
- **knowledge/PLANS.md** - Planning templates
- **knowledge/PRODUCT_SENSE.md** - Product principles
- **knowledge/QUALITY_SCORE.md** - Quality metrics and scoring
- **knowledge/RELIABILITY.md** - Reliability requirements
- **knowledge/SECURITY.md** - Security guidelines

## Core Principles

**Humans direct. Agents execute.**

Repository optimized for agent readability following OpenAI harness engineering:
- AGENTS.md as index (~100 lines), not encyclopedia
- Knowledge in structured docs/ with mechanical validation
- Rigid architecture with forward-only dependencies
- Continuous garbage collection for technical debt

See [knowledge/design-docs/core-beliefs.md](knowledge/design-docs/core-beliefs.md) for complete principles.

## Supported Platforms

VS Code (GitHub Copilot), Windsurf (Cascade), Cursor, Devin CLI, Claude Code, Gemini CLI

## Standards

[Agent Skills Specification](https://agentskills.io) | [Agentic AI Foundation](https://aaif.org) | [Model Context Protocol](https://modelcontextprotocol.io)
