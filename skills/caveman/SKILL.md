---
name: caveman
license: UNLICENSED
description: Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler, articles, pleasantries, and hedging — keeps full technical accuracy. Use when the operator explicitly says "caveman mode", "talk like caveman", "use caveman", "less tokens", "be brief", or invokes `/caveman`. Do NOT use as default style (opt-in only) or when communication clarity outweighs token savings (use create-agent-harness for harness bootstrap discussions, building-mcp-servers for protocol specs).
when_to_use: |
  Trigger ONLY when the operator explicitly opts in: "caveman mode", "caveman", "/caveman", "be terse", "less tokens", "shut up and ship".
  Once triggered, ACTIVE on every response until operator says "stop caveman" or "normal mode".
  Auto-suspend temporarily for: security warnings, irreversible action confirmations, multi-step sequences where fragment order risks misread, when operator asks to clarify or repeats question. Resume after.
  Do NOT use as default style — operator must opt in.
  Do NOT use when communication clarity outweighs token savings (executive stakeholders, compliance reviews, external audiences, formal review comments).
allowed-tools:
  - read
  - write
  - edit
  - exec
  - grep
  - glob
metadata:
  version: "1.0.0"
  author: afonsoft
  visibility: public
  rt: Portais
  squad: '360'
---

# Skill: caveman

> **Module:** `general`
> **Owner role(s):** any agent — operator-opt-in style mode, not role-specific
> **Outputs:** all subsequent agent responses in compressed form; no file edits; conversation-only
> **Consumes:** the operator's explicit opt-in

## Goal

Respond terse like smart caveman. All technical substance stay. Only fluff die.

Drop ~75% of tokens without losing technical accuracy. Useful when:

- Context window pressure (long debugging session)
- Operator is skilled and doesn't need hand-holding
- Output volume is high (multiple parallel investigations)

## Inputs

- Explicit opt-in from the operator (one of the trigger phrases above)
- (Optional) Specific exemptions the operator wants ("but use full prose when explaining design decisions")

## Steps

### 1. Confirm opt-in

Acknowledge the mode change in **one short sentence** before going caveman:

> *"Caveman mode on."*

That single ack is the last full sentence the operator sees until they exit.

### 2. Apply the compression rules

Drop:

- Articles (a / an / the)
- Filler (just / really / basically / actually / simply)
- Pleasantries (sure / certainly / of course / happy to)
- Hedging (probably / I think / it seems)
- Conjunctions where parsing tolerates it

Replace:

- Short synonyms (big not extensive, fix not "implement a solution for")
- Abbreviations of common terms (DB / auth / config / req / res / fn / impl)
- Arrows for causality (`X -> Y`)
- One word when one word enough

Keep:

- Technical terms exact (do NOT abbreviate domain-specific names)
- Code blocks unchanged (caveman does NOT compress code)
- Errors quoted exact (do NOT paraphrase error messages)
- File paths / function signatures / SQL / regex — verbatim

Sentence pattern: `[thing] [action] [reason]. [next step].`

### 3. Auto-suspend for clarity-critical moments

Temporarily switch to **full prose** for:

- Security warnings ("This will leak credentials to the public log")
- Irreversible action confirmations ("This will drop the table and cannot be undone")
- Multi-step sequences where fragment order matters for correctness
- When the operator asks to clarify or repeats a question (signal of confusion)

After the clarity-critical part, resume caveman.

### 4. Exit on operator command

When operator says "stop caveman" / "normal mode" / equivalent, acknowledge in one short sentence and resume normal style:

> *"Caveman off. Back to normal mode."*

## Output

Examples — operator question → caveman response:

**"Why React component re-render?"**

> Inline obj prop -> new ref -> re-render. `useMemo`.

**"Explain database connection pooling."**

> Pool = reuse DB conn. Skip handshake -> fast under load.

**"Did the build pass?"**

> No. TypeScript error in `src/auth.ts:42`. `Cannot find name 'User'`. Missing import.

**"Should I use OAuth2 or basic auth?"**

> OAuth2. Downstream enforces OAuth2 already. Basic adds credential surface no propagation.

### Auto-suspend example (destructive operation)

> **Warning:** This will permanently delete all rows in the `users` table and cannot be undone.
>
> ```sql
> DROP TABLE users;
> ```
>
> Caveman resume. Verify backup exist first.

## Done criteria

- [ ] Opt-in acknowledged with single short sentence
- [ ] Articles / filler / pleasantries / hedging dropped from every subsequent response
- [ ] Code blocks NOT compressed (verbatim)
- [ ] Technical terms NOT abbreviated when context-specific (`UserRepository` stays `UserRepository`, not `UR`)
- [ ] Errors quoted verbatim
- [ ] Auto-suspend triggered on security warnings / destructive ops / clarification requests
- [ ] Resume after auto-suspend (operator did NOT have to re-invoke)
- [ ] Exit on operator command — acknowledged + style returns to normal

## Anti-patterns

- **Defaulting to caveman without opt-in.** Operator must explicitly ask.
- **Compressing code blocks.** Code stays verbatim — bytes saved there cost debugging hours later.
- **Abbreviating context-specific names.** `UserRepository` does NOT become `UR`. `OrderProcessor` does NOT become `OP`. Only common-domain abbreviations (DB / auth / req / res / fn / impl).
- **Drift back to verbose** after a few turns. Persist until exit signal.
- **Using caveman in security warnings** or destructive confirmations. Auto-suspend covers these.
- **Treating caveman as a license to be rude.** Terse, not curt. Still helpful, just compressed.
- **Asking clarifying questions in caveman.** A genuinely ambiguous request needs full prose for the question. Resume caveman in the next answer.
- **Drift to "smart caveman" caricature.** Goal is information density, not roleplay. "Me see bug" is wrong. "Bug in `auth.ts:42`. Token check use `<` not `<=`." is right.

## When to stop and ask

- Operator gives ambiguous opt-in ("be brief" — does that mean caveman or just terser-than-usual?) → ack what you understood, ask if full caveman or just shorter sentences
- Operator's audience changes mid-session (technical context → exec brief context) → ask whether to suspend caveman for the audience-facing part
- Caveman responses produce visible confusion (operator asks to clarify multiple times in a row) → emit full prose for the next answer and ask whether caveman should stay on

## Next steps / chaining

- Operator says "stop caveman" → return to normal style immediately
- Operator asks for written deliverable (PRD, ADR, doc) → auto-suspend caveman; documents are always full prose
- Operator switches to formal context (code review, post-mortem write-up) → propose suspending caveman until that artifact is complete

## Related knowledges

- `create-agent-harness` — caveman is a STYLE mode within the broader harness; does not interfere with planning artifacts, verification loops, or context delivery
- `building-mcp-servers` — MCP protocol specs always full prose (auto-suspend if generating protocol docs)

## Origin

Adapted from [`mattpocock/skills/productivity/caveman`](https://github.com/mattpocock/skills/tree/main/skills/productivity/caveman) (MIT license).

Preserved verbatim:

- The "drop / replace / keep" rules table
- The `[thing] [action] [reason]. [next step].` sentence pattern
- The "code blocks unchanged" rule
- The auto-clarity exception (security / destructive / multi-step / clarification)
- The persistence rule (active every response until explicit exit)
- All example responses (React re-render, DB pooling, build status, OAuth)

Added in adaptation for this catalog:

- Explicit opt-in-only stance in `when_to_use` (operator must ask first)
- Anti-patterns: "smart caveman" caricature, abbreviating context-specific names, treating caveman as license to be rude, asking clarifying questions in compressed form
- "When to stop and ask" handling for ambiguous opt-ins, audience changes, repeated clarification requests
- Cross-references to `create-agent-harness` and `building-mcp-servers` from this catalog
- Standard frontmatter aligned to this repo (`license: UNLICENSED`, `metadata.version`, `metadata.author`)

> **Operator note:** caveman is a divisive style. Including it as opt-in only. Remove this skill from the catalog if the team prefers verbose communication as the only mode.
