# Documentação do Instalador de AI Tools

Guia abrangente para o script `install-ai-tools.sh` - instalador unificado para RTK, Caveman e Superpowers em múltiplos agentes de codificação de IA.

## Índice

- [Visão Geral](#visão-geral)
- [Instalação](#instalação)
- [Descrições das Ferramentas](#descrições-das-ferramentas)
- [Configuração por Agente](#configuração-por-agente)
- [Suporte por Plataforma](#suporte-por-plataforma)
- [Uso Avançado](#uso-avançado)
- [Solução de Problemas](#solução-de-problemas)

## Visão Geral

O script `install-ai-tools.sh` fornece uma interface unificada para instalar e configurar ferramentas de otimização de IA em múltiplos agentes de codificação. Ele gerencia:

- **RTK (Rust Token Killer)**: Otimização de comandos de terminal
- **Caveman**: Stack de compressão de tokens (5 ferramentas)
- **Superpowers**: Framework de skills de desenvolvimento estruturado

### Funcionalidades Principais

- **Multiplataforma**: Linux, macOS, Windows (PowerShell, Git Bash, WSL)
- **Específico por agente**: Configuração otimizada por agente de IA
- **Tratamento de erros**: Continua em falhas individuais com avisos claros
- **Modos seguros**: Opções de dry-run e verbose para testes seguros
- **Auto-detecção**: Detecta SO, shells e agentes instalados

## Instalação

### Pré-requisitos

- **Linux/macOS**: Bash shell, curl
- **Windows**: PowerShell, Git Bash ou WSL
- **Node.js**: Necessário para Caveman e algumas integrações de agentes
- **Rust**: Opcional, para instalação alternativa do RTK

### Instalação Básica

```bash
# Tornar script executável
chmod +x install-ai-tools.sh

# Instalar todas as ferramentas para agente padrão (Claude Code)
./install-ai-tools.sh --all

# Instalar ferramentas específicas
./install-ai-tools.sh --rtk
./install-ai-tools.sh --caveman
./install-ai-tools.sh --superpowers
```

## Descrições das Ferramentas

### RTK (Rust Token Killer)

**Propósito**: Reescreve automaticamente comandos de terminal para reduzir o uso de tokens em 60-90%.

**Como funciona**:
- Intercepta comandos de shell antes da execução do agente
- Filtra saída para mostrar apenas informações relevantes
- Exemplo: `cargo test` → mostra apenas falhas, não 500 linhas de testes passando

**Ecossistemas suportados**:
- Git (status, diff, log)
- Cargo/Rust (test, build, check)
- npm/JavaScript (test, build)
- Python (pytest, pip)
- Go (test, build)
- Docker/Kubernetes
- .NET (dotnet test, build)

**Métodos de instalação**:
1. Script oficial (recomendado): `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh`
2. Homebrew: `brew install rtk-ai/tap/rtk`
3. Cargo: `cargo install --git https://github.com/rtk-ai/rtk rtk`

**Importante**: Verifique instalação correta (Token Killer, não Type Kit):
```bash
rtk --version    # Deve mostrar versão
rtk gain         # Deve mostrar economia de tokens (NÃO "command not found")
```

### Caveman

**Propósito**: Stack de otimização de tokens com 5 ferramentas integradas para comunicação comprimida.

**Componentes**:
1. **caveman**: Compressão principal de comunicação (65% de redução de tokens)
2. **caveman-commit**: Otimização de mensagens de commit
3. **caveman-compress**: Compressão de saída
4. **caveman-review**: Otimização de revisão de código
5. **cavemem**: Compressão de memória

**Como funciona**:
- Remove artigos, preenchimentos e cortesias
- Mantém precisão técnica
- Suporta 6 modos de comunicação
- ~75% menor via compressão Caveman

**Instalação**:
```bash
# Instalação em uma linha (detecta todos os agentes automaticamente)
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex
```

### Superpowers

**Propósito**: Framework de skills de desenvolvimento estruturado para engenharia de software disciplinada.

**Skills incluídas**:
- **brainstorming**: Refinamento socrático de requisitos antes de codificar
- **test-driven-development**: Ciclos TDD red-green-refactor
- **systematic-debugging**: Metodologia de depuração em quatro fases
- **writing-skills**: Princípios TDD aplicados à documentação
- **subagent-driven-development**: Desenvolvimento com revisão de código e checkpoints

**Como funciona**:
- Workflows mandatórios (não sugestões)
- Skills carregadas automaticamente no início da sessão
- Agente deve invocar skill quando aplicável (mesmo 1% de chance)
- Impõe práticas disciplinadas

**Instalação**:
```bash
# Claude Code (marketplace oficial)
/plugin install superpowers@claude-plugins-official

# Claude Code (marketplace community)
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

## Configuração por Agente

### Gemini CLI

**Caminhos de configuração**:
- Config: `~/.gemini/settings.json`
- Hooks: `~/.gemini/hooks/`
- Skills: `~/.gemini/skills/`

**Configuração RTK**:
```bash
./install-ai-tools.sh --rtk --gemini
```

**O que é instalado**:
- `~/.gemini/hooks/rtk-hook-gemini.sh` - Processador de hook nativo Rust
- `~/.gemini/GEMINI.md` - Instruções de consciência RTK
- `~/.gemini/settings.json` - Patch com hook BeforeTool

**Uso**:
```bash
# Reescrita automática (transparente)
# Quando Gemini CLI executa: git status
# RTK intercepta e executa: rtk git status

# Verificar economia
rtk gain
```

**Configuração Caveman**:
```bash
./install-ai-tools.sh --caveman --gemini
```

**O que é instalado**:
- Detectado automaticamente pelo instalador Caveman
- Skills: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

### Devin CLI

**Caminhos de configuração**:
- Config: `~/.config/devin/config.json` (Linux/Mac)
- Config: `%APPDATA%\devin\config.json` (Windows)
- Skills: `~/.config/devin/skills/` ou `~/.devin/skills/`
- AGENTS.md: `~/.config/devin/AGENTS.md`

**Configuração RTK**:
```bash
./install-ai-tools.sh --rtk --devin
```

**O que é instalado**:
- `~/.config/devin/AGENTS.md` - Instruções manuais RTK
- Sem suporte de hook nativo ainda (uso manual necessário)

**Uso**:
```bash
# Uso manual (prefixe com rtk)
rtk git status
rtk cargo test
rtk npm test

# Verificar economia
rtk gain
```

**Configuração Caveman**:
```bash
./install-ai-tools.sh --caveman --devin
```

**O que é instalado**:
- Via `npx skills add JuliusBrussee/caveman -a devin`
- Skills: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

**Configuração Superpowers**:
```bash
./install-ai-tools.sh --superpowers --devin
```

**O que é instalado**:
- Instruções de instalação manual de skills
- Requer cópia manual de skills do repositório Superpowers
- Sem suporte nativo ainda

### Devin Desktop

**Caminhos de configuração**:
- Config: `~/.config/devin/config.json` (Linux/Mac)
- Config: `%APPDATA%\devin\config.json` (Windows)
- Skills: `~/.devin/skills/` ou `~/.codeium/windsurf/skills/` (legado)
- Caminhos legados: `~/.windsurf/skills/` (compatibilidade Windsurf)

**Configuração RTK**:
```bash
./install-ai-tools.sh --rtk --devin-desktop
```

**O que é instalado**:
- Mesmo que Devin CLI (instruções AGENTS.md)
- Localizado em `~/.config/devin/AGENTS.md`

**Configuração Caveman**:
```bash
./install-ai-tools.sh --caveman --devin-desktop
```

**O que é instalado**:
- Detecta automaticamente instalação Devin Desktop
- Também detecta caminhos Windsurf legados para compatibilidade
- Skills: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

**Configuração Superpowers**:
```bash
./install-ai-tools.sh --superpowers --devin-desktop
```

**O que é instalado**:
- Use integração Claude Code (Devin Desktop usa backend Claude Code)
- Instale via marketplace de plugins Claude Code
- Skills disponíveis em sessões Devin Desktop

### Claude Code

**Caminhos de configuração**:
- Config: `~/.claude/settings.json`
- Hooks: `~/.claude/hooks/`
- Skills: `~/.claude/skills/`

**Configuração RTK**:
```bash
./install-ai-tools.sh --rtk --claude
```

**O que é instalado**:
- `~/.claude/hooks/rtk-rewrite.sh` - Hook shell para reescrita de comandos
- `~/.claude/RTK.md` - Consciência RTK (10 linhas, apenas meta comandos)
- `~/.claude/settings.json` - Patch com hook PreToolUse
- `~/.claude/CLAUDE.md` - Adiciona referência @RTK.md

**Uso**:
```bash
# Reescrita automática (transparente)
# Quando Claude Code executa: git status
# RTK intercepta e executa: rtk git status

# Verificar economia
rtk gain
```

**Configuração Caveman**:
```bash
./install-ai-tools.sh --caveman --claude
```

**O que é instalado**:
- Via `claude plugin marketplace add JuliusBrussee/caveman`
- Skills: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

**Configuração Superpowers**:
```bash
./install-ai-tools.sh --superpowers --claude
```

**O que é instalado**:
- Via `/plugin install superpowers@claude-plugins-official`
- Skills: brainstorming, TDD, systematic debugging, writing-skills

### Cursor

**Caminhos de configuração**:
- Config: `~/.cursor/settings.json`
- Hooks: `~/.cursor/hooks.json`
- Skills: `~/.cursor/skills/`

**Configuração RTK**:
```bash
./install-ai-tools.sh --rtk --cursor
```

**O que é instalado**:
- Hook Cursor em `~/.cursor/hooks.json`
- Reescrita transparente de comandos

**Configuração Caveman**:
```bash
./install-ai-tools.sh --caveman --cursor
```

**O que é instalado**:
- Via `npx skills add JuliusBrussee/caveman -a cursor`
- Skills: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

**Configuração Superpowers**:
```bash
./install-ai-tools.sh --superpowers --cursor
```

**O que é instalado**:
- Via marketplace de plugins Cursor
- Skills: brainstorming, TDD, systematic debugging

### OpenCode

**Caminhos de configuração**:
- Config: `~/.config/opencode/opencode.json`
- Skills: `~/.config/opencode/skills/`
- Plugins: `~/.config/opencode/plugins/`
- Rules: `~/.config/opencode/AGENTS.md`

**Configuração RTK**:
```bash
./install-ai-tools.sh --rtk --opencode
```

**O que é instalado**:
- `~/.config/opencode/plugins/rtk.ts` - Plugin OpenCode para reescrita de comandos
- `~/.config/opencode/rules/rtk.md` - Regras RTK (criado por `rtk init -g --opencode`)
- Requer o binário `rtk` no PATH

**Uso**:
```bash
# Reescrita automática (transparente)
# Quando OpenCode executa: git status
# O plugin RTK intercepta e executa: rtk git status

# Verificar economia
rtk gain
```

**Configuração Caveman**:
```bash
./install-ai-tools.sh --caveman --opencode
```

**O que é instalado**:
- Via `npx -y github:JuliusBrussee/caveman -- --only opencode`
- Plugin e skills do OpenCode: `/caveman`, `/caveman-commit`, `/caveman-compress`, `/caveman-review`

**Configuração Superpowers**:
```bash
./install-ai-tools.sh --superpowers --opencode
```

**O que é instalado**:
- Instalação manual de skills em `~/.config/opencode/skills/`
- Use o comando `skill` no OpenCode para carregá-las

## Suporte por Plataforma

### Linux

**Suporte completo** para todas as ferramentas e agentes:
- Scripts shell funcionam nativamente
- Todos os hooks funcionam corretamente
- Gerenciadores de pacotes: apt, yum, dnf, etc.

**Instalação**:
```bash
./install-ai-tools.sh --all --all-agents
```

### macOS

**Suporte completo** para todas as ferramentas e agentes:
- Scripts shell funcionam nativamente
- Homebrew disponível para instalações alternativas
- Todos os hooks funcionam corretamente

**Instalação**:
```bash
./install-ai-tools.sh --all --all-agents
```

**Alternativa via Homebrew**:
```bash
# RTK
brew install rtk-ai/tap/rtk
```

### Windows

**Suporte varia por shell**:

#### Git Bash (Recomendado)
- **Suporte completo** para todas as ferramentas e agentes
- Hooks funcionam corretamente
- Melhor compatibilidade

**Instalação**:
```bash
# Execute no Git Bash
./install-ai-tools.sh --all --all-agents
```

#### PowerShell
- **Suporte limitado** para RTK (sem hooks)
- **Instalação manual** necessária para Caveman
- **Sem suporte de hooks** para reescrita de comandos

**Instalação**:
```bash
# Execute no PowerShell
.\install-ai-tools.sh --all --all-agents
```

**Instalação manual Caveman**:
```powershell
irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex
```

#### WSL (Windows Subsystem for Linux)
- **Suporte completo** (igual ao Linux)
- **Recomendado** para suporte completo de hooks
- Melhor opção para usuários Windows

**Instalação**:
```bash
# Execute no WSL
./install-ai-tools.sh --all --all-agents
```

## Uso Avançado

### Modo Dry-Run

Visualize alterações sem executar:
```bash
./install-ai-tools.sh --all --dry-run
```

**Saída**: Mostra o que seria instalado/modificado sem fazer alterações.

### Modo Verbose

Progresso detalhado da instalação:
```bash
./install-ai-tools.sh --all --verbose
```

**Saída**: Logging detalhado de cada passo, útil para debugging.

### Combinação de Opções

Múltiplas opções podem ser combinadas:
```bash
# Instala RTK para Gemini CLI com saída detalhada
./install-ai-tools.sh --rtk --gemini --verbose

# Instala todas as ferramentas para todos os agentes com dry-run
./install-ai-tools.sh --all --all-agents --dry-run

# Instala Caveman para Devin CLI e Claude Code
./install-ai-tools.sh --caveman --devin --claude
```

### Tratamento de Erros

O script continua em falhas individuais:
```bash
./install-ai-tools.sh --all --all-agents
```

**Comportamento**:
- Se RTK falhar, continua para Caveman
- Se Caveman falhar, continua para Superpowers
- Mostra avisos para falhas
- Exibe resumo no final
- Permite reexecutar apenas componentes que falharam

### Instalação Seletiva

Instale apenas ferramentas específicas para agentes específicos:
```bash
# RTK para Gemini CLI apenas
./install-ai-tools.sh --rtk --gemini

# Caveman para Devin CLI apenas
./install-ai-tools.sh --caveman --devin

# Superpowers para Claude Code apenas
./install-ai-tools.sh --superpowers --claude
```

## Solução de Problemas

### Problemas de Instalação RTK

**Problema**: RTK gain mostra "command not found"
**Solução**: RTK errado instalado (Type Kit em vez de Token Killer)
```bash
# Desinstale RTK errado
cargo uninstall rtk

# Reinstale RTK correto
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh

# Verifique
rtk gain  # Deve mostrar economia de tokens
```

**Problema**: RTK não encontrado após instalação cargo
**Solução**: Cargo bin não no PATH
```bash
# Adicione ao ~/.bashrc ou ~/.zshrc
export PATH="$HOME/.cargo/bin:$PATH"

# Recarregue shell
source ~/.bashrc
```

### Problemas de Instalação Caveman

**Problema**: comando npx não encontrado
**Solução**: Instale Node.js
```bash
# macOS
brew install node

# Ubuntu/Debian
sudo apt install nodejs npm

# Windows
# Baixe de https://nodejs.org/
```

**Problema**: Caveman não detectado para agente
**Solução**: Instalação manual
```bash
# Para Devin CLI
npx skills add JuliusBrussee/caveman -a devin

# Para Cursor
npx skills add JuliusBrussee/caveman -a cursor
```

### Problemas de Instalação Superpowers

**Problema**: Plugin Claude Code não encontrado
**Solução**: Registre marketplace primeiro
```bash
/plugin marketplace add claude-plugins-official
/plugin install superpowers@claude-plugins-official
```

**Problema**: Skills não ativando
**Solução**: Reinicie Claude Code
- Skills carregam no início da sessão
- Inicie nova sessão de chat
- Pergunte: "Tell me about your superpowers"

### Problemas Específicos do Windows

**Problema**: Script PowerShell falha
**Solução**: Use Git Bash ou WSL
```bash
# Git Bash (recomendado)
./install-ai-tools.sh --all

# WSL (suporte completo)
wsl bash -c './install-ai-tools.sh --all'
```

**Problema**: Hooks não funcionando no Windows
**Solução**: Use WSL para suporte completo de hooks
```bash
# Instale RTK no WSL
wsl bash -c 'curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh'
wsl bash -c 'rtk init -g'
```

### Problemas Específicos por Agente

**Problema**: Devin CLI não detectando ferramentas
**Solução**: Verifique caminhos de configuração
```bash
# Linux/Mac
ls ~/.config/devin/
cat ~/.config/devin/AGENTS.md

# Windows
ls %APPDATA%\devin\
type %APPDATA%\devin\AGENTS.md
```

**Problema**: Hooks Gemini CLI não funcionando
**Solução**: Reinicie Gemini CLI
```bash
# Gemini CLI precisa de reinício após instalação de hook
# Saia e reinicie Gemini CLI
```

## Suporte e Recursos

### Documentação Oficial
- **RTK**: https://www.rtk-ai.app/docs/
- **Caveman**: https://getcaveman.dev/
- **Superpowers**: https://claude.com/plugins/superpowers

### Repositórios GitHub
- **RTK**: https://github.com/rtk-ai/rtk
- **Caveman**: https://github.com/JuliusBrussee/caveman
- **Superpowers**: https://github.com/obra/superpowers

### Relatório de Problemas
- Problemas RTK: https://github.com/rtk-ai/rtk/issues
- Problemas Caveman: https://github.com/JuliusBrussee/caveman/issues
- Problemas Superpowers: https://github.com/obra/superpowers/issues
- Problemas instalador: https://github.com/afonsoft/agents-skills/issues

## Melhores Práticas

1. **Sempre verifique instalações**: Verifique `rtk gain` após instalação RTK
2. **Use dry-run primeiro**: Visualize alterações antes de executar
3. **Reinicie agentes**: A maioria das ferramentas requer reinício do agente após instalação
4. **Verifique caminhos**: Verifique caminhos de configuração para sua plataforma
5. **Use WSL no Windows**: Para suporte completo de hooks no Windows
6. **Atualize regularmente**: Mantenha ferramentas atualizadas para recursos mais recentes
7. **Monitore economia**: Use `rtk gain` para rastrear economia de tokens
8. **Teste funcionalidade**: Verifique se ferramentas funcionam após instalação

## Informações de Versão

- **Versão do script**: 1.0.0
- **Última atualização**: 2025-06-18
- **RTK suportado**: 0.23.1+
- **Caveman suportado**: Mais recente do branch main
- **Superpowers suportado**: Mais recente do branch main
