# agents-skills

A collection of **Agent Skills** (and session-start **hooks**) to enhance AI coding agents across multiple IDEs and CLIs. Each skill is a self-contained `SKILL.md` (per the [Agent Skills specification](https://agentskills.io)) with optional bundled resources, following harness engineering principles for agent-centered development.

> This repository distributes **skills + hooks only**. There is no `rules/` or `knowledge/` folder — project-specific guidance belongs in your own `AGENTS.md`/`CLAUDE.md`.

## 🚀 Features

- **📋 Skills** — Self-contained, task-specific instructions with bundled resources
- **🪝 Hooks** — Session-start hooks that inject the installed skills catalog into the agent context
- **⚡ Workflows** — Agentic workflows for GitHub Actions automation
- **🛠️ Installer** — One script to install skills + hooks across IDEs/CLIs
- **🧹 Utility scripts** — System maintenance and cleanup tools
- **⚡ AI Tools** — Unified installer for RTK, Caveman, and Superpowers

## 📁 Repository Structure

```
agents-skills/
├── skills/              # Agent Skills (SKILL.md format)
├── hooks/               # Session-start hooks per IDE
├── workflows/           # Agentic workflows for automation
├── .agents/             # Harness infrastructure (CONTEXT, RULES, TOOLS, ...)
├── install.sh           # Installer (--all, --devin, --claude, --cursor, ...)
├── install-ai-tools.sh  # AI Tools Installer (RTK, Caveman, Superpowers)
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
| Devin Desktop | `~/.devin/skills`, `~/.codeium/windsurf/skills` (legacy) | `~/.devin/hooks` |
| Claude Code | `~/.claude/skills` | `~/.claude/hooks` |
| Cursor | `~/.cursor/skills` | `~/.cursor/hooks` |
| Windsurf (legacy) | `~/.windsurf/skills` | `~/.windsurf/hooks` |
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

## ⚡ AI Tools Installer

The `install-ai-tools.sh` script provides unified installation of popular AI optimization tools:

### RTK (Rust Token Killer)
- **Purpose**: Token optimizer that automatically rewrites terminal commands
- **Savings**: Reduces token usage by filtering command output (e.g., showing only test failures)
- **Support**: Claude Code, VS Code Copilot, Cursor, Gemini CLI, OpenCode, OpenClaw
- **Installation**: Auto-detects correct RTK (Token Killer vs Type Kit), initializes hooks

### Caveman
- **Purpose**: Token optimization stack with 5 integrated tools
- **Features**: Compressed communication, commit optimization, review enhancement
- **Support**: Claude Code, Cursor, Gemini CLI, OpenCode, OpenClaw, Codex CLI
- **Installation**: One-line install that auto-detects and configures all installed agents

### Superpowers
- **Purpose**: Structured development skills framework
- **Skills**: Brainstorming, TDD, systematic debugging, writing-skills, subagent development
- **Support**: Claude Code (plugin marketplace), Cursor, OpenCode, Codex, Gemini CLI
- **Installation**: Via Claude Code plugin marketplace (official or community)

### Usage
```bash
# Install all AI tools
./install-ai-tools.sh --all

# Install specific tools
./install-ai-tools.sh --rtk
./install-ai-tools.sh --caveman
./install-ai-tools.sh --superpowers

# Combine tools
./install-ai-tools.sh --rtk --caveman

# Safe preview mode
./install-ai-tools.sh --all --dry-run

# Verbose mode
./install-ai-tools.sh --all --verbose
```

**Error Handling**: The script continues installation even if individual components fail. Each installation attempt is tracked separately, and warnings are displayed for failures. A summary at the end shows which components succeeded and which failed, allowing you to address specific issues without re-running successful installations.

### Cross-Platform Support
- **Linux**: Full support via shell scripts
- **macOS**: Full support via shell scripts and Homebrew
- **Windows**: Support via WSL or Git Bash (native Windows has limited hook support)

### Features
- **Auto-detection**: Detects OS and installed agents automatically
- **Safety checks**: Pre-installation verification to avoid conflicts
- **Dry-run mode**: Preview changes before execution
- **Verbose logging**: Detailed installation progress
- **Post-installation verification**: Confirms successful setup
- **Error handling**: Continues installation even if individual components fail, with clear warnings

## 🛠️ Utility Scripts

### install-ai-tools.sh
Unified installer for AI optimization tools (RTK, Caveman, Superpowers):
```bash
./install-ai-tools.sh --all                    # Install all tools
./install-ai-tools.sh --rtk --caveman         # Install specific tools
./install-ai-tools.sh --all --dry-run         # Preview changes
./install-ai-tools.sh --all --verbose         # Detailed output
```

### rm-backup.sh
Removes `*.backup.*` files/dirs created by the installer:
```bash
./rm-backup.sh                    # Remove backups only
./rm-backup.sh --uninstall       # Remove backups AND complete installations
./rm-backup.sh --dry-run         # Preview what would be removed
./rm-backup.sh --verbose         # Detailed output
```

### clear-up-linux.sh
Linux system cleanup with many categories (see [CLEAR-UP-README.md](CLEAR-UP-README.md)):
```bash
sudo ./clear-up-linux.sh --dry-run --verbose   # simulate
sudo ./clear-up-linux.sh --force               # non-interactive
```

### git-cleanup-repos.sh
Recursive Git repository maintenance with disk space tracking:
```bash
chmod +x git-cleanup-repos.sh && ./git-cleanup-repos.sh
./git-cleanup-repos.sh --verbose           # Detailed output
./git-cleanup-repos.sh --dry-run           # Preview changes
```
**Features:**
- Git fetch, pull, reflog cleanup, garbage collection
- Build artifact removal (bin, obj, .vs, node_modules)
- Package manager cache cleanup (npm, yarn, nuget)
- Windows-specific cache directory cleanup
- **Disk space tracking**: Measures space before/after cleanup, displays recovered space
- **Cross-platform**: Linux, macOS, Windows support
- **Detailed logging**: All operations logged with timestamps

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

## � Recent Updates

### Tool Path Updates
- **Devin Desktop Support**: Added support for Devin Desktop (formerly Windsurf) with new path structure
- **Devin CLI Paths**: Updated from `~/.config/cognition/` to `~/.config/devin/`
- **Legacy Compatibility**: Maintains backward compatibility with Windsurf paths during transition

### Enhanced Scripts
- **git-cleanup-repos.sh**: Added cross-platform package manager cleanup (npm, yarn, nuget) and disk space tracking
- **rm-backup.sh**: Added `--uninstall` option for complete removal of installations and backups
- **install-ai-tools.sh**: New unified installer for RTK, Caveman, and Superpowers

### Skill Quality Improvements
- Updated 11 skill descriptions to follow writing-skills specification
- All descriptions now start with "Use when..." pattern
- Removed process details from descriptions, focusing on triggering conditions
- Enhanced Claude Search Optimization (CSO) compliance

## �📄 License

Licensed under the [MIT License](LICENSE).

## 🔗 Related Projects

- [Agent Skills Specification](https://agentskills.io/specification)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [RTK - Rust Token Killer](https://www.rtk-ai.app/)
- [Caveman - Token Optimization Stack](https://getcaveman.dev/)
- [Superpowers - Structured Development Skills](https://claude.com/plugins/superpowers)
