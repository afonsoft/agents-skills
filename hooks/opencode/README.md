# Hooks — OpenCode

> OpenCode does **not** use shell session-start hooks. It uses a native plugin system (JavaScript/TypeScript) and the built-in `skill` tool to discover skills.

This directory is a placeholder. `install.sh --opencode` does **not** copy `hooks/opencode/` to `~/.config/opencode/hooks/` because that is not a standard OpenCode path. If `hooks/opencode/plugins/` exists, the installer copies plugins to `~/.config/opencode/plugins/`.

## How OpenCode loads skills

- Global: `~/.config/opencode/skills/<name>/SKILL.md`
- Global compatibility: `~/.claude/skills/<name>/SKILL.md` and `~/.agents/skills/<name>/SKILL.md`
- Project: `.opencode/skills/<name>/SKILL.md` or `.agents/skills/<name>/SKILL.md`

OpenCode reads `SKILL.md` files and makes them available through the `skill` tool automatically. No session hook is required.

## Plugin hook (optional)

If you want a real session hook, place a valid OpenCode plugin in `~/.config/opencode/plugins/`. The `install.sh` script will copy `hooks/opencode/plugins/*.js` there if present.
