# AGENTS.md

**agents-skills** - Community-driven collection of AI agent skills, rules, and knowledge following modern conventions.

## Project Overview

Cross-tool compatibility for AI development agents with file-based protocols:
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
├── skills/           # Agent Skills (SKILL.md format)
├── rules/            # Path-specific coding standards (.instructions.md)
├── agents/           # GitHub Copilot agent definitions
├── workflows/        # Agentic workflows for automation
├── knowledge/        # Memory documents and guides
├── .agents/          # Agent conventions and documentation
├── install.sh        # Multi-IDE/CLI installation script
└── llms.txt          # LLM discoverability
```

## Build Commands

```bash
# Install skills across all IDEs/CLIs
./install.sh --all

# Install for specific tools  
./install.sh --vscode --windsurf --claude

# Clean up backup files
./rm-backup.sh
```

## Coding Conventions

### Skills (SKILL.md)
- YAML frontmatter: name, description, tools, triggers
- Standard folder structure with bundled resources
- Follows [Agent Skills specification](https://agentskills.io)

### Rules (.instructions.md)
- Path-specific standards with YAML frontmatter
- Cross-platform compatibility
- IDE-specific configurations

### Context Files
- **AGENTS.md** - Cross-tool agent context (this file)
- **CLAUDE.md** - Claude-specific persistent instructions
- **GEMINI.md** - Gemini-specific context

## Agent Behavior

### What Agents Should Do
- Read and follow skills/rules for specialized tasks
- Use bundled resources when executing skills
- Respect .aiignore patterns for file exclusion
- Apply context from nearest AGENTS.md in directory tree

### What Agents Should Not Touch
- Generated files and backup artifacts
- Configuration files with sensitive data
- Build outputs and dependencies
- Files matching .aiignore patterns

## Standards Compliance

Following [Agentic AI Foundation](https://aaif.org) conventions:
- **SKILL.md** format for modular expertise
- **llms.txt** for LLM discoverability
- **Model Context Protocol (MCP)** for tool integration
- File-based protocols over proprietary solutions

## Contributing

1. Fork repository
2. Create feature branch from `staged`  
3. Add skill/rule/knowledge following conventions
4. Submit PR to `staged` branch

## Resources

- [Agent Skills Specification](https://agentskills.io)
- [AI Conventions](https://github.com/GuilhermeAlbert/awesome-ai-conventions)  
- [Model Context Protocol](https://modelcontextprotocol.io)
- [Agentic AI Foundation](https://aaif.org)

MIT License - see LICENSE file
