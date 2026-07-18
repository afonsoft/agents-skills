# Installation Paths Reference

This document provides the standard installation paths for each supported IDE/CLI.
The installer copies **skills + session hooks + AGENTS.md** — there are no rules/knowledge folders.

## Per-tool paths

### Base (always installed)
- **Skills**: `~/.agents/skills/`

### Devin
- **Skills**: `~/.devin/skills/`, `~/.cognition/skills/`
- **Hooks**: `~/.devin/hooks/`
- **Context**: `~/.devin/AGENTS.md`

### Devin CLI
- **Skills**: `~/.config/devin/skills/`
- **Hooks**: `~/.config/devin/hooks/`
- **Context**: `~/.config/devin/AGENTS.md`

### Devin Desktop
- **Skills**: `~/.devin/skills/`
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

### OpenCode
- **Skills**: `~/.opencode/skills/`, `~/.config/opencode/skills/`
- **Hooks**: `~/.opencode/hooks/`, `~/.config/opencode/hooks/`
- **Context**: `~/.opencode/AGENTS.md` or `~/.config/opencode/AGENTS.md`

### OpenCode Desktop
- **Skills**: `~/.opencode/skills/`
- **Hooks**: `~/.opencode/hooks/`
- **Context**: `~/.opencode/AGENTS.md`

### OpenCode CLI
- **Skills**: `~/.config/opencode/skills/`
- **Hooks**: `~/.config/opencode/hooks/`
- **Context**: `~/.config/opencode/AGENTS.md`

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
~/.devin/skills/your-skill/SKILL.md           # Devin Desktop
~/.config/devin/skills/your-skill/SKILL.md    # Devin CLI
~/.opencode/skills/your-skill/SKILL.md        # OpenCode Desktop
~/.config/opencode/skills/your-skill/SKILL.md # OpenCode CLI
~/.claude/skills/your-skill/SKILL.md          # Claude specific
```
