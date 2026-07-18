# OpenCode CLI Setup Guide

OpenCode CLI is the terminal-based agent. It reads skills and rules from `~/.config/opencode/`.

## Installation

1. Install OpenCode CLI using the official installer:
   - https://opencode.dev/docs/cli

On most systems:

```bash
# If a Homebrew tap is available
brew install opencode-cli

# Or via npm if distributed
npm install -g opencode
```

If an official installer script exists, use it:

```bash
curl -fsSL https://opencode.dev/install.sh | sh
```

## Configure Agent Skills

Run the repository installer:

```bash
./install.sh --opencode-cli
```

This installs:
- `~/.config/opencode/skills/` — Agent Skills (SKILL.md)
- `~/.config/opencode/rules/` — Rule instructions
- `~/.config/opencode/rules.md` — Consolidated rules
- `~/.config/opencode/knowledge/` — Knowledge sources
- `~/.config/opencode/AGENTS.md` — Repository index
- `~/.config/opencode/hooks/` — Session-start hooks

## Verify

```bash
opencode --version
ls ~/.config/opencode/skills
ls ~/.config/opencode/hooks
```

## Usage

```bash
opencode
```

Start a session. The session-start hook injects the skills catalog. Mention a skill by name, for example:

```
use the writing-plans skill
```

## Update

```bash
./install.sh --opencode-cli
```

## Uninstall

```bash
rm -rf ~/.config/opencode/skills ~/.config/opencode/rules ~/.config/opencode/knowledge
rm -f ~/.config/opencode/rules.md ~/.config/opencode/AGENTS.md
```

Or use `rm-backup.sh --uninstall`.
