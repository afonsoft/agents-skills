# CLAUDE.md

This file provides Claude-specific persistent instructions. For multi-tool teams, this is typically a symlink to AGENTS.md.

## Instructions

Read AGENTS.md for comprehensive project context and conventions.

## Claude-Specific Behavior

- Use @imports to reference additional context files
- Auto-memory will be written to MEMORY.md
- Skills are discovered from ~/.claude/skills/ and .agents/skills/
- Rules are loaded from ~/.claude/rules/ and project-specific .instructions.md files

## Memory Management

Claude writes learned information to MEMORY.md automatically. This complements the instructions in AGENTS.md.

## Tool Integration

Claude supports Model Context Protocol (MCP) servers for tool integration. Configure in mcp-config.json.
