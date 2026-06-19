# AI Tools Installer Documentation

Comprehensive guide for the `install-ai-tools.sh` script - unified installer for RTK, Caveman, and Superpowers across multiple AI coding agents.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Tool Descriptions](#tool-descriptions)
- [Agent Configuration](#agent-configuration)
- [Platform Support](#platform-support)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)

## Overview

The `install-ai-tools.sh` script provides a unified interface for installing and configuring AI optimization tools across multiple coding agents. It handles:

- **RTK (Rust Token Killer)**: Terminal command optimization
- **Caveman**: Token compression stack (5 tools)
- **Superpowers**: Structured development skills framework

### Key Features

- **Cross-platform**: Linux, macOS, Windows (PowerShell, Git Bash, WSL)
- **Agent-specific**: Optimized configuration per AI agent
- **Error handling**: Continues on individual failures with clear warnings
- **Safe modes**: Dry-run and verbose options for safe testing
- **Auto-detection**: Detects OS, shells, and installed agents

## Installation

### Prerequisites

- **Linux/macOS**: Bash shell, curl
- **Windows**: PowerShell, Git Bash, or WSL
- **Node.js**: Required for Caveman and some agent integrations
- **Rust**: Optional, for RTK alternative installation

### Basic Installation

```bash
# Make script executable
chmod +x install-ai-tools.sh

# Install all tools for default agent (Claude Code)
./install-ai-tools.sh --all

# Install specific tools
./install-ai-tools.sh --rtk
./install-ai-tools.sh --caveman
./install-ai-tools.sh --superpowers
```

## Tool Descriptions

### RTK (Rust Token Killer)

**Purpose**: Automatically rewrites terminal commands to reduce token usage by 60-90%.

**How it works**:
- Intercepts shell commands before agent execution
- Filters output to show only relevant information
- Example: `cargo test` → shows only failures, not 500 lines of passing tests

**Supported ecosystems**:
- Git (status, diff, log)
- Cargo/Rust (test, build, check)
- npm/JavaScript (test, build)
- Python (pytest, pip)
- Go (test, build)
- Docker/Kubernetes
- .NET (dotnet test, build)

**Installation methods**:
1. Official script (recommended): `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh`
2. Homebrew: `brew install rtk-ai/tap/rtk`
3. Cargo: `cargo install --git https://github.com/rtk-ai/rtk rtk`

**Important**: Verify correct installation (Token Killer, not Type Kit):
```bash
rtk --version    # Should show version
rtk gain         # Should show token savings (NOT "command not found")
```

### Caveman

**Purpose**: Token optimization stack with 5 integrated tools for compressed communication.

**Components**:
1. **caveman**: Main communication compression (65% token reduction)
2. **caveman-commit**: Commit message optimization
3. **caveman-compress**: Output compression
4. **caveman-review**: Code review optimization
5. **cavemem**: Memory compression

**How it works**:
- Removes articles, filler, and pleasantries
- Maintains technical accuracy
- Supports 6 communication modes
- ~75% smaller via Caveman compression

**Installation**:
```bash
# One-line install (auto-detects all agents)
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex
```

### Superpowers

**Purpose**: Structured development skills framework for disciplined software engineering.

**Skills included**:
- **brainstorming**: Socratic requirement refinement before coding
- **test-driven-development**: Red-green-refactor TDD cycles
- **systematic-debugging**: Four-phase debugging methodology
- **writing-skills**: TDD principles applied to documentation
- **subagent-driven-development**: Code review and checkpointed development

**How it works**:
- Mandatory workflows (not suggestions)
- Skills loaded automatically at session start
- Agent must invoke skill when applicable (even 1% chance)
- Enforces disciplined practices

**Installation**:
```bash
# Claude Code (official marketplace)
/plugin install superpowers@claude-plugins-official

# Claude Code (community marketplace)
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

## Agent Configuration

### Gemini CLI

**Configuration paths**:
- Config: `~/.gemini/settings.json`
- Hooks: `~/.gemini/hooks/`
- Skills: `~/.gemini/skills/`

**RTK Configuration**:
```bash
./install-ai-tools.sh --rtk --gemini
```

**What gets installed**:
- `~/.gemini/hooks/rtk-hook-gemini.sh` - Native Rust hook processor
- `~/.gemini/GEMINI.md` - RTK awareness instructions
- `~/.gemini/settings.json` - Patched with BeforeTool hook

**Usage**:
```bash
# Automatic rewriting (transparent)
# When Gemini CLI runs: git status
# RTK intercepts and runs: rtk git status

# Check savings
rtk gain
```

**Caveman Configuration**:
```bash
./install-ai-tools.sh --caveman --gemini
```

**What gets installed**:
- Auto-detected by Caveman installer
- Skills: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

### Devin CLI

**Configuration paths**:
- Config: `~/.config/devin/config.json` (Linux/Mac)
- Config: `%APPDATA%\devin\config.json` (Windows)
- Skills: `~/.config/devin/skills/` or `~/.devin/skills/`
- AGENTS.md: `~/.config/devin/AGENTS.md`

**RTK Configuration**:
```bash
./install-ai-tools.sh --rtk --devin
```

**What gets installed**:
- `~/.config/devin/AGENTS.md` - Manual RTK instructions
- No native hook support yet (manual usage required)

**Usage**:
```bash
# Manual usage (prefix with rtk)
rtk git status
rtk cargo test
rtk npm test

# Check savings
rtk gain
```

**Caveman Configuration**:
```bash
./install-ai-tools.sh --caveman --devin
```

**What gets installed**:
- Via `npx skills add JuliusBrussee/caveman -a devin`
- Skills: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

**Superpowers Configuration**:
```bash
./install-ai-tools.sh --superpowers --devin
```

**What gets installed**:
- Manual skill installation instructions
- Requires copying skills from Superpowers repository
- No native support yet

### Devin Desktop

**Configuration paths**:
- Config: `~/.config/devin/config.json` (Linux/Mac)
- Config: `%APPDATA%\devin\config.json` (Windows)
- Skills: `~/.devin/skills/` or `~/.codeium/windsurf/skills/` (legacy)
- Legacy paths: `~/.windsurf/skills/` (Windsurf compatibility)

**RTK Configuration**:
```bash
./install-ai-tools.sh --rtk --devin-desktop
```

**What gets installed**:
- Same as Devin CLI (AGENTS.md instructions)
- Located at `~/.config/devin/AGENTS.md`

**Caveman Configuration**:
```bash
./install-ai-tools.sh --caveman --devin-desktop
```

**What gets installed**:
- Auto-detects Devin Desktop installation
- Also detects legacy Windsurf paths for compatibility
- Skills: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

**Superpowers Configuration**:
```bash
./install-ai-tools.sh --superpowers --devin-desktop
```

**What gets installed**:
- Use Claude Code integration (Devin Desktop uses Claude Code backend)
- Install via Claude Code plugin marketplace
- Skills available in Devin Desktop sessions

### Claude Code

**Configuration paths**:
- Config: `~/.claude/settings.json`
- Hooks: `~/.claude/hooks/`
- Skills: `~/.claude/skills/`

**RTK Configuration**:
```bash
./install-ai-tools.sh --rtk --claude
```

**What gets installed**:
- `~/.claude/hooks/rtk-rewrite.sh` - Shell hook for command rewriting
- `~/.claude/RTK.md` - RTK awareness (10 lines, meta commands only)
- `~/.claude/settings.json` - Patched with PreToolUse hook
- `~/.claude/CLAUDE.md` - Adds @RTK.md reference

**Usage**:
```bash
# Automatic rewriting (transparent)
# When Claude Code runs: git status
# RTK intercepts and runs: rtk git status

# Check savings
rtk gain
```

**Caveman Configuration**:
```bash
./install-ai-tools.sh --caveman --claude
```

**What gets installed**:
- Via `claude plugin marketplace add JuliusBrussee/caveman`
- Skills: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

**Superpowers Configuration**:
```bash
./install-ai-tools.sh --superpowers --claude
```

**What gets installed**:
- Via `/plugin install superpowers@claude-plugins-official`
- Skills: brainstorming, TDD, systematic debugging, writing-skills

### Cursor

**Configuration paths**:
- Config: `~/.cursor/settings.json`
- Hooks: `~/.cursor/hooks.json`
- Skills: `~/.cursor/skills/`

**RTK Configuration**:
```bash
./install-ai-tools.sh --rtk --cursor
```

**What gets installed**:
- Cursor hook in `~/.cursor/hooks.json`
- Transparent command rewriting

**Caveman Configuration**:
```bash
./install-ai-tools.sh --caveman --cursor
```

**What gets installed**:
- Via `npx skills add JuliusBrussee/caveman -a cursor`
- Skills: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

**Superpowers Configuration**:
```bash
./install-ai-tools.sh --superpowers --cursor
```

**What gets installed**:
- Via Cursor plugin marketplace
- Skills: brainstorming, TDD, systematic debugging

## Platform Support

### Linux

**Full support** for all tools and agents:
- Shell scripts work natively
- All hooks function correctly
- Package managers: apt, yum, dnf, etc.

**Installation**:
```bash
./install-ai-tools.sh --all --all-agents
```

### macOS

**Full support** for all tools and agents:
- Shell scripts work natively
- Homebrew available for alternative installations
- All hooks function correctly

**Installation**:
```bash
./install-ai-tools.sh --all --all-agents
```

**Alternative via Homebrew**:
```bash
# RTK
brew install rtk-ai/tap/rtk
```

### Windows

**Support varies by shell**:

#### Git Bash (Recommended)
- **Full support** for all tools and agents
- Hooks work correctly
- Best compatibility

**Installation**:
```bash
# Run in Git Bash
./install-ai-tools.sh --all --all-agents
```

#### PowerShell
- **Limited support** for RTK (no hooks)
- **Manual installation** required for Caveman
- **No hook support** for command rewriting

**Installation**:
```bash
# Run in PowerShell
.\install-ai-tools.sh --all --all-agents
```

**Manual Caveman installation**:
```powershell
irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex
```

#### WSL (Windows Subsystem for Linux)
- **Full support** (same as Linux)
- **Recommended** for complete hook support
- Best option for Windows users

**Installation**:
```bash
# Run in WSL
./install-ai-tools.sh --all --all-agents
```

## Advanced Usage

### Dry-Run Mode

Preview changes without executing:
```bash
./install-ai-tools.sh --all --dry-run
```

**Output**: Shows what would be installed/modified without making changes.

### Verbose Mode

Detailed installation progress:
```bash
./install-ai-tools.sh --all --verbose
```

**Output**: Detailed logging of each step, useful for debugging.

### Combined Options

Multiple options can be combined:
```bash
# Install RTK for Gemini CLI with verbose output
./install-ai-tools.sh --rtk --gemini --verbose

# Install all tools for all agents with dry-run
./install-ai-tools.sh --all --all-agents --dry-run

# Install Caveman for Devin CLI and Claude Code
./install-ai-tools.sh --caveman --devin --claude
```

### Error Handling

The script continues on individual failures:
```bash
./install-ai-tools.sh --all --all-agents
```

**Behavior**:
- If RTK fails, continues to Caveman
- If Caveman fails, continues to Superpowers
- Shows warnings for failures
- Displays summary at end
- Allows re-running only failed components

### Selective Installation

Install only specific tools for specific agents:
```bash
# RTK for Gemini CLI only
./install-ai-tools.sh --rtk --gemini

# Caveman for Devin CLI only
./install-ai-tools.sh --caveman --devin

# Superpowers for Claude Code only
./install-ai-tools.sh --superpowers --claude
```

## Troubleshooting

### RTK Installation Issues

**Problem**: RTK gain shows "command not found"
**Solution**: Wrong RTK installed (Type Kit instead of Token Killer)
```bash
# Uninstall wrong RTK
cargo uninstall rtk

# Reinstall correct RTK
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh

# Verify
rtk gain  # Should show token savings
```

**Problem**: RTK not found after cargo install
**Solution**: Cargo bin not in PATH
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.cargo/bin:$PATH"

# Reload shell
source ~/.bashrc
```

### Caveman Installation Issues

**Problem**: npx command not found
**Solution**: Install Node.js
```bash
# macOS
brew install node

# Ubuntu/Debian
sudo apt install nodejs npm

# Windows
# Download from https://nodejs.org/
```

**Problem**: Caveman not detected for agent
**Solution**: Manual installation
```bash
# For Devin CLI
npx skills add JuliusBrussee/caveman -a devin

# For Cursor
npx skills add JuliusBrussee/caveman -a cursor
```

### Superpowers Installation Issues

**Problem**: Claude Code plugin not found
**Solution**: Register marketplace first
```bash
/plugin marketplace add claude-plugins-official
/plugin install superpowers@claude-plugins-official
```

**Problem**: Skills not activating
**Solution**: Restart Claude Code
- Skills load at session start
- Start new chat session
- Ask: "Tell me about your superpowers"

### Windows-Specific Issues

**Problem**: PowerShell script fails
**Solution**: Use Git Bash or WSL
```bash
# Git Bash (recommended)
./install-ai-tools.sh --all

# WSL (full support)
wsl bash -c './install-ai-tools.sh --all'
```

**Problem**: Hooks not working on Windows
**Solution**: Use WSL for full hook support
```bash
# Install RTK in WSL
wsl bash -c 'curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh'
wsl bash -c 'rtk init -g'
```

### Agent-Specific Issues

**Problem**: Devin CLI not detecting tools
**Solution**: Check configuration paths
```bash
# Linux/Mac
ls ~/.config/devin/
cat ~/.config/devin/AGENTS.md

# Windows
ls %APPDATA%\devin\
type %APPDATA%\devin\AGENTS.md
```

**Problem**: Gemini CLI hooks not working
**Solution**: Restart Gemini CLI
```bash
# Gemini CLI needs restart after hook installation
# Exit and restart Gemini CLI
```

## Support and Resources

### Official Documentation
- **RTK**: https://www.rtk-ai.app/docs/
- **Caveman**: https://getcaveman.dev/
- **Superpowers**: https://claude.com/plugins/superpowers

### GitHub Repositories
- **RTK**: https://github.com/rtk-ai/rtk
- **Caveman**: https://github.com/JuliusBrussee/caveman
- **Superpowers**: https://github.com/obra/superpowers

### Issue Reporting
- RTK issues: https://github.com/rtk-ai/rtk/issues
- Caveman issues: https://github.com/JuliusBrussee/caveman/issues
- Superpowers issues: https://github.com/obra/superpowers/issues
- Installer issues: https://github.com/afonsoft/agents-skills/issues

## Best Practices

1. **Always verify installations**: Check `rtk gain` after RTK installation
2. **Use dry-run first**: Preview changes before executing
3. **Restart agents**: Most tools require agent restart after installation
4. **Check paths**: Verify configuration paths for your platform
5. **Use WSL on Windows**: For full hook support on Windows
6. **Update regularly**: Keep tools updated for latest features
7. **Monitor savings**: Use `rtk gain` to track token savings
8. **Test functionality**: Verify tools work after installation

## Version Information

- **Script version**: 1.0.0
- **Last updated**: 2025-06-18
- **Supported RTK**: 0.23.1+
- **Supported Caveman**: Latest from main branch
- **Supported Superpowers**: Latest from main branch
