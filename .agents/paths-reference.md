# Installation Paths Reference

This document provides the standard installation paths for each supported IDE/CLI.
The installer copies **skills + session hooks + AGENTS.md** — there are no rules/knowledge folders.

## Per-tool paths

### Base (always installed)
- **Skills**: `~/.agents/skills/`

### Devin / Devin CLI
- **Skills**: `~/.devin/skills/`, `~/.cognition/skills/`, `~/.config/devin/skills/`
- **Hooks**: `~/.devin/hooks/`
- **Context**: `~/.devin/AGENTS.md`

### Claude Code
- **Skills**: `~/.claude/skills/`
- **Hooks**: `~/.claude/hooks/`
- **Context**: `~/.claude/CLAUDE.md`, `~/.claude/AGENTS.md`

### Cursor
- **Skills**: `~/.cursor/skills/`
- **Hooks**: `~/.cursor/hooks/`
- **Context**: `~/.cursor/AGENTS.md`

### Windsurf (Cascade)
- **Skills**: `~/.windsurf/skills/`
- **Hooks**: `~/.windsurf/hooks/`
- **Context**: `~/.windsurf/AGENTS.md`

### VS Code (GitHub Copilot)
- **Skills**: `~/.github/skills/`
- **Hooks**: `~/.github/hooks/`
- **Context**: `~/.github/AGENTS.md`

### Gemini CLI
- **Skills**: `~/.gemini/skills/`
- **Hooks**: `~/.gemini/hooks/`
- **Context**: `~/.gemini/AGENTS.md`

### OpenCode
- **Skills**: `~/.config/opencode/skills/` (primary), `~/.agents/skills/` (universal), `~/.claude/skills/` (fallback)
- **Rules**: `~/.config/opencode/AGENTS.md` (global), `.opencode/AGENTS.md` (project)
- **Plugins**: `~/.config/opencode/plugins/` (OpenCode plugin system)
- **Hooks**: OpenCode does not use a `hooks/` directory; it uses plugins and `AGENTS.md`

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

## Installation Script Behavior

The `install.sh` script:
1. Always installs to `~/.agents/skills/` (base)
2. Creates tool-specific directories as needed
3. Backs up existing dirs/files to `*.backup.<timestamp>`
4. Supports `--dry-run` to preview actions

## Examples

```bash
# After installation, skills are available at:
~/.agents/skills/your-skill/SKILL.md          # Universal
~/.windsurf/skills/your-skill/SKILL.md        # Windsurf specific
~/.claude/skills/your-skill/SKILL.md          # Claude specific
```
