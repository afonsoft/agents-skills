# OpenCode Hooks

OpenCode can load skills through its native `skill` tool (no session hook required), or use a shell session-start hook via `hooks.json`.

## Files

| Arquivo | Funcao |
|---------|--------|
| `hooks.json` | Configuracao de hooks do OpenCode (sessionStart) |
| `session-start` | Script que injeta catalogo de skills no inicio da sessao |

## How OpenCode loads skills

- Global: `~/.config/opencode/skills/<name>/SKILL.md`
- Global compatibility: `~/.claude/skills/<name>/SKILL.md` and `~/.agents/skills/<name>/SKILL.md`
- Project: `.opencode/skills/<name>/SKILL.md` or `.agents/skills/<name>/SKILL.md`

OpenCode reads `SKILL.md` files and makes them available through the `skill` tool automatically. No session hook is required.

## Instalacao

```bash
./install.sh --opencode
./install.sh --opencode-desktop
./install.sh --opencode-cli
```

Copia hooks para `~/.opencode/hooks/` (Desktop) ou `~/.config/opencode/hooks/` (CLI).

## Plugin hook (optional)

If you want a real session hook, place a valid OpenCode plugin in `~/.config/opencode/plugins/`. The `install.sh` script will copy `hooks/opencode/plugins/*.js` there if present.
