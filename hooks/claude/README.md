# Claude Code Hooks

## Arquivos

| Arquivo | Funcao |
|---------|--------|
| `hooks.json` | Configuracao de hooks do Claude Code (SessionStart) |
| `session-start` | Script que injeta catalogo de skills no inicio da sessao |
| `rtk-rewrite.sh` | Hook PreToolUse que reescreve comandos para RTK automaticamente |
| `rtk-suggest.sh` | Hook PreToolUse que sugere equivalentes RTK via systemMessage |

## Instalacao

```bash
./install.sh --claude
```

Copia hooks para `~/.claude/hooks/`.
