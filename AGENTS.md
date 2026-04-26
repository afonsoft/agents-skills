# AGENTS.md

**agents-skills** - Community-driven collection of custom agents, skills, rules, and knowledge for enhancing AI development experiences.

## Project Overview

This repository provides specialized AI agent capabilities across multiple IDEs and CLIs:
- **VS Code** (GitHub Copilot)
- **Windsurf** (Cascade)
- **Cursor**
- **Devin CLI**
- **Claude Code**
- **Gemini CLI**
- **OpenClaw**

## Repository Structure

```
agents-skills/
├── agents/           # Custom GitHub Copilot agent definitions
├── skills/           # Task-specific skills with bundled resources
├── rules/            # Coding standards and guidelines
├── workflows/        # Agentic workflows for automation
├── knowledge/        # Memory documents and guides
├── install.sh        # Installation script for all IDEs/CLIs
├── rm-backup.sh     # Backup cleanup script
├── clear-up-linux.sh  # Linux system cleanup utility
├── git-cleanup-repos.sh # Git repository maintenance
└── .agents/          # Agent configuration and conventions
```

## Key Conventions

### Skills Format
- Standard `SKILL.md` with YAML frontmatter
- Follows [Agent Skills specification](https://agentskills.io)
- Supports resource bundling and tool declarations

### Rules System
- `.instructions.md` files for path-specific rules
- YAML-frontmatter for IDE-specific configurations
- Cross-platform compatibility

### Knowledge Base
- Markdown documentation with patterns and guides
- Migration strategies and architectural decisions
- Framework-specific best practices

## Installation

```bash
# Install for all IDEs/CLIs
./install.sh --all

# Install for specific tools
./install.sh --vscode --windsurf --claude
```

## Usage

Skills are automatically discovered by supported agents:
- **Workspace skills**: `.agents/skills/` or tool-specific paths
- **User skills**: `~/.agents/skills/`
- **System skills**: Tool-specific locations

## Standards

This repository follows emerging AI conventions:
- **AGENTS.md** - Cross-tool agent context (this file)
- **SKILL.md** - Agent skills format
- **llms.txt** - LLM discoverability
- **MCP** - Model Context Protocol integration

## Contributing

1. Fork the repository
2. Create feature branch from `staged`
3. Add your skill/rule/knowledge/agent/workflow
4. Submit PR to `staged` branch

## License

MIT License - see LICENSE file for details.

## Resources

- [Agent Skills Specification](https://agentskills.io)
- [AI Conventions](https://github.com/GuilhermeAlbert/awesome-ai-conventions)
- [Agentic AI Foundation](https://aaif.org)
