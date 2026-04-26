# Agents Infrastructure

This directory contains the technical infrastructure for AI agent operations in the agents-skills repository.

## Purpose

The `.agents/` directory serves as the operational hub for AI agent context, memory, and configuration. It implements file-based protocols following Agentic AI Foundation standards.

## File Structure

```
.agents/
├── MEMORY.md              # AI-written technical decisions and lessons learned
├── conventions.md         # Overview of AI agent patterns and standards
├── skills-spec.md         # Complete SKILL.md specification guide
├── mcp-integration.md     # Model Context Protocol implementation patterns
└── paths-reference.md     # Installation paths reference for each IDE/CLI
```

## Skill Loading Architecture

### Discovery Precedence

Skills are discovered in the following order (highest to lowest priority):

1. **Workspace Skills**: `.agents/skills/` or tool-specific paths
2. **User Skills**: `~/.agents/skills/`
3. **System Skills**: Tool-specific locations

### Tool-Specific Paths

Each IDE/CLI has its own skill discovery path:

- **VS Code**: `~/.github/skills/`
- **Windsurf**: `~/.windsurf/skills/`
- **Cursor**: `~/.cursor/skills/`
- **Devin CLI**: `~/.config/cognition/skills/`
- **Claude Code**: `~/.claude/skills/`
- **Gemini CLI**: `~/.gemini/skills/`
- **OpenClaw**: `~/.openclaw/skills/`

### Universal Alias

The `.agents/skills/` path serves as a universal alias that all supported tools check, providing a single canonical location for skill management.

## SKILL.md Format

### Required Frontmatter

```yaml
---
name: skill-name
description: Skill description
tools: [optional]
triggers: [optional]
---
```

### Validation Criteria

- Folder name must match `name` field
- Name: lowercase with hyphens, max 64 characters
- Description: 10-1024 characters
- Bundled assets under 5MB per file

## Context File Hierarchy

### Root-Level Context

- **AGENTS.md**: Cross-tool agent context (single source of truth)
- **CLAUDE.md**: Claude-specific instructions with `@import AGENTS.md`
- **llms.txt**: LLM discoverability for web crawlers
- **.aiignore**: File exclusion patterns for AI agents

### Memory System

- **MEMORY.md**: AI-written technical decisions and lessons
- Located in `.agents/MEMORY.md` to avoid root clutter
- Complements AGENTS.md instructions with learned patterns

## Model Context Protocol (MCP)

### Server Architecture

MCP servers run independently from executing agents, providing tool integration agnostic of the agent platform.

### Configuration

MCP servers are configured in `mcp-config.json` at the workspace root:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["server.js"],
      "env": { "ENV_VAR": "value" }
    }
  }
}
```

### Integration Patterns

Skills can declare MCP tool dependencies in frontmatter:

```yaml
---
name: workflow-skill
tools:
  - mcp:github
  - mcp:filesystem
---
```

## Installation Script

The `install.sh` script handles cross-platform installation:

```bash
# Install for all IDEs/CLIs
./install.sh --all

# Install for specific tools
./install.sh --vscode --windsurf --claude

# Clean up backups
./rm-backup.sh
```

### Installation Behavior

1. Always installs to `~/.agents/skills/` (base)
2. Creates tool-specific directories as needed
3. Sets up symlinks for consolidated files
4. Handles platform-specific paths automatically

## Technical Stack

### Languages and Frameworks

- **C#/.NET**: ASP.NET Core, ABP.IO, Entity Framework Core
- **TypeScript**: Angular v20+, React, Node.js
- **Python**: Automation scripts, testing frameworks
- **PowerShell**: System administration utilities

### Architecture Patterns

- **SOLID Principles**: Applied across all code
- **Clean Architecture**: Layered separation of concerns
- **DDD**: Domain-Driven Design for complex domains
- **CQRS**: Command Query Responsibility Segregation

## Development Workflow

### Adding New Skills

1. Create skill directory: `skills/your-skill/`
2. Add `SKILL.md` with proper frontmatter
3. Include bundled resources (scripts, templates)
4. Validate with `./install.sh --all --verbose`
5. Test with target IDE/CLI

### Updating Context Files

1. Modify AGENTS.md for cross-tool changes
2. Update CLAUDE.md for Claude-specific changes
3. Add technical decisions to .agents/MEMORY.md
4. Commit with descriptive message

## Standards Compliance

This infrastructure follows:

- **Agentic AI Foundation**: AGENTS.md specification
- **Agent Skills**: SKILL.md format (agentskills.io)
- **Model Context Protocol**: MCP integration patterns
- **awesome-ai-conventions**: File-based protocols

## Troubleshooting

### Skills Not Loading

- Verify SKILL.md frontmatter is valid
- Check folder name matches `name` field
- Ensure directory structure follows specification
- Run `./install.sh --all --verbose` for diagnostics

### MCP Servers Not Connecting

- Verify mcp-config.json syntax
- Check server command and arguments
- Validate environment variables
- Test server independently

### Context Not Applied

- Ensure AGENTS.md is in repository root
- Verify .aiignore isn't excluding context files
- Check file permissions
- Restart agent to reload context

## Resources

- [Agent Skills Specification](https://agentskills.io)
- [Agentic AI Foundation](https://aaif.org)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [AI Conventions](https://github.com/GuilhermeAlbert/awesome-ai-conventions)
