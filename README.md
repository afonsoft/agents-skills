# agents-skills

A collection of **Agent Skills** (and session-start **hooks**) to enhance AI coding agents across multiple IDEs and CLIs. Each skill is a self-contained `SKILL.md` (per the [Agent Skills specification](https://agentskills.io)) with optional bundled resources, following harness engineering principles for agent-centered development.

> This repository distributes **skills + hooks only**. There is no `rules/` or `knowledge/` folder — project-specific guidance belongs in your own `AGENTS.md`/`CLAUDE.md`.

**🌐 Languages**: [English](README.md) | [Português](README.pt-br.md)

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
./install.sh --devin-desktop
./install.sh --devin-cli
./install.sh --claude
./install.sh --opencode
./install.sh --antigravity
./install.sh --agy

# Combine targets
./install.sh --cursor --vscode

# Preview without changing anything
./install.sh --devin --dry-run
```

### Supported IDEs/CLIs

| Tool | Skills | Hooks |
|------|--------|-------|
| Devin | `~/.devin/skills`, `~/.cognition/skills` | `~/.devin/hooks` |
| Devin CLI | `~/.config/devin/skills` | `~/.config/devin/hooks` |
| Devin Desktop | `~/.devin/skills` | `~/.devin/hooks` |
| OpenCode | `~/.opencode/skills`, `~/.config/opencode/skills` | `~/.opencode/hooks`, `~/.config/opencode/hooks` |
| OpenCode Desktop | `~/.opencode/skills` | `~/.opencode/hooks` |
| OpenCode CLI | `~/.config/opencode/skills` | `~/.config/opencode/hooks` |
| Claude Code | `~/.claude/skills` | `~/.claude/hooks` |
| Cursor | `~/.cursor/skills` | `~/.cursor/hooks` |
| VS Code (Copilot) | `~/.github/skills` | `~/.github/hooks` |
| Gemini CLI | `~/.gemini/skills` | `~/.gemini/hooks` |
| Google Antigravity IDE | `~/.gemini/skills` | `~/.gemini/hooks` |
| Google Antigravity CLI (agy) | `~/.gemini/antigravity-cli/skills` | `~/.gemini/antigravity-cli/hooks` |
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

# Configure for specific agents
./install-ai-tools.sh --rtk --gemini              # RTK for Gemini CLI
./install-ai-tools.sh --caveman --devin           # Caveman for Devin CLI
./install-ai-tools.sh --rtk --devin               # RTK for Devin CLI
./install-ai-tools.sh --rtk --opencode            # RTK for OpenCode
./install-ai-tools.sh --all --all-agents          # All tools for all agents

# Safe preview mode
./install-ai-tools.sh --all --dry-run

# Verbose mode
./install-ai-tools.sh --all --verbose
```

**Error Handling**: The script continues installation even if individual components fail. Each installation attempt is tracked separately, and warnings are displayed for failures. A summary at the end shows which components succeeded and which failed, allowing you to address specific issues without re-running successful installations.

### Agent-Specific Configuration

The installer supports agent-specific configuration for optimal integration:

#### Gemini CLI
- **RTK**: Native support via `rtk init -g --gemini`
- **Caveman**: Auto-detected and installed by Caveman installer
- **Superpowers**: Not yet supported (use Claude Code instead)

#### Devin CLI
- **RTK**: Manual configuration via AGENTS.md (no native support yet)
- **Caveman**: Installed via `npx skills add JuliusBrussee/caveman -a devin`
- **Superpowers**: Manual skill installation (no native support yet)
- **Docs**: [Devin CLI Setup](docs/devin-cli-setup.md)

#### Devin Desktop
- **RTK**: Manual configuration via AGENTS.md
- **Caveman**: Auto-detected if Devin Desktop is installed
- **Superpowers**: Manual skill installation (no native support yet)
- **Docs**: [Devin Desktop Setup](docs/devin-desktop-setup.md)

#### OpenCode CLI
- **RTK**: Plugin support via `rtk init -g --opencode`
- **Caveman**: Installed via `npx -y github:JuliusBrussee/caveman -- --only opencode`
- **Superpowers**: Manual skill installation to `~/.config/opencode/skills/`
- **Docs**: [OpenCode CLI Setup](docs/opencode-cli-setup.md)

#### OpenCode Desktop
- **RTK**: Plugin support via `rtk init -g --opencode`
- **Caveman**: Auto-detected if OpenCode Desktop is installed
- **Superpowers**: Manual skill installation to `~/.opencode/skills/`
- **Docs**: [OpenCode Desktop Setup](docs/opencode-desktop-setup.md)

#### Claude Code
- **RTK**: Native support via `rtk init -g`
- **Caveman**: Auto-detected and installed
- **Superpowers**: Native plugin marketplace support

#### Cursor
- **RTK**: Native support via `rtk init -g --agent cursor`
- **Caveman**: Auto-detected and installed
- **Superpowers**: Native plugin support

### Support Matrix

| Tool | Gemini CLI | Devin CLI | Devin Desktop | OpenCode CLI | OpenCode Desktop | Claude Code | Cursor |
|------|------------|-----------|---------------|--------------|------------------|-------------|--------|
| **RTK** | ✅ Native | ⚠️ Manual | ⚠️ Manual | ✅ Plugin | ✅ Plugin | ✅ Native | ✅ Native |
| **Caveman** | ✅ Auto | ✅ npx | ✅ Auto | ✅ Plugin | ✅ Plugin | ✅ Auto | ✅ Auto |
| **Superpowers** | ❌ No | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ✅ Native | ✅ Native |

**Legend:**
- ✅ Native/Full: Automatic installation with full support
- ⚠️ Manual: Requires manual configuration or partial support
- ❌ No: Not supported or requires alternative solution

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
- [AI Tools Installer Guide](AI-TOOLS-INSTALLER.md) — Comprehensive guide for RTK, Caveman, Superpowers installation
- [RTK & Caveman Support Matrix](RTK_CAVEMAN_SUPPORT.md) — Platform support status and configuration guidance
- [Contributing Guidelines](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)

## 📝 Recent Updates

### AI Tools Installer Enhancements
- **Agent-Specific Configuration**: Added support for Gemini CLI, Devin CLI, Devin Desktop, OpenCode CLI, OpenCode Desktop, and OpenCode plugin integrations (RTK, Caveman)
- **Shell Detection**: Improved Windows support with PowerShell, Git Bash, and WSL detection
- **Error Handling**: Enhanced error handling with continuation on individual failures
- **Configuration Matrix**: Added support matrix showing tool support per agent
- **Comprehensive Documentation**: Created detailed AI-TOOLS-INSTALLER.md guide

### Tool Path Updates
- **Devin Desktop Support**: Added support for Devin Desktop (local IDE successor to Windsurf)
- **Devin CLI Paths**: Updated to `~/.config/devin/`
- **OpenCode Support**: Added `~/.opencode/` and `~/.config/opencode/` paths, session hooks, and RTK/Caveman plugin configuration for Desktop and CLI
- **Legacy Cleanup**: Removed Windsurf paths; OpenClaw kept as legacy option

### Enhanced Scripts
- **git-cleanup-repos.sh**: Added cross-platform package manager cleanup (npm, yarn, nuget) and disk space tracking
- **rm-backup.sh**: Added `--uninstall` option for complete removal of installations and backups
- **install-ai-tools.sh**: New unified installer for RTK, Caveman, and Superpowers with agent-specific configuration

### Skill Quality Improvements
- Updated 11 skill descriptions to follow writing-skills specification
- All descriptions now start with "Use when..." pattern
- Removed process details from descriptions, focusing on triggering conditions
- Enhanced Claude Search Optimization (CSO) compliance

## 📄 License

Licensed under the [MIT License](LICENSE).

## 🔗 Related Projects

- [Agent Skills Specification](https://agentskills.io/specification)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [RTK - Rust Token Killer](https://www.rtk-ai.app/)
- [Caveman - Token Optimization Stack](https://getcaveman.dev/)
- [Superpowers - Structured Development Skills](https://claude.com/plugins/superpowers)
