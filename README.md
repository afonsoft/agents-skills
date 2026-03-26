# agents-skills

A community-driven collection of custom agents, skills, rules, and knowledge designed to enhance GitHub Copilot and AI development experiences across various domains, languages, and frameworks.

## 🚀 Features

- **🤖 Agents** - Specialized GitHub Copilot agents with MCP server integration
- **📋 Skills** - Self-contained task-specific instructions with bundled resources
- **📚 Rules** - Coding standards and best practices for different languages and frameworks
- **⚡ Workflows** - Agentic workflows for GitHub Actions automation
- **🧠 Knowledge** - Memory documents, patterns, and migration guides
- **🛠️ Installation Scripts** - Easy setup across multiple IDEs and CLIs

## 📁 Repository Structure

```
agents-skills/
├── agents/           # Custom GitHub Copilot agent definitions
├── skills/           # Task-specific skills with bundled resources
├── rules/            # Coding standards and guidelines
├── workflows/        # Agentic workflows for automation
├── knowledge/        # Memory documents and guides
├── install.sh        # Installation script for all IDEs
└── rm-backup.sh      # Cleanup script for backups
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

## 📚 Knowledge Base

### Pattern Libraries
- **Agent Skills Patterns**: Common structures and templates for skill development
- **Implementation Patterns**: Reusable coding patterns and architectural templates
- **Coding Standards Compendium**: Comprehensive coding guidelines across languages

### Migration Guides
- **ASP.NET Boilerplate to ABP.IO**: Complete migration guide with code examples
- **Framework Upgrades**: Step-by-step upgrade instructions
- **Best Practices**: Modern development patterns and conventions

### Framework Documentation
- **ABP.IO Framework Guide**: Comprehensive ABP.IO framework documentation
- **Architecture Patterns**: DDD patterns and clean architecture principles
- **Development Tools**: CLI, Suite, and Studio usage guides

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
2. **Create** a feature branch
3. **Add** your skill/rule/knowledge
4. **Test** with your IDE
5. **Submit** a pull request to the `staged` branch

### Development Setup

```bash
# Clone repository
git clone https://github.com/your-username/agents-skills.git
cd agents-skills

# Install dependencies
npm install

# Validate your contribution
npm run build
npm run skill:validate  # For skills
```

## 📖 Documentation

- [Development Guide](AGENTS.md) - Detailed development workflow
- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community standards
- [Security Policy](SECURITY.md) - Security policies

## 🏆 Community

This is a community-driven project. Join us in:

- 🌟 **Starring** the repository
- 🍴 **Forking** and contributing
- 🐛 **Reporting** issues and suggesting features
- 📝 **Improving** documentation
- 💬 **Sharing** feedback and experiences

## 📊 Statistics

- **Skills**: 61+ specialized skills
- **Rules**: 96+ coding standards  
- **Workflows**: 7+ automation workflows
- **Knowledge**: 5+ comprehensive guides and migration documents
- **IDE Support**: 6+ major IDEs and CLIs

## 📄 License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

## 🔗 Related Projects

- [GitHub Copilot](https://github.com/features/copilot) - AI pair programmer
- [GitHub Awesome Copilot](https://github.com/github/awesome-copilot) - Community resources
- [Agent Skills Specification](https://agentskills.io/specification) - Skills standard

---

**Built with ❤️ by the community, for the community.**
