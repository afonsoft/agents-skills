# Devin CLI Setup Guide

Devin CLI is the terminal-based agent. It reads skills and rules from `~/.config/devin/` (and falls back to `~/.devin/`).

## Installation

1. Install Devin CLI using the official installer:
   - https://cli.devin.ai/docs

On most systems:

```bash
# If a Homebrew tap is available
brew install devin-cli

# Or via npm if distributed
npm install -g @devin/cli
```

If an official installer script exists, use it:

```bash
curl -fsSL https://cli.devin.ai/install.sh | sh
```

## Configure Agent Skills

Run the repository installer:

```bash
./install.sh --devin-cli
```

This installs:
- `~/.config/devin/skills/` — Agent Skills (SKILL.md)
- `~/.config/devin/rules/` — Rule instructions
- `~/.config/devin/rules.md` — Consolidated rules
- `~/.config/devin/knowledge/` — Knowledge sources
- `~/.config/devin/AGENTS.md` — Repository index
- `~/.config/devin/hooks/` — Session-start hooks

## Verify

```bash
devin --version
ls ~/.config/devin/skills
ls ~/.config/devin/hooks
```

## Usage

```bash
devin
```

Start a session. The session-start hook injects the skills catalog. Mention a skill by name, for example:

```
use the writing-plans skill
```

## Update

```bash
./install.sh --devin-cli
```

## Uninstall

```bash
rm -rf ~/.config/devin/skills ~/.config/devin/rules ~/.config/devin/knowledge
rm -f ~/.config/devin/rules.md ~/.config/devin/AGENTS.md
```

Or use `rm-backup.sh --uninstall`.
