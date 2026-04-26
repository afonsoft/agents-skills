@import "AGENTS.md"

# Claude-Specific Instructions

## Memory Management

Claude writes learned information to .agents/MEMORY.md automatically. This complements the instructions in AGENTS.md.

## Tool Integration

Claude supports Model Context Protocol (MCP) servers for tool integration. Configure in mcp-config.json.

## Skill Discovery

Skills are discovered from:
- ~/.claude/skills/ (Claude-specific)
- .agents/skills/ (universal)
- ~/.agents/skills/ (user-level)

## Rules Loading

Rules are loaded from:
- ~/.claude/rules/ (Claude-specific)
- .instructions.md files (path-specific)
