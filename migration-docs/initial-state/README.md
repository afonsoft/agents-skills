# Estado inicial — `afonsoft/agents-skills`

Snapshot tirado antes de qualquer modificação (branch `feat/simplify-agents-skills-and-migrate-core`, base `main`).

## Estrutura raiz
- `skills/` — 85 diretórios de skills
- `rules/` — 107 arquivos `*.instructions.md`
- `workflows/` — 7 workflows agentic
- `knowledge/` — ~23 docs (design-docs, references, exec-plans, raiz)
- `.agents/` — harness docs (CONTEXT, RULES, MEMORY, TOOLS, WORKFLOWS, README, etc.)
- Scripts: `install.sh` (988 linhas), `rm-backup.sh`, `clear-up-linux.sh`, `git-cleanup-repos.sh`
- Docs: `README.md`, `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `LICENSE`, `CODEOWNERS`, `INSTALLATION_VALIDATION.md`, `CLEAR-UP-README.md`, `RM-BACKUP-IMPROVEMENTS.md`, `harness-engineering.txt`, `llms.txt`
- Ignore files: `.claudeignore`, `.devinignore`, `.windsurfignore`

## Observações
- **Sem branding ITAU** e **sem** `package.json`/`registry.json`/`patch-scanner.cjs`/`ORANGEBOOK.md` (presentes apenas no repo de origem `itau-lt6-scm-agent-skills`).
- Referências quebradas a `npm run skill:*` e `npm run build` em `README.md` e `CONTRIBUTING.md` (não há `package.json`).
- `install.sh` copia skills + rules + knowledge para múltiplas IDEs e gera "consolidated rules".

## Skills marcadas para remoção (41) — padrões da demanda
`angular-*` (10), `create-*` (10), `csharp-*` (8), `dotnet-*` (9), `blazor-components`, `javascript-typescript-jest`.

Arquivos detalhados: ver `files-maxdepth3.txt`, `skills-files.txt`, `knowledge-files.txt`, `rules-files.txt`, `workflows-files.txt`, `git-ls-files.txt`.
