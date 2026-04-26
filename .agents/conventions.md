# AI Agent Conventions

This directory contains configuration files and documentation for AI agent standards and conventions.

## Files

- `conventions.md` - This file, overview of AI agent patterns
- `skills-spec.md` - Agent Skills specification details  
- `mcp-integration.md` - Model Context Protocol integration guide
- `paths-reference.md` - Reference of installation paths for each IDE/CLI

## Standards Supported

### Agent Skills (SKILL.md)
- YAML frontmatter with name, description, tools
- Standard folder structure with bundled resources
- Cross-tool compatibility

### Model Context Protocol (MCP)
- "USB-C for AI" interoperability standard
- Agent-agnostic tool integration
- Server-based architecture

### Context Files
- `AGENTS.md` - Cross-tool agent context
- `CLAUDE.md` - Claude-specific instructions
- `GEMINI.md` - Gemini-specific context

### Discovery
- `llms.txt` - LLM discoverability standard
- Automatic skill detection
- Hierarchical precedence

## Implementation Patterns

### Skill Structure
```
skill-name/
├── SKILL.md           # Main skill file with frontmatter
├── scripts/           # Optional bundled scripts
├── templates/         # Optional code templates
└── assets/           # Other supporting files
```

### Installation Precedence
1. Workspace skills (`.agents/skills/`)
2. User skills (`~/.agents/skills/`)
3. System skills (tool-specific)

### Cross-Tool Compatibility
- Standard folder structures
- Generic aliases (`.agents/skills/`)
- Tool-specific fallbacks

## Resources

- [Agent Skills Specification](https://agentskills.io)
- [AI Conventions](https://github.com/GuilhermeAlbert/awesome-ai-conventions)
- [Agentic AI Foundation](https://aaif.org)
- [Model Context Protocol](https://modelcontextprotocol.io)
