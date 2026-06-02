# agents-skills

A collection of **Agent Skills** (and session-start **hooks**) to enhance AI coding agents across multiple IDEs and CLIs. Each skill is a self-contained `SKILL.md` (per the [Agent Skills specification](https://agentskills.io)) with optional bundled resources, following harness engineering principles for agent-centered development.

> This repository distributes **skills + hooks only**. There is no `rules/` or `knowledge/` folder — project-specific guidance belongs in your own `AGENTS.md`/`CLAUDE.md`.

## 🚀 Features

- **📋 Skills** — Self-contained, task-specific instructions with bundled resources
- **🪝 Hooks** — Session-start hooks that inject the installed skills catalog into the agent context
- **⚡ Workflows** — Agentic workflows for GitHub Actions automation
- **🛠️ Installer** — One script to install skills + hooks across IDEs/CLIs
- **🧹 Utility scripts** — System maintenance and cleanup tools

## 📁 Repository Structure

```
agents-skills/
├── skills/              # Agent Skills (SKILL.md format)
├── hooks/               # Session-start hooks per IDE
├── workflows/           # Agentic workflows for automation
├── .agents/             # Harness infrastructure (CONTEXT, RULES, TOOLS, ...)
├── install.sh           # Installer (--all, --devin, --claude, --cursor, ...)
├── rm-backup.sh         # Removes *.backup.* files created by the installer
├── clear-up-linux.sh    # Linux system cleanup script
└── git-cleanup-repos.sh # Git repository maintenance script
```

## 🎯 Quick Start

```bash
# Install skills + hooks + AGENTS.md for all supported IDEs/CLIs
./install.sh --all

# Install for a specific tool
./install.sh --devin
./install.sh --claude

# Combine targets
./install.sh --cursor --vscode

# Preview without changing anything
./install.sh --devin --dry-run
```

### Supported IDEs/CLIs

| Tool | Skills | Hooks |
|------|--------|-------|
| Devin / Devin CLI | `~/.devin/skills`, `~/.config/devin/skills` | `~/.devin/hooks` |
| Claude Code | `~/.claude/skills` | `~/.claude/hooks` |
| Cursor | `~/.cursor/skills` | `~/.cursor/hooks` |
| Windsurf | `~/.windsurf/skills` | `~/.windsurf/hooks` |
| VS Code (Copilot) | `~/.github/skills` | `~/.github/hooks` |
| Gemini CLI | `~/.gemini/skills` | `~/.gemini/hooks` |
| Base (all) | `~/.agents/skills` | — |

## 🧰 Skills Catalog

### Agent workflow & productivity
`brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents`, `systematic-debugging`, `test-driven-development`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`, `finishing-a-development-branch`, `using-git-worktrees`, `writing-skills`, `find-skills`, `memory-merger`, `building-mcp-servers`, `json-canvas`, `defuddle`

### Compressed communication
`caveman`, `caveman-commit`, `caveman-compress`, `caveman-review`

### .NET / C#
`aspnet-core-api`, `modern-csharp-coding-standards`, `design-patterns`, `performance-optimization`, `security-jwt`, `testing-xunit`, `microsoft-agent-framework`, `microsoft-code-reference`, `microsoft-docs`, `microsoft-skill-creator`

### ABP Framework
`abp-angular`, `abp-app-nolayers`, `abp-application-layer`, `abp-authorization`, `abp-blazor`, `abp-cli`, `abp-core`, `abp-ddd`, `abp-dependency-rules`, `abp-development-flow`, `abp-ef-core`, `abp-infrastructure`, `abp-microservice`, `abp-module`, `abp-mongodb`, `abp-multi-tenancy`, `abp-mvc`, `abp-testing`, `migrate-aspnetboilerplate-to-abp`, `fluentui-blazor`

### Data / SQL
`ef-core`, `efcore-patterns`, `entity-framework-core`, `postgresql-code-review`, `postgresql-optimization`, `sql-code-review`, `sql-optimization`

### Frontend & review
`premium-frontend-ui`, `web-design-reviewer`, `chrome-devtools`

### Harness & meta
`harness-repo-structure`, `github-issues`

> Run `./install.sh --all` then start a session — the session-start hook injects the catalog so the agent can pick the right skill via each skill's `description` / `when_to_use`.

## 🛠️ Utility Scripts

### rm-backup.sh
Removes `*.backup.*` files/dirs created by the installer:
```bash
./rm-backup.sh
```

### clear-up-linux.sh
Linux system cleanup with many categories (see [CLEAR-UP-README.md](CLEAR-UP-README.md)):
```bash
sudo ./clear-up-linux.sh --dry-run --verbose   # simulate
sudo ./clear-up-linux.sh --force               # non-interactive
```

### git-cleanup-repos.sh
Recursive Git repository maintenance (fetch, gc, reflog cleanup, build-artifact removal):
```bash
chmod +x git-cleanup-repos.sh && ./git-cleanup-repos.sh
```

## 🤝 Contributing

See the [Contributing Guidelines](CONTRIBUTING.md).

1. **Fork** the repository
2. **Create** a feature branch
3. **Add** your skill (a folder under `skills/` with a valid `SKILL.md`) — the `writing-skills` skill is a good guide
4. **Validate**: `shellcheck install.sh` and `./install.sh --devin --dry-run`
5. **Open** a pull request

## 📖 Documentation

- [AGENTS.md](AGENTS.md) — Repository index and conventions
- [Contributing Guidelines](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)

## 📄 License

Licensed under the [MIT License](LICENSE).

## 🔗 Related Projects

- [Agent Skills Specification](https://agentskills.io/specification)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Agentic Workflows](https://github.github.com/gh-aw)
