# MEMORY.md

This file stores technical decisions, technical debt, and lessons learned to avoid error loops. Written by AI agents, not humans.

## Technical Decisions

### 2026-04-26 - Architecture Alignment
- **Decision**: Adopt awesome-ai-conventions and Agentic AI Foundation standards
- **Rationale**: File-based protocols (AGENTS.md, SKILL.md, llms.txt) provide cross-tool compatibility
- **Impact**: Repository now supports VS Code, Windsurf, Cursor, Devin, Claude, Gemini
- **Status**: Implemented

### 2026-04-26 - Skill Format Standardization
- **Decision**: All skills must follow SKILL.md with YAML frontmatter
- **Rationale**: Universal format adopted by Anthropic, OpenAI, GitHub Copilot
- **Impact**: 140+ skills standardized with name, description, tools, triggers
- **Status**: Validated

## Technical Debt

### None currently tracked

## Lessons Learned

### Cross-Tool Compatibility
- Use `.agents/skills/` as universal path for skill discovery
- Tool-specific paths serve as fallbacks
- Symlink pattern prevents content drift across tools

### Memory Management
- Claude writes auto-memory to MEMORY.md
- AGENTS.md provides persistent instructions
- Separation prevents token bloat

### MCP Integration
- Model Context Protocol enables agent-agnostic tool integration
- Servers run independently from executing agent
- Standardized interface for tool discovery and invocation

## Known Issues

### None currently tracked

## Future Considerations

- Consider adding GEMINI.md for Gemini-specific instructions
- Evaluate Agent Cards specification for skill metadata
- Monitor Agentic AI Foundation for new conventions
