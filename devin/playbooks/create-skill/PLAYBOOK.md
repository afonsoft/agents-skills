---
description: >
  Create a new agent skill in the afonsoft/agents-skills repository following the
  agentskills.io specification and the repository's Test-Driven Development
  conventions. Use when a reusable pattern, technique, or reference guide needs
  to be added and the user has approved the topic.
mode: agent
tools:
  - read
  - grep
  - find_file_by_name
  - write
  - exec
  - git_create_pr
  - git_view_pr
---

# Create Agent Skill

## Role
Agent Skills Author.

## Goal
Create a production-ready `SKILL.md` under `skills/{skill-name}/` that follows
the agentskills.io specification and the repository's quality invariants.

## Input
- `SKILL_NAME`: lowercase kebab-case, max 64 characters, must match folder name.
- `SKILL_TYPE`: `technique`, `pattern`, or `reference`.
- `TRIGGER_DESCRIPTION`: third-person, technology-agnostic trigger conditions.
- `REPO_ROOT`: `/home/ubuntu/repos/agents-skills` or equivalent.

---

## Phase 1 — Validate Need and Scope

Before creating, confirm:

- [ ] The topic is reusable across projects, not a one-off solution.
- [ ] It is not a project-specific convention (those belong in `AGENTS.md`/`CLAUDE.md`).
- [ ] It cannot be enforced mechanically with regex/validation alone.
- [ ] The user explicitly approved the topic.

If any item is false, stop and report why.

---

## Phase 2 — Check Existing Skills

Search the repository to avoid duplication:

```bash
grep -R "<topic>" skills/ --include="SKILL.md" -l
ls skills/ | grep -i "<topic>"
```

If a similar skill exists, extend it instead of creating a new one.

---

## Phase 3 — Apply Test-Driven Development for Skills

The skill document is the "production code". Validate it with pressure scenarios.

### 3.1 Design the Skill

- Define the **core principle** in 1-2 sentences.
- List concrete **trigger conditions** (when to use and when NOT to use).
- Draft the main workflow or pattern.
- Identify 2-3 common mistakes the skill prevents.

### 3.2 Write Pressure Scenarios (Tests)

Create 2-3 scenarios that would cause an agent to fail without the skill.
Examples:

- Scenario A: an agent is asked to do X but omits step Y.
- Scenario B: an agent uses the wrong tool or assumption for this domain.
- Scenario C: an agent produces output that violates the skill's output contract.

### 3.3 Run Baseline (RED)

If possible, run the scenarios with a fresh subagent or mental model and record
how the agent fails. Capture exact rationalizations or shortcuts.

### 3.4 Write SKILL.md (GREEN)

Create `skills/{skill-name}/SKILL.md` with the required frontmatter:

```markdown
---
name: {skill-name}
description: >
  Use when [triggering conditions, symptoms, and contexts].
  Do not use when [exclusions].
metadata:
  version: "1.0.0"
  author: afonsoft
  visibility: public
---

# {Skill Name}

## Overview
1-2 sentence core principle.

## When to Use
- Trigger 1
- Trigger 2
- Symptom A

### When NOT to Use
- One-off project-specific conventions
- Cases enforceable by validation/lint

## Core Pattern
Before/after comparison or step-by-step workflow.

## Quick Reference
Table or bullet list for scanning.

## Implementation
Inline code for simple patterns; link to supporting files for heavy reference.

## Common Mistakes
- Mistake 1: problem + fix
- Mistake 2: problem + fix
```

### 3.5 Refactor (CLOSE LOOPHOLES)

Re-run the pressure scenarios mentally or with a subagent. If the agent still
violates the skill, close the loophole by rewriting the relevant section.

Repeat until the skill reliably guides the desired behavior.

---

## Phase 4 — Quality Invariants

Ensure the skill passes all repository quality checks:

- [ ] `name` in frontmatter matches the folder name.
- [ ] `description` starts with "Use when..." and describes triggers, not workflow.
- [ ] `description` is under 1024 characters.
- [ ] Folder name is lowercase kebab-case and under 64 characters.
- [ ] No unsupported characters in `name` (only letters, numbers, hyphens).
- [ ] Agent readability score ≥ 70/100.
- [ ] Cross-platform compatibility score ≥ 80/100.
- [ ] Documentation quality score ≥ 70/100.
- [ ] No platform-specific assumptions unless the skill is explicitly platform-specific.
- [ ] Self-contained — no external dependencies for understanding.

---

## Phase 5 — Optional Supporting Files

Only add supporting files when necessary:

```
skills/{skill-name}/
├── SKILL.md              # required
├── references/           # optional: detailed docs, patterns, examples
├── templates/            # optional: code templates
├── scripts/              # optional: bundled scripts
└── assets/               # optional: supporting files (< 5MB each)
```

---

## Phase 6 — Validation and Delivery

1. Verify the skill file with `markdownlint` if available.
2. Validate YAML frontmatter with `yamllint` or equivalent.
3. Create branch `feature/{YYYYMMDD}-skill-{skill-name}`.
4. Commit with Conventional Commit: `feat(skills): add {skill-name} skill`.
5. **Do not open the Pull Request automatically** unless explicitly instructed.
   Prepare a summary of the skill, its triggers, and the TDD verification so the
   user can open the PR manually.

---

## Restrictions

- Do not create a skill without the user's approval of the topic.
- Do not duplicate existing skills.
- Do not put project-specific conventions into a skill.
- Do not commit secrets or credentials.
- Do not exceed 5MB per supporting asset.
