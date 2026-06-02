# Análise do repo de origem — `itau-corp-commons/itau-lt6-scm-agent-skills`

Repositório clonado com sucesso (proxy/git-manager corporativo).

## Estrutura
- `skills/` — 39 skills (mix de `itau-*` corporativas + genéricas família "superpowers"/mattpocock)
- `hooks/` — session-start por IDE (claude/cursor/windsurf/vscode/devin/gemini) + `session-start-base.sh` + hooks RTK (rewrite/suggest)
- `tools/` — `dotnet-install.sh`, `git-cleanup-scan.sh`, `patch-scanner.cjs`, `packages-microsoft-prod.deb`
- `mcps/`, `docs/`, `devin/knowledge_sources/` (muitas `itau-*`), `devin/playbooks/`
- `rules/`, `registry.json`, `package.json`, `package-lock.json`, `install.sh` (60KB), `rm-backup.sh`
- `AGENTS.md`, `AGENTS_CLI.md`, `CLAUDE.md`, `README.md` (35KB)

## Classificação para migração

### Migrado (genérico, agnóstico, alto valor)
**Skills (20):** `brainstorming`, `building-mcp-servers`, `caveman`, `caveman-commit`, `caveman-compress`, `caveman-review`, `defuddle`, `dispatching-parallel-agents`, `executing-plans`, `finishing-a-development-branch`, `json-canvas`, `receiving-code-review`, `requesting-code-review`, `subagent-driven-development`, `systematic-debugging`, `test-driven-development`, `using-git-worktrees`, `verification-before-completion`, `writing-plans`, `writing-skills`.

**Hooks:** todo o `hooks/` (session-start por IDE + base), **menos** os scripts RTK.

### NÃO migrado
- **Skills `itau-*`** (canal-360, ceep, datadog, dotnet-*, ids-design-system, testing-jest-cypress): corporativas/domínio Itaú.
- **`create-agent-harness`**: casa com o padrão de remoção `create-*` da demanda.
- **`angular-signals`, `angular-ssr`**: padrão de remoção `angular-*`.
- **`rtk-token-killer`** + hooks RTK (`rtk-rewrite.sh`, `rtk-suggest.sh`, `windsurf/rules.md`): acoplados ao tooling corporativo RTK (download via token corporativo).
- **`registry.json`, `package.json`, `package-lock.json`, `patch-scanner.cjs`, `tools/*`, `mcps/`, `devin/knowledge_sources/itau-*`, `devin/playbooks`, `rules/`, `AGENTS_CLI.md`, `docs/`, `*ignore`**: corporativo, específico de origem, ou fora do escopo enxuto.

## Sanitização aplicada nos itens migrados
- Removido `ORANGEBOOK.md` de todas as skills (catálogo corporativo pt-BR).
- Frontmatter reduzido para `name`/`description` (+`when_to_use`/`allowed-tools` quando funcionais); removidos `metadata.{community: Integração Digital, rt: Portais, squad: 360, author: adnsasp, visibility}` e `license: UNLICENSED` (alinha ao padrão das skills do alvo).
- Removidas notas "Itaú/360i", "Confluence/Orange Book", convenção de branch corporativa, WAF, Artifactory/`.iupipes.yml`, referências a `rules/global-rules.instructions.md` e a `create-agent-harness` (skill não migrada).
- Hooks: comentários e `SESSION_CONTEXT` genéricos; `hooks/README.md` reescrito (sem RTK), com diagrama Mermaid.
- Atribuição upstream preservada (obra/superpowers, mattpocock, JuliusBrussee — MIT).
