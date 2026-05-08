# Core Beliefs - Agent-Centered Development Principles

## Operating Philosophy

**Humans direct. Agents execute.**

This repository follows OpenAI's harness engineering principles where the primary function of engineering shifts from writing code to designing environments, specifying intentions, and building feedback loops that enable agents to perform reliable work.

## Golden Rules

### 1. Repository Knowledge is the System of Record

- **Give agents a map, not a 1,000-page instruction manual**
- Context is a scarce resource - large instruction files obscure tasks and relevant code
- Monolithic documentation becomes a graveyard of obsolete rules
- AGENTS.md serves as an index (~100 lines), not an encyclopedia
- Knowledge resides in structured `docs/` directory with mechanical validation

### 2. Agent Readability is the Goal

- The repository is optimized primarily for agent readability
- Anything agents cannot access in context effectively does not exist
- Versioned, local repository artifacts (code, markdown, schemas, executable plans) are all agents can see
- Knowledge in Google Docs, Slack conversations, or human minds is inaccessible
- All context must be encoded in repository artifacts

### 3. Rigid Architecture Enables Velocity

- Agents are most effective in environments with rigid boundaries and predictable structure
- Each business domain is divided into fixed layers: **Types → Config → Repo → Service → Runtime → UI**
- Dependencies only go "forward" through fixed layers
- Cross-cutting concerns (auth, connectors, telemetry, feature flags) enter via single explicit interface: **Providers**
- Constraints are mechanically enforced via custom linters and structural tests

### 4. Invariants Over Implementation

- Impose invariants, don't micromanage implementations
- Example: Require data format validation at the boundary, but don't prescribe the library (agent may prefer Zod)
- Rigid boundaries, correctness, and reproducibility are central concerns
- Within those boundaries, allow significant local autonomy

### 5. Taste is Continually Reintroduced

- Code output may not match human stylistic preferences - that's acceptable if correct, maintainable, and agent-readable
- Human taste is captured once and applied continuously via:
  - Review comments
  - Refactoring PRs
  - Visible bugs recorded as documentation updates or tool rules
- When documentation is insufficient, encode the rule directly in code

### 6. Continuous Garbage Collection

- Technical debt is like high-interest loans: better paid continuously in small installments
- Encode "golden principles" directly in the repository
- Recurring cleanup process checks for deviations, updates quality scores, opens refactoring PRs
- Most refactoring PRs can be reviewed in <1 minute and merged automatically
- Identify and resolve problematic patterns daily rather than letting them spread for weeks

### 7. High Processing Rate Changes Merge Philosophy

- Repository operates with minimum merge process blocking
- Pull requests are short-lived
- Test instabilities are handled with follow-up runs rather than indefinite blocking
- In high agent processing environments, fixes are cheap, waiting is expensive
- This trade-off is appropriate when agent processing rate far exceeds human attention

### 8. Progressive Disclosure

- Agents start with a small, stable entry point (AGENTS.md as index)
- Instructed on where to look next, not overwhelmed initially
- Mechanical validation ensures knowledge base is current, cross-linked, and properly structured
- Recurring "documentation maintenance" agent checks for outdated/obsolete documentation

## Architecture Principles

### Layered Domain Architecture

```
Within each business domain:
Types → Config → Repo → Service → Runtime → UI

Cross-cutting concerns (auth, connectors, telemetry, feature flags) enter via:
Providers (single explicit interface)

Utils module sits outside boundary and is injected via Providers
```

### Dependency Rules

- Code can only depend "forward" through fixed layers
- All cross-cutting concerns must go through Providers
- Any other dependency is prohibited and mechanically enforced

### Quality Invariants

- Structured logging is statically enforced
- Naming conventions for schemas and types
- File size limits
- Platform-specific reliability requirements
- Custom code checks with agent-friendly error messages

## Technology Choices

**Prefer "boring" technologies** that are:
- Fully internalizable and analyzable within the repository
- Composable
- Have stable APIs
- Well-represented in training data

Sometimes it's cheaper to have agents reimplement functionality subsets than work around opaque public library behavior.

## What "Agent-Generated" Means

When we say code is agent-generated, we mean everything in the codebase:

- Product code and tests
- CI configuration and deployment tooling
- Internal developer tools
- Documentation and design history
- Evaluation harness
- Scripts that manage the repository itself
- Production dashboard definition files

Humans remain in the process but work at a different abstraction level: prioritize work, transform user feedback into acceptance criteria, validate results. When agents struggle, interpret as signal: identify what's missing (tools, guidelines, documentation) and feed back into repository, always having the agent write the fix.

## Autonomy Levels

As more development steps are built into the system (testing, validation, review, feedback handling, recovery), repositories can achieve end-to-end feature implementation with a single command:

1. Validate current codebase state
2. Reproduce reported bug
3. Record video demonstrating failure
4. Implement fix
5. Validate fix by running application
6. Record second video demonstrating resolution
7. Open pull request
8. Respond to agent and human feedback
9. Detect and fix build failures
10. Escalate to human only when decision required
11. Consolidate change

This behavior depends on specific repository structure and tools - not generalizable without similar investments.

## Still Learning

We don't yet know:
- How architectural coherence evolves over years in fully agent-generated systems
- Where human judgment adds most value and how to encode it for multiplication
- How systems evolve as models become more capable

What is clear: software development still requires discipline, but that discipline manifests more in support structure than in code itself. Tools, abstractions, and feedback loops that maintain code cohesion are increasingly important.
