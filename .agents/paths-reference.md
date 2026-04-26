# Installation Paths Reference

This document provides the standard installation paths for each supported IDE/CLI.

## Skills Installation Paths

### VS Code (GitHub Copilot)
- **Skills**: `~/.github/skills/`
- **Rules**: `~/.copilot/instructions/`
- **Knowledge**: `~/.copilot/knowledge/`
- **Consolidated**: `~/.github/copilot-instructions.md`

### Windsurf (Cascade)
- **Skills**: `~/.windsurf/skills/`
- **Rules**: `~/.windsurf/rules/`
- **Knowledge**: `~/.windsurf/knowledge/`
- **Consolidated**: `~/.windsurfrules`

### Cursor
- **Skills**: `~/.cursor/skills/`
- **Rules**: `~/.cursor/rules/`
- **Knowledge**: `~/.cursor/knowledge/`
- **Consolidated**: `~/.cursorrules`

### Devin CLI
- **Skills**: `~/.config/cognition/skills/`
- **Knowledge**: `~/.config/cognition/knowledge/`
- **Legacy**: `~/.cognition/skills/`
- **Compat**: `~/.devin/skills/`

### Claude Code
- **Skills**: `~/.claude/skills/`
- **Rules**: `~/.claude/rules/`
- **Knowledge**: `~/.claude/knowledge/`
- **Context**: `CLAUDE.md` (persistent instructions)

### Gemini CLI
- **Skills**: `~/.gemini/skills/`
- **Knowledge**: `~/.gemini/knowledge/`
- **Context**: `~/.gemini/GEMINI.md`
- **Memory**: `~/.gemini/memory/MEMORY.md`

### OpenClaw
- **Skills**: `~/.openclaw/skills/`
- **Memory**: `~/.openclaw/workspace/memory/MEMORY.md`
- **Daily Logs**: `~/.openclaw/workspace/memory/YYYY-MM-DD.md`

## Universal Paths

### Base Skills Directory
- `~/.agents/skills/` - Always installed, serves as universal source
- `.agents/skills/` - Workspace-specific skills

### Precedence Order
1. Workspace skills (`.agents/skills/`)
2. User skills (`~/.agents/skills/`)
3. Tool-specific paths

## Platform Differences

### Windows
- `%APPDATA%\tool-name\skills\`
- `%USERPROFILE%\.tool-name\skills\`

### macOS/Linux
- `~/.tool-name/skills/`
- `~/.config/tool-name/skills/` (XDG compliance)

## Aliases and Compatibility

### Generic Alias
- `.agents/skills/` - Works across all supported tools
- Provides unified management interface

### Tool-Specific Fallbacks
Each tool checks its specific path first, then falls back to generic alias.

## Installation Script Behavior

The `install.sh` script:
1. Always installs to `~/.agents/skills/` (base)
2. Creates tool-specific directories as needed
3. Sets up symlinks for consolidated files
4. Handles platform-specific paths automatically

## Examples

```bash
# After installation, skills are available at:
~/.agents/skills/your-skill/SKILL.md          # Universal
~/.windsurf/skills/your-skill/SKILL.md        # Windsurf specific
~/.claude/skills/your-skill/SKILL.md          # Claude specific
```
