# agents-skills

A community-driven collection of custom agents, skills, rules, and knowledge designed to enhance GitHub Copilot and AI development experiences across various domains, languages, and frameworks. Following OpenAI harness engineering principles for agent-centered development.

## 🚀 Features

- **🤖 Agents** - Specialized GitHub Copilot agents with MCP server integration
- **📋 Skills** - Self-contained task-specific instructions with bundled resources
- **📚 Rules** - Coding standards and best practices for different languages and frameworks
- **⚡ Workflows** - Agentic workflows for GitHub Actions automation
- **🧠 Knowledge** - Memory documents, patterns, and migration guides
- **🛠️ Installation Scripts** - Easy setup across multiple IDEs and CLIs
- **🧹 Utility Scripts** - System maintenance and cleanup tools

## 📁 Repository Structure

```
agents-skills/
├── agents/           # Custom GitHub Copilot agent definitions
├── skills/           # Task-specific skills with bundled resources
├── rules/            # Coding standards and guidelines
├── workflows/        # Agentic workflows for automation
├── knowledge/        # Knowledge base (structured docs following OpenAI patterns)
│   ├── design-docs/  # Design patterns, core beliefs, architectural principles
│   ├── exec-plans/   # Active/completed execution plans, tech debt tracker
│   ├── generated/    # Auto-generated documentation
│   ├── product-specs/ # Product specifications
│   ├── references/   # Framework-specific guides
│   ├── DESIGN.md     # Design principles and patterns
│   ├── FRONTEND.md   # Frontend design patterns
│   ├── PLANS.md      # Planning templates
│   ├── PRODUCT_SENSE.md # Product principles
│   ├── QUALITY_SCORE.md # Quality metrics and scoring
│   ├── RELIABILITY.md # Reliability requirements
│   └── SECURITY.md   # Security guidelines
├── install.sh        # Installation script for all IDEs
├── rm-backup.sh      # Cleanup script for backups
├── clear-up-linux.sh # Linux system cleanup script
└── git-cleanup-repos.sh # Git repository maintenance script
```

## 🎯 Quick Start

### Installation

Install skills, rules, and knowledge for your preferred IDE:

```bash
# Install for all IDEs/CLIs
./install.sh --all

# Install for specific IDEs
./install.sh --vscode --cursor --devin

# Install for ABP.IO development
./install.sh --vscode --cursor
```

### Supported IDEs/CLIs

- **VS Code** (GitHub Copilot)
- **Windsurf** (Cascade) 
- **Cursor**
- **Devin** / Devin Review / Devin CLI
- **Claude Code**
- **Gemini CLI** (Google)

## 📋 Categories

### 🏗️ Framework Support

#### ASP.NET Boilerplate & ABP.IO
- **Rules**: `aspnetboilerplate.instructions.md`, `abp-io.instructions.md`
- **Skills**: 
  - `create-aspnetboilerplate-project` - Traditional ASP.NET Boilerplate setup
  - `create-abp-io-template` - Modern ABP.IO CLI-based creation
  - `create-abp-project` - ABP.IO project creation with template selection
  - `migrate-aspnetboilerplate-to-abp` - Complete migration guidance
- **Knowledge**: `aspnetboilerplate-to-abp-migration-guide.md`

#### .NET Development
- **C#**: Async programming, testing frameworks (MSTest, NUnit, xUnit), EF Core
- **Architecture**: DDD patterns, SOLID principles, clean architecture
- **Web**: ASP.NET Core, Blazor, API development

### 🔧 Development Tools

#### Code Quality & Review
- **Generic**: Universal code review guidelines and best practices
- **Security**: Comprehensive security standards and vulnerability prevention
- **Performance**: Optimization patterns and monitoring strategies

#### Project Management
- **GitHub Issues**: Issue creation, management, and workflow automation
- **Implementation Planning**: Structured planning templates and methodologies
- **Documentation**: Automated documentation generation and maintenance

### 🌐 Web Development

#### Frontend
- **JavaScript/TypeScript**: Modern JS patterns, testing with Jest
- **UI/UX**: Premium frontend UI components and design systems

#### Backend
- **APIs**: RESTful design, OpenAPI documentation
- **Databases**: PostgreSQL, SQL Server, optimization strategies

## 🛠️ Installation Scripts

### install.sh

Comprehensive installation script supporting:
- Selective IDE installation
- Automatic backup of existing configurations
- Support for multiple IDEs/CLIs
- Cross-platform compatibility (Windows, Linux, macOS)

```bash
# Usage examples
./install.sh --all                    # All IDEs
./install.sh --vscode                 # VS Code only
./install.sh --cursor --devin         # Multiple IDEs
./install.sh -a                       # All IDEs (short)
./install.sh -v -d -g                 # VS Code + Devin + Gemini (short)
```

### rm-backup.sh

Cleanup script to remove backup files created during installation:
```bash
./rm-backup.sh
```

### clear-up-linux.sh

Comprehensive Linux system cleanup script with aaPanel and BleachBit support:
```bash
# Basic cleanup
sudo ./clear-up-linux.sh

# With BleachBit deep cleaning
sudo ./clear-up-linux.sh --bleachbit

# Dry run simulation
sudo ./clear-up-linux.sh --dry-run --verbose
```

**Features:**
- System logs, APT cache, temporary files cleanup
- Docker containers, images, volumes, and build cache
- aaPanel comprehensive cleaning (16 categories)
- PostgreSQL logs, MySQL binary logs, web cache
- BleachBit integration for deep cleaning
- Journal cleanup (1-day retention)
- Interactive and batch modes

### git-cleanup-repos.sh

Git repository maintenance and cleanup script:
```bash
# Make executable and run
chmod +x git-cleanup-repos.sh
./git-cleanup-repos.sh

# Run from specific directory
cd /path/to/projects && ./git-cleanup-repos.sh
```

**Features:**
- Recursive Git repository discovery
- Git fetch, pull, reflog cleanup, and garbage collection
- Build artifact removal (bin, obj, .vs, node_modules)
- Detailed timestamped logging
- Before/after repository statistics
- Safe operations with validation

## 📚 Knowledge Base

Following OpenAI harness engineering principles with structured knowledge organization:

### Core Documents
- **[AGENTS.md](AGENTS.md)** - Repository index (~100 lines) serving as map to knowledge base
- **[knowledge/design-docs/core-beliefs.md](knowledge/design-docs/core-beliefs.md)** - Agent-centered development principles and "golden rules"
- **[knowledge/DESIGN.md](knowledge/DESIGN.md)** - Design principles and architectural patterns
- **[knowledge/SECURITY.md](knowledge/SECURITY.md)** - Security guidelines and requirements

### Pattern Libraries
- **[knowledge/design-docs/agent-skills-patterns.md](knowledge/design-docs/agent-skills-patterns.md)** - Common structures and templates for skill development
- **[knowledge/design-docs/ai-development-patterns.md](knowledge/design-docs/ai-development-patterns.md)** - AI/ML development patterns and best practices
- **[knowledge/design-docs/implementation-patterns.md](knowledge/design-docs/implementation-patterns.md)** - Reusable coding patterns and architectural templates
- **[knowledge/design-docs/coding-standards-compendium.md](knowledge/design-docs/coding-standards-compendium.md)** - Comprehensive coding guidelines across languages

### Migration Guides
- **[knowledge/references/aspnetboilerplate-to-abp-migration-guide.md](knowledge/references/aspnetboilerplate-to-abp-migration-guide.md)** - Complete migration guide with code examples
- **Framework Upgrades**: Step-by-step upgrade instructions
- **Best Practices**: Modern development patterns and conventions

### Framework Documentation
- **[knowledge/references/abp-io-framework-guide.md](knowledge/references/abp-io-framework-guide.md)** - Comprehensive ABP.IO framework documentation
- **Architecture Patterns**: DDD patterns and clean architecture principles
- **Development Tools**: CLI, Suite, and Studio usage guides

### Planning & Quality
- **[knowledge/PLANS.md](knowledge/PLANS.md)** - Planning templates and methodology
- **[knowledge/PRODUCT_SENSE.md](knowledge/PRODUCT_SENSE.md)** - Product principles and decision framework
- **[knowledge/QUALITY_SCORE.md](knowledge/QUALITY_SCORE.md)** - Quality metrics and scoring system
- **[knowledge/RELIABILITY.md](knowledge/RELIABILITY.md)** - Reliability requirements and standards
- **[knowledge/exec-plans/tech-debt-tracker.md](knowledge/exec-plans/tech-debt-tracker.md)** - Technical debt tracking

## 🎨 Featured Skills

### Project Creation
- **create-abp-project**: ABP.IO project creation with template selection
- **create-abp-io-template**: Modern ABP.IO CLI-based template creation
- **create-aspnetboilerplate-project**: Traditional ASP.NET Boilerplate setup
- **create-implementation-plan**: Structured planning for development work
- **create-github-action-workflow-specification**: CI/CD workflow specifications

### Code Generation
- **csharp-async**: C# async programming best practices
- **migrate-aspnetboilerplate-to-abp**: Complete ASP.NET Boilerplate to ABP.IO migration
- **github-issues**: GitHub issue management automation
- **web-design-reviewer**: Web design review and optimization

### Database & Data
- **postgresql-code-review**: PostgreSQL optimization strategies
- **sql-optimization**: SQL performance tuning patterns
- **ef-core**: Entity Framework Core best practices

### Harness Engineering
- **harness-repo-structure**: Create and maintain OpenAI-style repository structure
- **harness-architecture**: Rigid layered architecture with forward-only dependencies
- **harness-quality-invariants**: Quality invariants and golden rules for agent-generated code
- **harness-no-yolo-probing**: Strict prohibition of unvalidated data access

## 🔧 Configuration

### IDE Integration

Each IDE has specific integration patterns:

- **VS Code**: `~/.github/skills`, `~/.copilot/instructions`
- **Windsurf**: `~/.windsurf/skills`, `~/.windsurf/rules`
- **Cursor**: `~/.cursor/skills`, `~/.cursor/rules`
- **Devin**: `~/.agents/skills`, `~/.devin/skills`
- **Claude**: `~/.claude/skills`, `~/.claude/rules`
- **Gemini**: `~/.gemini/skills`, `~/.gemini/GEMINI.md`

### Custom Rules

Rules are applied automatically based on file patterns:
```yaml
applyTo: '**/*.cs,**/*.csproj,**/Program.cs,**/*.razor'
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Quick Contribution Steps

1. **Fork** the repository
2. **Create** a feature branch from `staged` branch
3. **Add** your skill/rule/knowledge/agent/workflow
4. **Submit** a pull request to the `staged` branch

### Development Setup

```bash
# Clone repository
git clone https://github.com/your-username/agents-skills.git
cd agents-skills

# Validate your contribution
npm run skill:validate  # For skills
npm run plugin:validate  # For plugins (if applicable)
```

## 📖 Documentation

- [AGENTS.md](AGENTS.md) - Repository index and quick start guide (OpenAI harness engineering pattern)
- [knowledge/design-docs/core-beliefs.md](knowledge/design-docs/core-beliefs.md) - Core principles and golden rules
- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute to the project
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community standards and guidelines
- [Security Policy](SECURITY.md) - Security policies and vulnerability reporting

## 🏆 Community

This is a community-driven project built with ❤️ by developers, for developers. Join us in:

- 🌟 **Starring** the repository to show your support
- 🍴 **Forking** and contributing your skills and knowledge
- 🐛 **Reporting** issues and suggesting features
- 📝 **Improving** documentation and sharing feedback
- 💬 **Sharing** your experiences and use cases
- 🤝 **Helping** others in the community

## 📊 Statistics

- **Skills**: 62+ specialized skills across various domains (including harness engineering)
- **Rules**: 99+ coding standards and best practices (including architecture rules)
- **Workflows**: 7+ agentic workflows for automation
- **Knowledge**: 18+ comprehensive guides and documents (restructured following OpenAI patterns)
- **Frameworks**: ASP.NET Boilerplate, ABP.IO, Angular, Blazor, and more
- **Languages**: C#, TypeScript, Python, PowerShell, and others
- **IDE Support**: VS Code, Windsurf, Cursor, Devin, Claude, Gemini
- **Utility Scripts**: 2 system maintenance and cleanup scripts

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

## 🔗 Related Projects

- [GitHub Copilot](https://github.com/features/copilot) - AI pair programmer
- [Agent Skills Specification](https://agentskills.io/specification) - Skills standard
- [Agentic Workflows](https://github.github.com/gh-aw) - AI-powered repository automation
- [MCP Protocol](https://modelcontextprotocol.io/) - Model Context Protocol for AI agents
- [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/) - Harness engineering principles
- [Awesome Harness Engineering](https://github.com/ai-boost/awesome-harness-engineering) - Harness engineering resources

---

**Built with ❤️ by the community, for the community.**
