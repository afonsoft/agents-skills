# AGENTS.md

## Project Overview

The agents-skills repository is a community-driven collection of custom agents and instructions designed to enhance GitHub Copilot experiences across various domains, languages, and use cases. The project includes:

- **Agents** - Specialized GitHub Copilot agents that integrate with MCP servers
- **rules** - Coding standards and best practices applied to specific file patterns
- **Skills** - Self-contained folders with instructions and bundled resources for specialized tasks
- **Workflows** - [Agentic Workflows](https://github.github.com/gh-aw) for AI-powered repository automation in GitHub Actions
- **knowledge** - Memory and knowledge base for AI agents, containing patterns, standards, migration guides, and comprehensive documentation that enhances agent capabilities and provides contextual information for Windsurf Cascade and other AI development tools

## Repository Structure

```
.
├── agents/           # Custom GitHub Copilot agent definitions (.agent.md files)
├── rules/     	      # Coding standards and guidelines (.instructions.md files)
├── skills/           # Agent Skills folders (each with SKILL.md and optional bundled assets)
├── workflows/        # Agentic Workflows (.md files for GitHub Actions automation)
├── knowledge/        # Memory and knowledge base for AI agents with patterns, standards, and guides
├── install.sh        # Installation script for skills, rules, and knowledge
└── rm-backup.sh      # Script to remove backup files created during installation
```

## Development Workflow

### Working with Agents, rules, Skills, and knowledge

All agent files (`*.agent.md`) and instruction files (`*.instructions.md`) must include proper markdown front matter. Agent Skills are folders containing a `SKILL.md` file with frontmatter and optional bundled assets. The knowledge folder contains memory documents, patterns, standards, and comprehensive guides that serve as contextual information for AI agents, particularly enhancing Windsurf Cascade's capabilities with established best practices and migration strategies.

#### Installation and Setup

Use the provided installation scripts to set up skills, rules, and knowledge across different IDEs:

```bash
# Install for all IDEs/CLIs
./install.sh --all

# Install for specific IDEs
./install.sh --vscode --cursor --devin

# Clean up backups
./rm-backup.sh
```

Supported IDEs/CLIs:
- VS Code (GitHub Copilot)
- Windsurf (Cascade)
- Cursor
- Devin / Devin Review / Devin CLI
- Claude Code
- Gemini CLI (Google)

#### Agent Files (*.agent.md)
- Must have `description` field (wrapped in single quotes)
- File names should be lower case with words separated by hyphens
- Recommended to include `tools` field
- Strongly recommended to specify `model` field

#### rules Files (*.instructions.md)
- Must have `description` field (wrapped in single quotes, not empty)
- Must have `applyTo` field specifying file patterns (e.g., `'**.js, **.ts'`)
- File names should be lower case with words separated by hyphens

#### Agent Skills (skills/*/SKILL.md)
- Each skill is a folder containing a `SKILL.md` file
- SKILL.md must have `name` field (lowercase with hyphens, matching folder name, max 64 characters)
- SKILL.md must have `description` field (wrapped in single quotes, 10-1024 characters)
- Folder names should be lower case with words separated by hyphens
- Skills can include bundled assets (scripts, templates, data files)
- Bundled assets should be referenced in the SKILL.md instructions
- Asset files should be reasonably sized (under 5MB per file)
- Skills follow the [Agent Skills specification](https://agentskills.io/specification)

#### Workflow Files (workflows/*.md)
- Each workflow is a standalone `.md` file in the `workflows/` directory
- Must have `name` field (human-readable name)
- Must have `description` field (wrapped in single quotes, not empty)
- Contains agentic workflow frontmatter (`on`, `permissions`, `safe-outputs`) and natural language instructions
- File names should be lower case with words separated by hyphens
- Only `.md` files are accepted — `.yml`, `.yaml`, and `.lock.yml` files are blocked by CI
- Follow the [GitHub Agentic Workflows specification](https://github.github.com/gh-aw/reference/workflow-structure/)

#### Knowledge Files (knowledge/*)
- Memory documents and guides for AI agent reference and contextual enhancement
- Markdown files with comprehensive documentation including patterns, standards, and migration guides
- Serves as knowledge base for Windsurf Cascade and other AI development tools
- Provides established best practices, architectural patterns, and framework-specific guidance
- File names should be descriptive and use kebab-case
- No specific front matter required but recommended for consistency

### Adding New Resources

When adding a new agent, instruction, skill, hook, workflow, or plugin:

**For Agents and Instructions:**
1. Create the file with proper front matter
2. Add the file to the appropriate directory
3. Update the README.md by running: `npm run build`
4. Verify the resource appears in the generated README

**For Workflows:**
1. Create a new `.md` file in `workflows/` with a descriptive name (e.g., `daily-issues-report.md`)
2. Include frontmatter with `name` and `description`, plus agentic workflow fields (`on`, `permissions`, `safe-outputs`)
3. Compile with `gh aw compile --validate` to verify it's valid
4. Update the README.md by running: `npm run build`
5. Verify the workflow appears in the generated README

**For Skills:**
1. Run `npm run skill:create` to scaffold a new skill folder
2. Edit the generated SKILL.md file with your instructions
3. Add any bundled assets (scripts, templates, data) to the skill folder
4. Run `npm run skill:validate` to validate the skill structure
5. Update the README.md by running: `npm run build`
6. Verify the skill appears in the generated README

Before committing:
- Ensure all markdown front matter is correctly formatted
- Verify file names follow the lower-case-with-hyphens convention
- Check that your new resource appears correctly in the README

## Code Style Guidelines

### Markdown Files
- Use proper front matter with required fields
- Keep descriptions concise and informative
- Wrap description field values in single quotes
- Use lower-case file names with hyphens as separators

### JavaScript/Node.js Scripts
- Located in `eng/` and `scripts/` directories
- Follow Node.js ES module conventions (`.mjs` extension)
- Use clear, descriptive function and variable names

## Pull Request Guidelines

When creating a pull request:

> **Important:** All pull requests should target the **`staged`** branch, not `main`.

1. **README updates**: New files should automatically be added to the README when you run `npm run build`
2. **Front matter validation**: Ensure all markdown files have the required front matter fields
3. **File naming**: Verify all new files follow the lower-case-with-hyphens naming convention
4. **Build check**: Run `npm run build` before committing to verify README generation
5. **Line endings**: **Always run `bash scripts/fix-line-endings.sh`** to normalize line endings to LF (Unix-style)
6. **Description**: Provide a clear description of what your agent/instruction does
7. **Testing**: If adding a plugin, run `npm run plugin:validate` to ensure validity

### Pre-commit Checklist

Before submitting your PR, ensure you have:
- [ ] Run `npm install` (or `npm ci`) to install dependencies
- [ ] Run `npm run build` to generate the updated README.md
- [ ] Run `bash scripts/fix-line-endings.sh` to normalize line endings
- [ ] Verified that all new files have proper front matter
- [ ] Tested that your contribution works with GitHub Copilot
- [ ] Checked that file names follow the naming convention

### Code Review Checklist

For instruction (rules) files (*.instructions.md):
- [ ] Has markdown front matter
- [ ] Has non-empty `description` field wrapped in single quotes
- [ ] Has `applyTo` field with file patterns
- [ ] File name is lower case with hyphens

For agent files (*.agent.md):
- [ ] Has markdown front matter
- [ ] Has non-empty `description` field wrapped in single quotes
- [ ] Has `name` field with human-readable name (e.g., "Address Comments" not "address-comments")
- [ ] File name is lower case with hyphens
- [ ] Includes `model` field (strongly recommended)
- [ ] Considers using `tools` field

For skills (skills/*/):
- [ ] Folder contains a SKILL.md file
- [ ] SKILL.md has markdown front matter
- [ ] Has `name` field matching folder name (lowercase with hyphens, max 64 characters)
- [ ] Has non-empty `description` field wrapped in single quotes (10-1024 characters)
- [ ] Folder name is lower case with hyphens
- [ ] Any bundled assets are referenced in SKILL.md
- [ ] Bundled assets are under 5MB per file

For workflow files (workflows/*.md):
- [ ] File has markdown front matter
- [ ] Has `name` field with human-readable name
- [ ] Has non-empty `description` field wrapped in single quotes
- [ ] File name is lower case with hyphens
- [ ] Contains `on` and `permissions` in frontmatter
- [ ] Workflow uses least-privilege permissions and safe outputs
- [ ] No `.yml`, `.yaml`, or `.lock.yml` files included
- [ ] Follows [GitHub Agentic Workflows specification](https://github.github.com/gh-aw/reference/workflow-structure/)

This is a community-driven project. Contributions are welcome! Please see:
- [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community standards
- [SECURITY.md](SECURITY.md) for security policies

## Project Statistics

- **Skills**: 61+ specialized skills across various domains
- **Rules**: 96+ coding standards and best practices
- **Workflows**: 7+ agentic workflows for automation
- **Knowledge**: 5+ comprehensive guides and migration documents
- **Frameworks**: ASP.NET Boilerplate, ABP.IO, Angular, Blazor, and more
- **Languages**: C#, TypeScript, Python, PowerShell, and others
- **IDE Support**: VS Code, Windsurf, Cursor, Devin, Claude, Gemini

## Featured Content

### ABP.IO Framework Support
- Complete project creation skills with CLI integration
- Migration guides from ASP.NET Boilerplate
- Architecture patterns and best practices
- Template selection and configuration guidance

### Development Excellence
- Code review standards and patterns
- Performance optimization strategies
- Security best practices and guidelines
- Testing frameworks and methodologies

### Knowledge Base
- Implementation patterns and templates
- Coding standards compendium
- Migration strategies and guides
- Architectural decision records
- ABP.IO framework comprehensive guide

