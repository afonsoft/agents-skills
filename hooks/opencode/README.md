# OpenCode Hooks

## Arquivos

| Arquivo | Funcao |
|---------|--------|
| `hooks.json` | Configuracao de hooks do OpenCode (sessionStart) |
| `session-start` | Script que injeta catalogo de skills no inicio da sessao |

## Instalacao

```bash
./install.sh --opencode
./install.sh --opencode-desktop
./install.sh --opencode-cli
```

Copia hooks para `~/.opencode/hooks/` (Desktop) ou `~/.config/opencode/hooks/` (CLI).
