# agents-skills

Uma coleção de **Agent Skills** (e **hooks** de início de sessão) para aprimorar agentes de codificação de IA em múltiplos IDEs e CLIs. Cada skill é um arquivo `SKILL.md` independente (conforme a [especificação Agent Skills](https://agentskills.io)) com recursos opcionais agrupados, seguindo princípios de harness engineering para desenvolvimento centrado no agente.

> Este repositório distribui **apenas skills + hooks**. Não há pasta `rules/` ou `knowledge/` — orientações específicas do projeto pertencem ao seu próprio `AGENTS.md`/`CLAUDE.md`.

**🌐 Idiomas**: [English](README.md) | [Português](README.pt-br.md)

## 🚀 Funcionalidades

- **📋 Skills** — Instruções independentes e específicas de tarefas com recursos agrupados
- **🪝 Hooks** — Hooks de início de sessão que injetam o catálogo de skills instaladas no contexto do agente
- **⚡ Workflows** — Workflows agênticos para automação do GitHub Actions
- **🛠️ Instalador** — Um script para instalar skills + hooks em múltiplos IDEs/CLIs
- **🧹 Scripts utilitários** — Ferramentas de manutenção e limpeza do sistema
- **⚡ AI Tools** — Instalador unificado para RTK, Caveman e Superpowers

## 📁 Estrutura do Repositório

```
agents-skills/
├── skills/              # Agent Skills (formato SKILL.md)
├── hooks/               # Hooks de início de sessão por IDE
├── workflows/           # Workflows agênticos para automação
├── .agents/             # Infraestrutura de harness (CONTEXT, RULES, TOOLS, ...)
├── install.sh           # Instalador (--all, --devin, --claude, --cursor, ...)
├── install-ai-tools.sh  # Instalador de AI Tools (RTK, Caveman, Superpowers)
├── rm-backup.sh         # Remove arquivos *.backup.* criados pelo instalador
├── clear-up-linux.sh    # Script de limpeza do sistema Linux
└── git-cleanup-repos.sh # Script de manutenção de repositórios Git
```

## 🎯 Início Rápido

```bash
# Instala skills + hooks + AGENTS.md para todos os IDEs/CLIs suportados
./install.sh --all

# Instala para uma ferramenta específica
./install.sh --devin
./install.sh --devin-desktop
./install.sh --devin-cli
./install.sh --claude
./install.sh --opencode

# Combine alvos
./install.sh --cursor --vscode

# Visualize sem alterar nada
./install.sh --devin --dry-run
```

### IDEs/CLIs Suportados

| Ferramenta | Skills | Hooks |
|------------|--------|-------|
| Devin | `~/.devin/skills`, `~/.cognition/skills` | `~/.devin/hooks` |
| Devin CLI | `~/.config/devin/skills` | `~/.config/devin/hooks` |
| Devin Desktop | `~/.devin/skills` | `~/.devin/hooks` |
| OpenCode | `~/.opencode/skills`, `~/.config/opencode/skills` | `~/.opencode/hooks`, `~/.config/opencode/hooks` |
| OpenCode Desktop | `~/.opencode/skills` | `~/.opencode/hooks` |
| OpenCode CLI | `~/.config/opencode/skills` | `~/.config/opencode/hooks` |
| Claude Code | `~/.claude/skills` | `~/.claude/hooks` |
| Cursor | `~/.cursor/skills` | `~/.cursor/hooks` |
| VS Code (Copilot) | `~/.github/skills` | `~/.github/hooks` |
| Gemini CLI | `~/.gemini/skills` | `~/.gemini/hooks` |
| Base (todos) | `~/.agents/skills` | — |

## 🧰 Catálogo de Skills

### Workflow de agente e produtividade
`brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents`, `systematic-debugging`, `test-driven-development`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`, `finishing-a-development-branch`, `using-git-worktrees`, `writing-skills`, `find-skills`, `memory-merger`, `building-mcp-servers`, `json-canvas`, `defuddle`

### Comunicação comprimida
`caveman`, `caveman-commit`, `caveman-compress`, `caveman-review`

### .NET / C#
`aspnet-core-api`, `modern-csharp-coding-standards`, `design-patterns`, `performance-optimization`, `security-jwt`, `testing-xunit`, `microsoft-agent-framework`, `microsoft-code-reference`, `microsoft-docs`, `microsoft-skill-creator`

### Framework ABP
`abp-angular`, `abp-app-nolayers`, `abp-application-layer`, `abp-authorization`, `abp-blazor`, `abp-cli`, `abp-core`, `abp-ddd`, `abp-dependency-rules`, `abp-development-flow`, `abp-ef-core`, `abp-infrastructure`, `abp-microservice`, `abp-module`, `abp-mongodb`, `abp-multi-tenancy`, `abp-mvc`, `abp-testing`, `migrate-aspnetboilerplate-to-abp`, `fluentui-blazor`

### Dados / SQL
`ef-core`, `efcore-patterns`, `entity-framework-core`, `postgresql-code-review`, `postgresql-optimization`, `sql-code-review`, `sql-optimization`

### Frontend e revisão
`premium-frontend-ui`, `web-design-reviewer`, `chrome-devtools`

### Harness e meta
`harness-repo-structure`, `github-issues`

> Execute `./install.sh --all` e inicie uma sessão — o hook de início de sessão injeta o catálogo para que o agente possa escolher a skill certa através da `description` / `when_to_use` de cada skill.

## ⚡ Instalador de AI Tools

O script `install-ai-tools.sh` fornece instalação unificada de ferramentas populares de otimização de IA:

### RTK (Rust Token Killer)
- **Propósito**: Otimizador de tokens que reescreve automaticamente comandos de terminal
- **Economia**: Reduz o uso de tokens filtrando a saída de comandos (ex: mostrando apenas falhas nos testes)
- **Suporte**: Claude Code, VS Code Copilot, Cursor, Gemini CLI, OpenCode, OpenClaw
- **Instalação**: Detecta automaticamente o RTK correto (Token Killer vs Type Kit), inicializa hooks

### Caveman
- **Propósito**: Stack de otimização de tokens com 5 ferramentas integradas
- **Funcionalidades**: Comunicação comprimida, otimização de commits, melhoria de revisão
- **Suporte**: Claude Code, Cursor, Gemini CLI, OpenCode, OpenClaw, Codex CLI
- **Instalação**: Instalação em uma linha que detecta e configura todos os agentes instalados

### Superpowers
- **Propósito**: Framework de skills de desenvolvimento estruturado
- **Skills**: Brainstorming, TDD, depuração sistemática, writing-skills, desenvolvimento de subagentes
- **Suporte**: Claude Code (marketplace de plugins), Cursor, OpenCode, Codex, Gemini CLI
- **Instalação**: Via marketplace de plugins do Claude Code (oficial ou community)

### Uso
```bash
# Instala todas as ferramentas AI
./install-ai-tools.sh --all

# Instala ferramentas específicas
./install-ai-tools.sh --rtk
./install-ai-tools.sh --caveman
./install-ai-tools.sh --superpowers

# Combine ferramentas
./install-ai-tools.sh --rtk --caveman

# Configure para agentes específicos
./install-ai-tools.sh --rtk --gemini              # RTK para Gemini CLI
./install-ai-tools.sh --caveman --devin           # Caveman para Devin CLI
./install-ai-tools.sh --rtk --devin               # RTK para Devin CLI
./install-ai-tools.sh --all --all-agents          # Todas as ferramentas para todos os agentes

# Modo de preview seguro
./install-ai-tools.sh --all --dry-run

# Modo detalhado
./install-ai-tools.sh --all --verbose
```

**Tratamento de Erros**: O script continua a instalação mesmo se componentes individuais falharem. Cada tentativa de instalação é rastreada separadamente, e avisos são exibidos para falhas. Um resumo no final mostra quais componentes tiveram sucesso e quais falharam, permitindo que você resolva problemas específicos sem precisar executar novamente as instalações bem-sucedidas.

### Configuração Específica por Agente

O instalador suporta configuração específica por agente para integração otimizada:

#### Gemini CLI
- **RTK**: Suporte nativo via `rtk init -g --gemini`
- **Caveman**: Detectado automaticamente e instalado pelo instalador Caveman
- **Superpowers**: Ainda não suportado (use Claude Code em vez disso)

#### Devin CLI
- **RTK**: Configuração manual via AGENTS.md (ainda sem suporte nativo)
- **Caveman**: Instalado via `npx skills add JuliusBrussee/caveman -a devin`
- **Superpowers**: Instalação manual de skills (ainda sem suporte nativo)
- **Docs**: [Devin CLI Setup](docs/devin-cli-setup.md)

#### Devin Desktop
- **RTK**: Configuração manual via AGENTS.md
- **Caveman**: Detectado automaticamente se Devin Desktop estiver instalado
- **Superpowers**: Instalação manual de skills (ainda sem suporte nativo)
- **Docs**: [Devin Desktop Setup](docs/devin-desktop-setup.md)

#### OpenCode CLI
- **RTK**: Configuração manual via AGENTS.md (ainda sem suporte nativo)
- **Caveman**: Instalação manual de skills (ainda sem suporte nativo)
- **Superpowers**: Instalação manual de skills (ainda sem suporte nativo)
- **Docs**: [OpenCode CLI Setup](docs/opencode-cli-setup.md)

#### OpenCode Desktop
- **RTK**: Configuração manual via AGENTS.md
- **Caveman**: Instalação manual de skills (ainda sem suporte nativo)
- **Superpowers**: Instalação manual de skills (ainda sem suporte nativo)
- **Docs**: [OpenCode Desktop Setup](docs/opencode-desktop-setup.md)

#### Claude Code
- **RTK**: Suporte nativo via `rtk init -g`
- **Caveman**: Detectado automaticamente e instalado
- **Superpowers**: Suporte nativo de marketplace de plugins

#### Cursor
- **RTK**: Suporte nativo via `rtk init -g --agent cursor`
- **Caveman**: Detectado automaticamente e instalado
- **Superpowers**: Suporte nativo de plugins

### Matriz de Suporte

| Ferramenta | Gemini CLI | Devin CLI | Devin Desktop | OpenCode CLI | OpenCode Desktop | Claude Code | Cursor |
|------------|------------|-----------|---------------|--------------|------------------|-------------|--------|
| **RTK** | ✅ Nativo | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ✅ Nativo | ✅ Nativo |
| **Caveman** | ✅ Auto | ✅ npx | ✅ Auto | ⚠️ Manual | ⚠️ Manual | ✅ Auto | ✅ Auto |
| **Superpowers** | ❌ Não | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ✅ Nativo | ✅ Nativo |

**Legenda:**
- ✅ Nativo/Completo: Instalação automática com suporte completo
- ⚠️ Manual: Requer configuração manual ou suporte parcial
- ❌ Não: Não suportado ou requer solução alternativa

### Suporte Multiplataforma
- **Linux**: Suporte completo via scripts shell
- **macOS**: Suporte completo via scripts shell e Homebrew
- **Windows**: Suporte via WSL ou Git Bash (Windows nativo tem suporte limitado de hooks)

### Funcionalidades
- **Auto-detecção**: Detecta SO e agentes instalados automaticamente
- **Verificações de segurança**: Verificação pré-instalação para evitar conflitos
- **Modo dry-run**: Visualize alterações antes da execução
- **Logging detalhado**: Progresso detalhado da instalação
- **Verificação pós-instalação**: Confirma configuração bem-sucedida
- **Tratamento de erros**: Continua instalação mesmo se componentes individuais falharem, com avisos claros

## 🛠️ Scripts Utilitários

### install-ai-tools.sh
Instalador unificado para ferramentas de otimização de IA (RTK, Caveman, Superpowers):
```bash
./install-ai-tools.sh --all                    # Instala todas as ferramentas
./install-ai-tools.sh --rtk --caveman         # Instala ferramentas específicas
./install-ai-tools.sh --all --dry-run         # Visualiza alterações
./install-ai-tools.sh --all --verbose         # Saída detalhada
```

### rm-backup.sh
Remove arquivos/diretórios `*.backup.*` criados pelo instalador:
```bash
./rm-backup.sh                    # Remove apenas backups
./rm-backup.sh --uninstall       # Remove backups E instalações completas
./rm-backup.sh --dry-run         # Visualiza o que seria removido
./rm-backup.sh --verbose         # Saída detalhada
```

### clear-up-linux.sh
Limpeza do sistema Linux com muitas categorias (veja [CLEAR-UP-README.md](CLEAR-UP-README.md)):
```bash
sudo ./clear-up-linux.sh --dry-run --verbose   # simula
sudo ./clear-up-linux.sh --force               # não-interativo
```

### git-cleanup-repos.sh
Manutenção recursiva de repositórios Git com rastreamento de espaço em disco:
```bash
chmod +x git-cleanup-repos.sh && ./git-cleanup-repos.sh
./git-cleanup-repos.sh --verbose           # Saída detalhada
./git-cleanup-repos.sh --dry-run           # Visualiza alterações
```
**Funcionalidades:**
- Git fetch, pull, limpeza de reflog, garbage collection
- Remoção de artefatos de build (bin, obj, .vs, node_modules)
- Limpeza de cache de gerenciadores de pacotes (npm, yarn, nuget)
- Limpeza de diretórios de cache específicos do Windows
- **Rastreamento de espaço em disco**: Mede espaço antes/depois da limpeza, exibe espaço recuperado
- **Multiplataforma**: Suporte Linux, macOS, Windows
- **Logging detalhado**: Todas as operações registradas com timestamps

## 🤝 Contribuindo

Veja as [Diretrizes de Contribuição](CONTRIBUTING.md).

1. **Fork** o repositório
2. **Crie** uma branch de feature
3. **Adicione** sua skill (uma pasta sob `skills/` com um `SKILL.md` válido) — a skill `writing-skills` é um bom guia
4. **Valide**: `shellcheck install.sh` e `./install.sh --devin --dry-run`
5. **Abra** um pull request

## 📖 Documentação

- [AGENTS.md](AGENTS.md) — Índice do repositório e convenções
- [Guia do Instalador de AI Tools](AI-TOOLS-INSTALLER.pt-br.md) — Guia abrangente para instalação de RTK, Caveman, Superpowers
- [Diretrizes de Contribuição](CONTRIBUTING.md)
- [Código de Conduta](CODE_OF_CONDUCT.md)
- [Política de Segurança](SECURITY.md)

## 📝 Atualizações Recentes

### Melhorias do Instalador de AI Tools
- **Configuração Específica por Agente**: Adicionado suporte para Gemini CLI, Devin CLI, Devin Desktop, OpenCode CLI e OpenCode Desktop
- **Detecção de Shell**: Suporte aprimorado para Windows com detecção de PowerShell, Git Bash e WSL
- **Tratamento de Erros**: Tratamento de erros aprimorado com continuação em falhas individuais
- **Matriz de Configuração**: Adicionada matriz de suporte mostrando suporte de ferramenta por agente
- **Documentação Abrangente**: Criado guia detalhado AI-TOOLS-INSTALLER.md

### Atualizações de Caminhos de Ferramentas
- **Suporte Devin Desktop**: Adicionado suporte para Devin Desktop (sucessor local do Windsurf)
- **Caminhos Devin CLI**: Atualizados para `~/.config/devin/`
- **Suporte OpenCode**: Adicionados caminhos `~/.opencode/` e `~/.config/opencode/` para Desktop e CLI
- **Limpeza Legada**: Removidos caminhos Windsurf; OpenClaw mantido como opção legada

### Scripts Aprimorados
- **git-cleanup-repos.sh**: Adicionada limpeza de cache de gerenciadores de pacotes multiplataforma (npm, yarn, nuget) e rastreamento de espaço em disco
- **rm-backup.sh**: Adicionada opção `--uninstall` para remoção completa de instalações e backups
- **install-ai-tools.sh**: Novo instalador unificado para RTK, Caveman e Superpowers com configuração específica por agente

### Melhorias de Qualidade de Skills
- Atualizadas 11 descrições de skills para seguir especificação writing-skills
- Todas as descrições agora começam com padrão "Use when..."
- Removidos detalhes de processo das descrições, focando em condições de acionamento
- Aprimorada conformidade com Claude Search Optimization (CSO)

## 📄 Licença

Licenciado sob a [Licença MIT](LICENSE).

## 🔗 Projetos Relacionados

- [Especificação Agent Skills](https://agentskills.io/specification)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [RTK - Rust Token Killer](https://www.rtk-ai.app/)
- [Caveman - Stack de Otimização de Tokens](https://getcaveman.dev/)
- [Superpowers - Skills de Desenvolvimento Estruturado](https://claude.com/plugins/superpowers)
