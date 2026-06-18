# Windsurf Hooks

## Arquivos

| Arquivo | Funcao |
|---------|--------|
| `hooks.json` | Configuracao de hooks do Windsurf (sessionStart) |
| `session-start` | Script que injeta catalogo de skills no inicio da sessao |
| `rules.md` | Regras de prompt para uso de RTK (prompt-level guidance) |

## Nota

Windsurf nao suporta hook de rewrite transparente. RTK e integrado via rules file (`.windsurfrules`).

## Instalacao

```bash
./install.sh --windsurf
```

Copia hooks para `~/.windsurf/hooks/`.
