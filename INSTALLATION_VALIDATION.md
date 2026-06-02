# Validação do Script de Instalação

O `install.sh` instala **skills + hooks de sessão + AGENTS.md**. Não instala `rules/` nem `knowledge/` (o repositório não distribui essas pastas).

## Targets suportados

| Target | Skills | Hooks | Config |
|--------|--------|-------|--------|
| `--base` / base (sempre) | `~/.agents/skills/` | — | — |
| `--devin` | `~/.devin/skills/`, `~/.cognition/skills/`, `~/.config/devin/skills/` | `~/.devin/hooks/` | `~/.devin/AGENTS.md` |
| `--claude` | `~/.claude/skills/` | `~/.claude/hooks/` | `~/.claude/CLAUDE.md`, `~/.claude/AGENTS.md` |
| `--cursor` | `~/.cursor/skills/` | `~/.cursor/hooks/` | `~/.cursor/AGENTS.md` |
| `--windsurf` | `~/.windsurf/skills/` | `~/.windsurf/hooks/` | `~/.windsurf/AGENTS.md` |
| `--vscode` | `~/.github/skills/` | `~/.github/hooks/` | `~/.github/AGENTS.md` |
| `--gemini` | `~/.gemini/skills/` | `~/.gemini/hooks/` | `~/.gemini/AGENTS.md` |

## Comandos validados

```bash
./install.sh --help              # Exibe ajuda
./install.sh --devin --dry-run   # Pré-visualiza ações sem alterar nada
./install.sh --devin             # Instala para Devin
./install.sh --all               # Instala para todos os targets
```

## Comportamento

- **Backup automático**: diretórios/arquivos existentes viram `*.backup.<timestamp>` antes de serem sobrescritos.
- **`--dry-run`**: imprime cada ação (`mkdir`/`cp`/`mv`) sem executar.
- **Idempotente**: pode ser re-executado; cria backups das instalações anteriores.
- **Validação rápida**:

```bash
test -d ~/.agents/skills && test -f ~/.devin/AGENTS.md && echo "PASS" || echo "FAIL"
```

## Lint

```bash
shellcheck install.sh
```
