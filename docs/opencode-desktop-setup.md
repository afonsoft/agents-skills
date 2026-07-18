# OpenCode Desktop Setup Guide

OpenCode Desktop is a local IDE with agent support. It loads configuration from `~/.opencode/`.

## Installation

1. Download OpenCode Desktop from the official site:
   - https://opencode.dev
   - Or follow the docs at https://opencode.dev/docs

2. Install the launcher for your platform (macOS, Windows, or Linux).

## Configure Agent Skills

After installing OpenCode Desktop, run the repository installer:

```bash
./install.sh --opencode-desktop
```

This installs:
- `~/.opencode/skills/` — Agent Skills (SKILL.md)
- `~/.opencode/rules/` — Rule instructions
- `~/.opencode/rules.md` — Consolidated rules
- `~/.opencode/knowledge/` — Knowledge sources
- `~/.opencode/AGENTS.md` — Repository index
- `~/.opencode/hooks/` — Session-start hooks

## Verify

```bash
ls ~/.opencode/skills
ls ~/.opencode/hooks
```

## Usage

1. Open OpenCode Desktop.
2. Open a workspace/repository.
3. The session-start hook injects the skills catalog into the agent context.
4. Reference a skill by name or description in chat.

## Update

```bash
./install.sh --opencode-desktop
```

## Uninstall

```bash
rm -rf ~/.opencode/skills ~/.opencode/rules ~/.opencode/knowledge
rm -f ~/.opencode/rules.md ~/.opencode/AGENTS.md
```

Or use `rm-backup.sh --uninstall`.
