---
description: >
  Validate the installation and distribution of the afonsoft/agents-skills
  repository for one or more target IDEs (Devin, Claude, Cursor, Windsurf,
  VS Code, Gemini, OpenClaw). Use after running install.sh or when a user
  reports that skills, hooks, or AGENTS.md are not loading.
mode: agent
tools:
  - read
  - grep
  - find_file_by_name
  - exec
  - git_create_pr
  - git_view_pr
---

# Validate Agent Skills Installation

## Role
DevOps / SRE validation engineer.

## Goal
Verify that `install.sh` correctly deploys skills, hooks, rules, and the
`AGENTS.md` index to the expected platform-specific paths, and that the deployed
artifacts are syntactically valid.

## Input
- `TARGET`: one or more of `devin`, `claude`, `cursor`, `windsurf`, `vscode`,
  `gemini`, `openclaw`, `all`.
- `REPO_ROOT`: path to the cloned `afonsoft/agents-skills` repository.

---

## Phase 1 — Pre-Install State

Record the environment before running the installer:

```bash
# Check supported shells and common target directories
echo $SHELL
uname -s
ls -la ~/.agents/ 2>/dev/null || true
ls -la ~/.devin/ 2>/dev/null || true
ls -la ~/.claude/ 2>/dev/null || true
ls -la ~/.cursor/ 2>/dev/null || true
ls -la ~/.windsurf/ 2>/dev/null || true
ls -la ~/.github/ 2>/dev/null || true
ls -la ~/.gemini/ 2>/dev/null || true
```

---

## Phase 2 — Run Installer

Execute the installer for the requested target(s):

```bash
# Example for Devin only
./install.sh --devin

# Example for all supported platforms
./install.sh --all

# Optional dry-run preview
./install.sh --devin --dry-run
```

Capture the full output to a log file.

---

## Phase 3 — Verify Deployed Artifacts

### Expected paths per platform

| Platform | Skills path | Hooks path | Index file |
|---|---|---|---|
| Base | `~/.agents/skills/` | — | `~/.agents/AGENTS.md` |
| Devin | `~/.devin/skills/` | `~/.devin/hooks/` | `~/.devin/AGENTS.md` |
| Claude | `~/.claude/skills/` | `~/.claude/hooks/` | `~/.claude/AGENTS.md` |
| Cursor | `~/.cursor/skills/` | `~/.cursor/hooks/` | `~/.cursor/AGENTS.md` |
| Windsurf | `~/.windsurf/skills/` | `~/.windsurf/hooks/` | `~/.windsurf/AGENTS.md` |
| VS Code / Copilot | `~/.github/skills/` | `~/.github/hooks/` | `~/.github/AGENTS.md` |
| Gemini | `~/.gemini/skills/` | `~/.gemini/hooks/` | `~/.gemini/AGENTS.md` |
| OpenClaw | `~/.gemini/antigravity-cli/skills/` | `~/.gemini/antigravity-cli/hooks/` | `~/.gemini/antigravity-cli/AGENTS.md` |

For each requested target:

1. Confirm the `skills/` directory exists and contains all `SKILL.md` files.
2. Confirm the `hooks/` directory exists and contains the session-start hook.
3. Confirm the `AGENTS.md` index file is present and points to `skills/` and `hooks/`.
4. Verify at least one `SKILL.md` has valid YAML frontmatter:
   - `name` matches the folder name.
   - `description` is present and under 1024 characters.

### Validation script example

```bash
test -d ~/.agents/skills && \
test -d ~/.devin/skills && \
test -d ~/.devin/hooks && \
test -f ~/.devin/AGENTS.md && \
echo "PASS" || echo "FAIL"
```

---

## Phase 4 — Static Validation

Run the repository's standard validation commands:

```bash
# Lint shell scripts
shellcheck install.sh rm-backup.sh git-cleanup-repos.sh clear-up-linux.sh

# Validate install dry-run
./install.sh --all --dry-run

# Basic existence validation
bash -c 'test -d ~/.agents/skills && test -d ~/.devin/skills && test -f ~/.devin/AGENTS.md && echo "PASS" || echo "FAIL"'
```

Record lint warnings and dry-run output in the validation log.

---

## Phase 5 — Report Results

Produce a concise report with:

- Platform(s) validated.
- Installer version / commit SHA.
- Pass/fail per artifact path.
- ShellCheck summary.
- Any warnings or missing files.
- Recommended fixes (if any).

### Example report

```markdown
## Validation Report

- Target: devin, claude
- Commit: <sha>
- Result: PASS / FAIL

| Platform | Skills | Hooks | AGENTS.md | Notes |
|---|---|---|---|---|
| devin | PASS | PASS | PASS | — |
| claude | PASS | FAIL | PASS | `hooks/` directory missing |

### ShellCheck
- install.sh: 0 errors, 2 warnings
- git-cleanup-repos.sh: 0 errors, 5 warnings

### Recommendations
- Fix missing `~/.claude/hooks/` deployment.
```

---

## Phase 6 — Fix and Re-validate

If validation fails:

1. Inspect `install.sh` for the failing target and identify the root cause.
2. Make minimal corrections to `install.sh` or the source files.
3. Re-run the installer and validation.
4. Update the report.

If changes are made, create branch `feature/{YYYYMMDD}-install-validation-fix`
and prepare a commit with Conventional Commit message such as:
`fix(install): correct hooks path for <target>`.

**Do not open the Pull Request automatically** unless explicitly instructed.

---

## Restrictions

- Do not modify workflow files in `/.github/workflows/`.
- Do not commit secrets or credentials.
- Do not assume all platforms are installed; validate only the requested `TARGET`.
