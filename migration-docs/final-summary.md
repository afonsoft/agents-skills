# Resumo da Migração — `afonsoft/agents-skills`

Branch: `feat/simplify-agents-skills-and-migrate-core` (base `main`).
Objetivo: simplificar o repositório para distribuir **apenas skills + hooks de sessão + AGENTS.md**, removendo `rules/`, `knowledge/` e skills específicas, e migrando skills genéricas do repositório de origem (sanitizadas).

## Antes → Depois

| Item | Antes | Depois |
|------|------:|------:|
| Skills (`skills/`) | 85 | **64** |
| Rules (`rules/`) | 107 | **0** (pasta removida) |
| Knowledge (`knowledge/`) | ~23 | **0** (pasta removida) |
| Workflows (`workflows/`) | 7 | 7 |
| Hooks (`hooks/`) | — | 18 arquivos (6 IDEs) |
| `install.sh` | 988 linhas | **235 linhas** |
| Arquivos versionados | 308 | 102 |

Diff total: **316 arquivos alterados** (96 adicionados, 206 removidos, 14 modificados).

## O que foi removido

- **`rules/` inteira** (107 `*.instructions.md`) + todas as referências em docs e no `install.sh`.
- **`knowledge/` inteira** (~23 docs) — conteúdo genérico/derivado das rules. Análise em `knowledge-analysis.md`.
- **41 skills** por padrão da demanda: `angular-*` (10), `create-*` (10), `csharp-*` (8), `dotnet-*` (9), `blazor-components`, `javascript-typescript-jest`. Detalhe em `skills-removed.md`.

## O que foi migrado (do `itau-lt6-scm-agent-skills`, sanitizado)

- **20 skills genéricas** ("superpowers"): `brainstorming`, `building-mcp-servers`, `caveman`, `caveman-commit`, `caveman-compress`, `caveman-review`, `defuddle`, `dispatching-parallel-agents`, `executing-plans`, `finishing-a-development-branch`, `json-canvas`, `receiving-code-review`, `requesting-code-review`, `subagent-driven-development`, `systematic-debugging`, `test-driven-development`, `using-git-worktrees`, `verification-before-completion`, `writing-plans`, `writing-skills`.
- **`hooks/`** de session-start para 6 IDEs (devin, claude, cursor, windsurf, vscode, gemini).
- Mapeamento origem→destino em `migration-map.md`; classificação em `source-repo-analysis.md`.

### Sanitização aplicada a cada skill migrada
1. `ORANGEBOOK.md` removido.
2. Frontmatter: removido `license: UNLICENSED` e bloco `metadata:` (community, rt, squad, author, visibility).
3. Prosa: removidas referências a Itaú/360i/Orange Book/WAF/Artifactory/`.iupipes.yml`/branch-policy.
4. **Não migrados**: skills `itau-*`, `angular-*`, `create-agent-harness`, `rtk-token-killer` e scripts/hooks específicos de RTK.

## Documentação atualizada

- `README.md` — reescrito: escopo skills+hooks, catálogo das 64 skills, tabela de paths por IDE, sem `rules/knowledge`, sem `npm run`.
- `AGENTS.md` — estrutura/paths atualizados, diagrama Mermaid do fluxo de session-start, sem rules/knowledge.
- `CLAUDE.md` — removida referência a `rules/*.instructions.md`.
- `CONTRIBUTING.md` — removidas seções "Adding Rules/Agents/Knowledge" e comandos `npm run *`; fluxo de validação via `shellcheck` + `install.sh --dry-run`.
- `llms.txt`, `INSTALLATION_VALIDATION.md` — reescritos para o novo escopo.
- `.agents/` (`paths-reference`, `TOOLS`, `CONTEXT`, `WORKFLOWS`, `RULES`, `README`, `skills-spec`) — referências a rules/knowledge/OpenClaw e exemplos de skills removidas atualizados.

## install.sh (novo)

- Targets: `--all/-a`, `--base/-b`, `--devin/-d`, `--claude`, `--cursor/-c`, `--windsurf/-w`, `--vscode/-v`, `--gemini/-g`, `--dry-run`.
- Instala apenas **skills + hooks + AGENTS.md** (sem rules/knowledge, sem "consolidated rules").
- Backups automáticos `*.backup.<timestamp>`; suporta múltiplos targets na mesma chamada.
- Validado: `--all` (64 skills + hooks copiados, sem backups espúrios) e `--dry-run`.

## Verificação

- `shellcheck install.sh` — sem erros.
- `grep` de branding (Itaú/360i/Orange Book/WAF/RTK/Artifactory/iupipes) fora de `migration-docs/` — **0 ocorrências**.
- Inventário final em `migration-docs/final-state/`.
