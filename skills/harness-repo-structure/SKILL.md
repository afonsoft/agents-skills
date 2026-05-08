---
name: harness-repo-structure
description: 'Create and maintain OpenAI-style harness engineering repository structure with knowledge base organization'
---

# Harness Repository Structure

## Primary Directive

Create and maintain repository structure following OpenAI harness engineering principles where AGENTS.md serves as an index (~100 lines) and knowledge resides in structured docs/ with mechanical validation.

## Execution Context

This skill is for AI-to-AI communication to establish repository structure optimized for agent readability. All instructions must be executed systematically without human interpretation.

## Repository Structure Pattern

```
repository-root/
├── skills/           # Agent Skills (SKILL.md format)
├── rules/            # Path-specific coding standards (.instructions.md)
├── agents/           # GitHub Copilot agent definitions
├── workflows/        # Agentic workflows for automation
├── knowledge/        # Knowledge base (structured docs)
│   ├── design-docs/  # Design patterns, core beliefs
│   ├── exec-plans/   # Active/completed execution plans
│   ├── generated/    # Auto-generated documentation
│   ├── product-specs/ # Product specifications
│   ├── references/   # Framework-specific guides
│   ├── DESIGN.md     # Design principles
│   ├── FRONTEND.md   # Frontend patterns
│   ├── PLANS.md      # Planning templates
│   ├── PRODUCT_SENSE.md # Product principles
│   ├── QUALITY_SCORE.md # Quality metrics
│   ├── RELIABILITY.md # Reliability requirements
│   └── SECURITY.md   # Security guidelines
├── .agents/          # Agent conventions
├── install.sh        # Installation script
└── llms.txt          # LLM discoverability
```

## AGENTS.md Requirements

- **Length**: Approximately 100 lines
- **Purpose**: Index/map to knowledge base, not encyclopedia
- **Content**: Quick start, repository map, knowledge base structure links, core principles summary, supported platforms, standards

## Knowledge Base Organization

### design-docs/

Contains design patterns and operational principles:
- `index.md` - Design documents index
- `core-beliefs.md` - Agent-centered development principles (golden rules)
- Pattern documents (agent-skills-patterns.md, ai-development-patterns.md, etc.)

### exec-plans/

Contains execution plans and technical debt tracking:
- `active/` - Ongoing implementation plans
- `completed/` - Finished plans
- `tech-debt-tracker.md` - Technical debt inventory

### generated/

Contains auto-generated documentation (db-schema.md, etc.)

### product-specs/

Contains product specifications and requirements

### references/

Contains framework-specific guides and external references

## Root Knowledge Files

Create these files in knowledge/ root:

- **DESIGN.md** - Design principles and patterns
- **FRONTEND.md** - Frontend design patterns
- **PLANS.md** - Planning templates and methodology
- **PRODUCT_SENSE.md** - Product principles and decision framework
- **QUALITY_SCORE.md** - Quality metrics and scoring system
- **RELIABILITY.md** - Reliability requirements and standards
- **SECURITY.md** - Security guidelines

## Mechanical Validation

Implement linters and CI checks to validate:
- Knowledge base structure is correct
- All index files exist and are up-to-date
- Links in documentation are valid
- AGENTS.md remains under 120 lines
- No placeholder text remains in final documents
- Front matter follows required format

## Progressive Disclosure

- AGENTS.md provides small, stable entry point
- Agents instructed on where to look next
- Not overwhelmed with initial context
- Mechanical validation ensures knowledge base is current

## File Creation Process

When creating new structure:

1. Create directory structure following pattern
2. Create index.md files for each subdirectory
3. Create root knowledge files (DESIGN.md, FRONTEND.md, etc.)
4. Update AGENTS.md to reference new structure
5. Create linters to validate structure
6. Add CI checks for mechanical validation

## File Moving Process

When reorganizing existing files:

1. Identify target category (design-docs, exec-plans, references, etc.)
2. Move file to appropriate directory
3. Update index.md files
4. Update any cross-references
5. Validate links still work
6. Update AGENTS.md if needed

## Quality Gates

Before considering structure complete:

- All directories exist per pattern
- All index files created
- All root knowledge files created
- AGENTS.md under 120 lines
- Mechanical validation linters in place
- CI checks configured
- No broken links
- No placeholder text

## Common Patterns

### Creating New Design Document

```bash
# Create in design-docs/
mkdir -p knowledge/design-docs
# Create document
# Update knowledge/design-docs/index.md
```

### Creating New Execution Plan

```bash
# Create in exec-plans/active/ for ongoing
# or exec-plans/completed/ for finished
# Update tech-debt-tracker.md if applicable
```

### Adding Framework Reference

```bash
# Create in references/
# Update knowledge/references/index.md
```

## Error Handling

If structure validation fails:
- Identify missing directories or files
- Create missing components
- Update index files
- Re-run validation
- Report specific errors with fix suggestions

## Success Criteria

Structure is complete when:
- Repository matches pattern exactly
- AGENTS.md is concise index (~100 lines)
- Knowledge base is mechanically validated
- All links are valid
- No placeholder text remains
- CI checks pass
