# Antigravity Hooks

Session-start hooks for Google Antigravity IDE.

## Files

- `session-start` - Hook that injects the skills catalog into the agent context at session start

## Installation

These hooks are automatically installed by the main installer script:

```bash
./install.sh --antigravity
```

## Configuration

The hook uses the standard session-start base script and outputs the skills catalog in the additionalContext format expected by the Antigravity SDK.
