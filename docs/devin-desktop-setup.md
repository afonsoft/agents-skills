# Devin Desktop Setup Guide

Devin Desktop is the local IDE successor to Windsurf/Cascade. It loads agent configuration from `~/.devin/`.

## Installation

1. Download Devin Desktop from the official site:
   - https://www.devin.ai/desktop
   - Or follow the docs at https://docs.devin.ai/desktop/devin-desktop-faq

2. Install the launcher for your platform (macOS, Windows, or Linux).

## Configure Agent Skills

After installing Devin Desktop, run the repository installer:

```bash
./install.sh --devin-desktop
```

This installs:
- `~/.devin/skills/` — Agent Skills (SKILL.md)
- `~/.devin/rules/` — Rule instructions
- `~/.devin/rules.md` — Consolidated rules
- `~/.devin/knowledge/` — Knowledge sources
- `~/.devin/AGENTS.md` — Repository index
- `~/.devin/hooks/` — Session-start hooks

## Verify

```bash
ls ~/.devin/skills
ls ~/.devin/hooks
```

## Usage

1. Open Devin Desktop.
2. Open a workspace/repository.
3. The session-start hook injects the skills catalog into the agent context.
4. Reference a skill by name or description in chat.

## Update

To update skills and rules:

```bash
./install.sh --devin-desktop
```

## Uninstall

```bash
rm -rf ~/.devin/skills ~/.devin/rules ~/.devin/knowledge
rm -f ~/.devin/rules.md ~/.devin/AGENTS.md
```

Or use `rm-backup.sh --uninstall` to remove everything.
