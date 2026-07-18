---
name: rtk-token-killer
license: UNLICENSED
description: "Install and configure RTK (Rust Token Killer) — a high-performance CLI proxy that reduces LLM token consumption by 60-90%. Automatically rewrites shell commands to their rtk equivalents via hooks. Use when setting up a new dev environment or when token optimization is needed. Do NOT use when raw unfiltered output is required (use rtk proxy for that)."
metadata:
  version: "1.0.0"
  author: afonsoft
  visibility: public
  rt: Portais
  origin: rtk-ai/rtk
---

# RTK — Rust Token Killer

High-performance CLI proxy that reduces LLM token consumption by 60-90% through smart filtering, grouping, truncation, and deduplication. Single Rust binary, 100+ supported commands, <10ms overhead.

## Installation

### Pre-built binary

RTK detects OS and architecture automatically (x86_64 and aarch64 supported):

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

Installs to `~/.local/bin`. Ensure PATH includes it:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Verify

```bash
rtk --version   # Should show version
rtk gain         # Should show token savings stats
```

## Hook Setup (per IDE)

After installing the binary, configure hooks for your IDE:

### Claude Code
```bash
rtk init -g                    # Install hook + RTK.md
```

### Cursor / Devin Desktop
```bash
rtk init -g --agent cursor     # Cursor
rtk init -g --agent devin      # Devin Desktop
```

### Codex / Gemini
```bash
rtk init -g --codex            # Codex (OpenAI)
rtk init -g --gemini           # Gemini CLI
```

### Google Antigravity
```bash
rtk init --agent antigravity    # Creates .agents/rules/antigravity-rtk-rules.md
```

### Devin
Devin is not officially supported by RTK. The install.sh script installs the RTK binary globally, but you'll need to manually configure RTK for Devin if needed.

## How It Works

```
Without rtk:                           With rtk:
Claude --git status--> shell --> git    Claude --git status--> RTK --> git
  ^      ~2000 tokens        |           ^    ~200 tokens     |filter|
  +---------------------------+           +--------------------+------+
```

Four strategies per command:
1. **Smart Filtering** — removes noise (comments, whitespace, boilerplate)
2. **Grouping** — aggregates similar items (files by directory, errors by type)
3. **Truncation** — keeps relevant context, cuts redundancy
4. **Deduplication** — collapses repeated log lines with counts

## Key Commands

| Command | Savings | Description |
|---------|---------|-------------|
| `rtk git status` | -80% | Compact git status |
| `rtk git diff` | -75% | Condensed diff |
| `rtk git log` | -80% | One-line commits |
| `rtk cargo test` | -90% | Failures only |
| `rtk ls` | -80% | Token-optimized tree |
| `rtk read file.rs` | -70% | Smart file reading |
| `rtk grep pattern .` | -80% | Grouped search |
| `rtk gain` | — | Token savings analytics |
| `rtk discover` | — | Find missed savings |

## Auto-Rewrite Hook

The hook transparently intercepts Bash commands and rewrites them to rtk equivalents:

```bash
git status    → rtk git status     # automatic
cargo test    → rtk cargo test     # automatic
cat file.rs   → rtk read file.rs   # automatic
```

Result: 100% rtk adoption across all conversations and subagents, zero effort.

## Bypass

When unfiltered output is needed:
```bash
rtk proxy git log --oneline -20    # Full output, still tracked
```

## Proxy Configuration

Behind corporate proxy, set before install:
```bash
```
