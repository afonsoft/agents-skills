# Mapa de migração (origem → destino)

| Origem (`itau-lt6-scm-agent-skills`) | Destino (`afonsoft/agents-skills`) | Ação |
|---|---|---|
| `skills/brainstorming` | `skills/brainstorming` | copiado + sanitizado (drop ORANGEBOOK, notas Itaú, stop-server comment) |
| `skills/building-mcp-servers` | `skills/building-mcp-servers` | copiado + sanitizado (Artifactory/iupipes removidos) |
| `skills/caveman` | `skills/caveman` | copiado + sanitizado (atribuição mattpocock; refs create-agent-harness removidas) |
| `skills/caveman-commit` | `skills/caveman-commit` | copiado + sanitizado |
| `skills/caveman-compress` | `skills/caveman-compress` | copiado + sanitizado |
| `skills/caveman-review` | `skills/caveman-review` | copiado + sanitizado |
| `skills/defuddle` | `skills/defuddle` | copiado + sanitizado |
| `skills/dispatching-parallel-agents` | `skills/dispatching-parallel-agents` | copiado + sanitizado |
| `skills/executing-plans` | `skills/executing-plans` | copiado + sanitizado |
| `skills/finishing-a-development-branch` | `skills/finishing-a-development-branch` | copiado + sanitizado |
| `skills/json-canvas` | `skills/json-canvas` | copiado + sanitizado |
| `skills/receiving-code-review` | `skills/receiving-code-review` | copiado + sanitizado |
| `skills/requesting-code-review` | `skills/requesting-code-review` | copiado + sanitizado |
| `skills/subagent-driven-development` | `skills/subagent-driven-development` | copiado + sanitizado |
| `skills/systematic-debugging` | `skills/systematic-debugging` | copiado + sanitizado |
| `skills/test-driven-development` | `skills/test-driven-development` | copiado + sanitizado |
| `skills/using-git-worktrees` | `skills/using-git-worktrees` | copiado + sanitizado |
| `skills/verification-before-completion` | `skills/verification-before-completion` | copiado + sanitizado |
| `skills/writing-plans` | `skills/writing-plans` | copiado + sanitizado |
| `skills/writing-skills` | `skills/writing-skills` | copiado + sanitizado (refs superpowers→skills locais) |
| `hooks/{devin,claude,cursor,windsurf,vscode,gemini}/` + `hooks/session-start-base.sh` | `hooks/...` | copiado + sanitizado (sem RTK; contexto genérico) |
| `hooks/**/rtk-*.sh`, `hooks/windsurf/rules.md` | — | **não migrado** (RTK corporativo) |
| `skills/itau-*`, `skills/angular-*`, `skills/create-agent-harness`, `skills/rtk-token-killer` | — | **não migrado** |
| `registry.json`, `package.json`, `package-lock.json`, `tools/`, `mcps/`, `rules/`, `devin/`, `docs/`, `AGENTS_CLI.md` | — | **não migrado** |

## Resumo
- **20 skills** genéricas migradas + **hooks** de session-start de 6 IDEs.
- Nenhum arquivo corporativo (`registry.json`/`package.json`/`patch-scanner.cjs`/`ORANGEBOOK.md`) trazido.
