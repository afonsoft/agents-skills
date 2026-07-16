---
description: >
  Gera ou atualiza README.md e CHANGELOG.md em um repositório alvo.
  Orienta o agente a analisar a estrutura de diretórios, stack tecnológica,
  cobertura de testes e histórico de commits para produzir documentação clara,
  navegável e alinhada a Keep a Changelog + SemVer.
mode: agent
tools:
  - read
  - grep
  - find_file_by_name
  - exec
  - git_create_pr
  - git_view_pr
---

# README and CHANGELOG Generation

## Role
Senior SRE Engineer / Technical Writer.

## Goal
Analyze the target repository `{REPO_NAME}` and generate (or update) a
professional `README.md` and a `CHANGELOG.md` following best practices.

## Input
- `REPO_NAME`: full repository name (e.g. `owner/repo`).
- `BASE_BRANCH`: branch to start from (default: `main` or `develop`).
- `OUTPUT_BRANCH`: `feature/{YYYYMMDD}-readme-changelog`.

---

## Phase 1 — Discovery

Read and inspect:
- Root directory tree and top-level files.
- `package.json`, `*.csproj`, `pom.xml`, `build.gradle`, `pyproject.toml`,
  `requirements.txt`, `Dockerfile`, `docker-compose.yml`.
- `.github/workflows/` and any CI/CD definitions.
- Existing `README.md` and `CHANGELOG.md` (if any).
- Git history: `git log --oneline -n 50`.
- Test/coverage reports if available (e.g. `coverage/`, `TestResults/`).

Document findings in this format before generating files:

```
Discovery Summary:
- Stack: {languages, frameworks, runtimes}
- Architecture: {patterns found}
- CI/CD: {pipelines and tools}
- Integrations: {DataDog, OpenTelemetry, AWS, Azure, Terraform, etc.}
- Gaps in current README/CHANGELOG: {list}
```

---

## Phase 2 — README.md Generation

### Structure
The generated README must contain, in order:

1. `# <Project Name>` title.
2. Badges (CI, coverage, version, license) when detectable.
3. **Descrição do Projeto** — rich functional and strategic description.
4. **Estrutura do Repositório** — hierarchical tree with a short description per file/folder.
5. **Stack Tecnológica** — languages, frameworks, tools, cloud services.
6. **Arquitetura** — layers, patterns (Clean Architecture, DDD, MVC, etc.).
7. **Fluxo do Sistema** — Mermaid diagrams or textual flow when applicable.
8. **Como Rodar** — prerequisites, environment variables, build and run commands.
9. **Testes e Cobertura** — commands, total tests, line/branch coverage.
10. **Visão de Negócio** — functional/strategic view.
11. **Visão Técnica** — architecture, dependencies, implementation notes.
12. **Desenvolvedores / Contribuintes** — only if explicitly referenced.
13. **Licença** — if missing, state "Uso interno exclusivo".
14. **Status do Projeto** — if no progress is indicated, mark as "Concluído".
15. **Links** — internal references converted to clickable Markdown links,
    including a link to `CHANGELOG.md`.

### Rules
- Reuse and extend the existing `README.md` whenever it exists.
- Fix typos and add language annotations to code blocks.
- Keep indentation aligned with the directory hierarchy.
- Write conditional sections only when concrete data is available.
- Use Portuguese (pt-BR) by default unless the repository is clearly English-only.
- Avoid inventing information; every statement must be evidenced by files or commits.

---

## Phase 3 — CHANGELOG.md Generation

### Rules
- Follow [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) format.
- Use [Semantic Versioning](https://semver.org/lang/pt-BR/).
- Analyze recent commits to populate `Added`, `Changed`, `Deprecated`,
  `Removed`, `Fixed`, and `Security` sections.
- Maintain a `[Unreleased]` section at the top.
- Link version numbers to tags or compare URLs when available.
- Add a `CHANGELOG.md` link in the generated/updated `README.md`.

### Suggested Categories
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be-removed features.
- `Removed` for now-removed features.
- `Fixed` for bug fixes.
- `Security` for vulnerability fixes.

---

## Phase 4 — Delivery

1. Ensure the target repository is cloned and on the correct base branch.
2. Create branch `feature/{YYYYMMDD}-readme-changelog`.
3. Apply changes to `README.md` and `CHANGELOG.md`.
4. Run a Markdown linter if available (`markdownlint-cli` or similar).
5. Prepare a commit with Conventional Commit message:
   `docs(readme): atualiza README e CHANGELOG` (or English equivalent).
6. **Do not open the Pull Request automatically.** Prepare the branch and a
   detailed summary of changes so the user can open the PR manually.

---

## Architecture & Style References

### SOLID
- Justify documentation structure with **Single Responsibility** and
  **Dependency Inversion** where code examples are included.

### DDD
- If domain examples are shown, use Aggregate, Entity, Value Object,
  Repository terminology.

### Clean Architecture
- Clarify layer separation: Domain, Application, Infrastructure, Presentation.

---

## Restrictions

- Do not analyze repositories other than `{REPO_NAME}`.
- Do not open Pull Request automatically; prepare the commit and report only.
- Do not commit secrets, credentials, or environment files.
