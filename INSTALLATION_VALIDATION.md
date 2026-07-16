# Validação do Script de Instalação

O `install.sh` instala **skills + hooks de sessão + AGENTS.md**. Não instala `rules/` nem `knowledge/` (o repositório não distribui essas pastas).

## Targets suportados

| Target | Skills | Hooks | Config |
|--------|--------|-------|--------|
| `--base` / base (sempre) | `~/.agents/skills/` | — | — |
| `--devin` | `~/.devin/skills/`, `~/.cognition/skills/` | `~/.devin/hooks/` | `~/.devin/AGENTS.md` |
| `--devin-desktop` | `~/.devin/skills/` | `~/.devin/hooks/` | `~/.devin/AGENTS.md` |
| `--devin-cli` | `~/.config/devin/skills/` | `~/.config/devin/hooks/` | `~/.config/devin/AGENTS.md` |
| `--claude` | `~/.claude/skills/` | `~/.claude/hooks/` | `~/.claude/CLAUDE.md`, `~/.claude/AGENTS.md` |
| `--cursor` | `~/.cursor/skills/` | `~/.cursor/hooks/` | `~/.cursor/AGENTS.md` |
| `--opencode` | `~/.opencode/skills/`, `~/.config/opencode/skills/` | `~/.opencode/hooks/`, `~/.config/opencode/hooks/` | `~/.opencode/AGENTS.md` or `~/.config/opencode/AGENTS.md` |
| `--opencode-desktop` | `~/.opencode/skills/` | `~/.opencode/hooks/` | `~/.opencode/AGENTS.md` |
| `--opencode-cli` | `~/.config/opencode/skills/` | `~/.config/opencode/hooks/` | `~/.config/opencode/AGENTS.md` |
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
