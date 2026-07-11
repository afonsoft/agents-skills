#!/bin/bash

# Script de instalacao das skills, rules e knowledge do Agent Skills
# Suporta instalacao seletiva por IDE ou instalacao completa
#
# Uso:
#   ./install.sh --all, -a        Instala para todas as IDEs/CLIs
#   ./install.sh --devin, -d      Instala para Devin / Devin Review / Devin CLI
#   ./install.sh --claude, -c     Instala para Claude Code
#   ./install.sh --devin-desktop, -dd   Instala para Devin Desktop (formerly Windsurf)
#   ./install.sh --windsurf, -w   Instala para Windsurf (Cascade) - legado, use --devin-desktop
#   ./install.sh --vscode, -v     Instala para VS Code (GitHub Copilot)
#   ./install.sh --cursor         Instala para Cursor
#   ./install.sh --gemini, -g     Instala para Gemini CLI (Google)
#   ./install.sh --antigravity    Instala para Google Antigravity IDE
#   ./install.sh --agy            Instala para Google Antigravity CLI (agy)
#   ./install.sh --openclaw, -o   Instala para OpenClaw
#   ./install.sh --opencode, -p   Instala para OpenCode
#   ./install.sh --dry-run        Visualiza o que seria instalado (nao altera)
#   ./install.sh --github-token <TOKEN>  Token GitHub para download do RTK
#   ./install.sh --help, -h       Exibe ajuda
#
# Variaveis de ambiente:
#   GITHUB_TOKEN                   Token GitHub para download do RTK (alternativa ao --github-token)
#
# Multiplas IDEs/CLIs podem ser combinadas:
#   ./install.sh --devin --claude --devin-desktop
#   ./install.sh --all --github-token ghp_xxx

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Funcoes de log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Flags de IDEs selecionadas
INSTALL_VSCODE=false
INSTALL_WINDSURF=false
INSTALL_DEVIN_DESKTOP=false
INSTALL_CURSOR=false
INSTALL_DEVIN=false
INSTALL_CLAUDE=false
INSTALL_GEMINI=false
INSTALL_ANTIGRAVITY=false
INSTALL_AGY=false
INSTALL_OPENCLAW=false
INSTALL_OPENCODE=false

# Modo dry-run (nao faz alteracoes, apenas preview)
DRY_RUN=false

# GitHub Token para download do RTK (parametro --github-token ou env GITHUB_TOKEN)
GITHUB_TOKEN_PARAM=""

# ============================================================================
# HELP
# ============================================================================

show_help() {
    echo
    echo -e "${CYAN}Agent Skills - Instalador${NC}"
    echo
    echo -e "${YELLOW}Uso:${NC}"
    echo "  ./install.sh [opcoes]"
    echo
    echo -e "${YELLOW}Opcoes de IDE:${NC}"
    echo "  --devin,    -d          Instala para Devin / Devin Review / Devin CLI"
    echo "  --claude,   -c          Instala para Claude Code"
    echo "  --devin-desktop, -dd   Instala para Devin Desktop (formerly Windsurf)"
    echo "  --windsurf, -w          Instala para Windsurf (Cascade) - legado"
    echo "  --vscode,   -v          Instala para VS Code (GitHub Copilot)"
    echo "  --cursor                Instala para Cursor"
    echo "  --gemini,   -g          Instala para Gemini CLI (Google)"
    echo "  --antigravity           Instala para Google Antigravity IDE"
    echo "  --agy                   Instala para Google Antigravity CLI (agy)"
    echo "  --openclaw, -o          Instala para OpenClaw"
    echo "  --opencode, -p          Instala para OpenCode"
    echo "  --all,      -a          Instala para todas as IDEs/CLIs"
    echo
    echo -e "${YELLOW}Outras opcoes:${NC}"
    echo "  --dry-run               Visualiza o que seria instalado (nao altera)"
    echo "  --github-token <TOKEN>  Token GitHub para download do RTK (evita rate-limit)"
    echo "  --help, -h              Exibe esta mensagem de ajuda"
    echo
    echo -e "${YELLOW}Variaveis de ambiente:${NC}"
    echo "  GITHUB_TOKEN            Token GitHub para download do RTK (alternativa ao --github-token)"
    echo
    echo -e "${YELLOW}Exemplos:${NC}"
    echo "  ./install.sh --all                    # Todas as IDEs"
    echo "  ./install.sh --vscode                 # Apenas VS Code"
    echo "  ./install.sh --devin --claude         # Devin + Claude"
    echo "  ./install.sh --devin-desktop --vscode # Devin Desktop + VS Code"
    echo "  ./install.sh --gemini                 # Apenas Gemini CLI"
    echo "  ./install.sh -a                       # Todas as IDEs/CLIs (atalho)"
    echo "  ./install.sh -d -c -dd                # Devin + Claude + Devin Desktop (atalho)"
    echo "  ./install.sh -c                       # Apenas Claude Code (atalho)"
    echo "  ./install.sh --all --github-token ghp_xxx  # Com token GitHub para RTK"
    echo "  GITHUB_TOKEN=ghp_xxx ./install.sh --all    # Mesmo via env var"
    echo
    echo -e "${YELLOW}O que sera instalado:${NC}"
    echo
    echo "  IDE/CLI          Skills              Rules                    Knowledge"
    echo "  --------------- ------------------- ------------------------ -------------------"
    echo "  VS Code          ~/.github/skills    ~/.copilot/instructions  ~/.copilot/knowledge"
    echo "                                       ~/.github/copilot-instructions.md (consolidado)"
    echo "  Devin Desktop    ~/.devin/skills     ~/.devin/rules           ~/.devin/knowledge"
    echo "  (formerly       ~/.codeium/windsurf/skills (legacy read)    ~/.codeium/windsurf/knowledge (legacy)"
    echo "   Windsurf)       ~/.agents/skills (universal)                ~/.devin/AGENTS.md"
    echo "  Windsurf         ~/.windsurf/skills  ~/.windsurf/rules        ~/.windsurf/knowledge"
    echo "  (legacy)         ~/.windsurfrules (consolidado)"
    echo "                   ~/.codeium/windsurf/memories/global_rules.md (global, sempre ativo)"
    echo "  Cursor           ~/.cursor/skills    ~/.cursor/rules          ~/.cursor/knowledge"
    echo "                                       ~/.cursorrules (consolidado)"
    echo "  Devin            ~/.agents/skills     (via Cursor/Devin Desktop) ~/.devin/knowledge"
    echo "                   + ~/.cognition/skills  (Devin-specific)"
    echo "                   + ~/.devin/skills  (compatibilidade)"
    echo "                   + ~/.config/devin/skills  (Devin CLI)"
    echo "                   + ~/.config/devin/knowledge  (Devin CLI)"
    echo "                   + AGENTS.md -> ~/.devin/AGENTS.md"
    echo "  Claude           ~/.claude/skills    ~/.claude/rules          ~/.claude/knowledge"
    echo "                                       ~/.claude/CLAUDE.md (instrucoes globais)"
    echo "                                       ~/.claude/settings.json (permissoes)"
    echo "                                       ~/.claude/commands/ (slash commands)"
    echo "  Gemini CLI       ~/.gemini/skills    ~/.gemini/GEMINI.md      ~/.gemini/knowledge"
    echo "  Google Antigravity ~/.gemini/skills    ~/.gemini/ANTIGRAVITY.md ~/.gemini/knowledge"
    echo "  IDE              .agent/skills (workspace) .agent/CLAUDE.md .agent/knowledge"
    echo "  Google Antigravity ~/.gemini/antigravity-cli/skills  (CLI-specific)"
    echo "  CLI (agy)        .agent/skills (workspace) .agent/CLAUDE.md .agent/knowledge"
    echo "                  ~/.gemini/antigravity-cli/AGY.md  (CLI-specific)"
    echo "  OpenClaw         ~/.openclaw/skills   ~/.openclaw/rules        ~/.openclaw/knowledge"
    echo "  OpenCode         ~/.config/opencode/skills  ~/.config/opencode/AGENTS.md  —"
    echo
    echo "  Base: ~/.agents/skills (sempre instalado)"
    echo "  Base: ~/.agents/harness/ (templates do Agent Harness)"
    echo "  Base: ~/.agents/AGENTS_CLI.md (instrucoes genericas)"
    echo
    echo -e "${YELLOW}Documentacao:${NC}"
    echo "  VS Code:      https://code.visualstudio.com/docs/copilot/customization/custom-instructions"
    echo "  Devin Desktop: https://docs.devin.ai/desktop/devin-desktop-faq"
    echo "  Windsurf:     https://docs.windsurf.com/windsurf/cascade/agents-md (legacy)"
    echo "  Cursor:       https://docs.cursor.com/context/rules"
    echo "  Devin:        https://docs.devin.ai/work-with-devin/devin-review"
    echo "  Devin CLI:    https://cli.devin.ai/docs/extensibility/skills/overview"
    echo "  Claude:       https://docs.anthropic.com/en/docs/claude-code"
    echo "                https://docs.anthropic.com/en/docs/claude-code/slash-commands"
    echo "  Gemini:       https://geminicli.com/docs/"
    echo "  Antigravity:  https://antigravity.google/docs/cli-overview"
    echo "                https://antigravity.google/docs/ide-overview"
    echo "  OpenClaw:     https://openclaw.dev/docs/"
    echo "  OpenCode:     https://opencode.ai/docs/"
    echo
}

# ============================================================================
# PARSE ARGS
# ============================================================================

parse_args() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-help|--h|-h)
                show_help
                exit 0
                ;;
            --all|-a)
                INSTALL_VSCODE=true
                INSTALL_WINDSURF=true
                INSTALL_DEVIN_DESKTOP=true
                INSTALL_CURSOR=true
                INSTALL_DEVIN=true
                INSTALL_CLAUDE=true
                INSTALL_GEMINI=true
                INSTALL_ANTIGRAVITY=true
                INSTALL_AGY=true
                INSTALL_OPENCLAW=true
                INSTALL_OPENCODE=true
                ;;
            --vscode|-v)
                INSTALL_VSCODE=true
                ;;
            --devin-desktop|-dd)
                INSTALL_DEVIN_DESKTOP=true
                ;;
            --windsurf|-w)
                INSTALL_WINDSURF=true
                ;;
            --cursor)
                INSTALL_CURSOR=true
                ;;
            --devin|-d)
                INSTALL_DEVIN=true
                ;;
            --claude|-c)
                INSTALL_CLAUDE=true
                ;;
            --gemini|-g)
                INSTALL_GEMINI=true
                ;;
            --antigravity)
                INSTALL_ANTIGRAVITY=true
                ;;
            --agy)
                INSTALL_AGY=true
                ;;
            --openclaw|-o)
                INSTALL_OPENCLAW=true
                ;;
            --opencode|-p)
                INSTALL_OPENCODE=true
                ;;
            --dry-run)
                DRY_RUN=true
                ;;
            --github-token)
                shift
                if [ $# -eq 0 ]; then
                    log_error "--github-token requer um valor. Ex: --github-token ghp_xxx"
                    exit 1
                fi
                GITHUB_TOKEN_PARAM="$1"
                ;;
            *)
                log_error "Opcao desconhecida: $1"
                echo "Use --help para ver as opcoes disponiveis."
                exit 1
                ;;
        esac
        shift
    done
}

# ============================================================================
# HELPERS
# ============================================================================

backup_dir_if_exists() {
    local dir_path="$1"
    if [ -d "$dir_path" ] && [ -n "$(ls -A "$dir_path" 2>/dev/null)" ]; then
        local backup_path="${dir_path}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backup: $dir_path -> $backup_path"
        mv "$dir_path" "$backup_path"
    fi
    mkdir -p "$dir_path"
}

backup_file_if_exists() {
    local file_path="$1"
    if [ -f "$file_path" ]; then
        local backup_path="${file_path}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backup: $file_path -> $backup_path"
        cp "$file_path" "$backup_path"
    fi
}

generate_consolidated_rules() {
    local output_file="$1"
    local platform="${2:-}"
    backup_file_if_exists "$output_file"
    : > "$output_file"
    for rule_file in rules/*.instructions.md; do
        if [ -f "$rule_file" ]; then
            # Strip YAML frontmatter, --- separators, and squeeze blank lines
            awk 'BEGIN{fm=0} /^---$/{fm++; if(fm<=2) next} fm>=2||fm==0{print}' "$rule_file" \
                | sed '/^---$/d' \
                | cat -s >> "$output_file"
        fi
    done
    # Inject IDE-specific paths row after Base table
    local ide_row=""
    case "$platform" in
        vscode)        ide_row="| VS Code / Copilot | \`~/.github/skills/\` | \`~/.copilot/instructions/\` | \`~/.copilot/knowledge/\` |" ;;
        devin-desktop) ide_row="| Devin Desktop | \`~/.devin/skills/\` | \`~/.devin/rules/\` | \`~/.devin/knowledge/\` |" ;;
        windsurf)      ide_row="| Windsurf | \`~/.windsurf/skills/\` | \`~/.windsurf/rules/\` | \`~/.windsurf/knowledge/\` |" ;;
        cursor)        ide_row="| Cursor | \`~/.cursor/skills/\` | \`~/.cursor/rules/\` | \`~/.cursor/knowledge/\` |" ;;
        claude)        ide_row="| Claude Code | \`~/.claude/skills/\` | \`~/.claude/rules/\` | \`~/.claude/knowledge/\` |" ;;
        devin)         ide_row="| Devin | \`~/.devin/skills/\` | — | \`~/.devin/knowledge/\` |" ;;
        gemini)        ide_row="| Gemini CLI | \`~/.gemini/skills/\` | \`~/.gemini/GEMINI.md\` | \`~/.gemini/knowledge/\` |" ;;
        antigravity)   ide_row="| Google Antigravity IDE | \`~/.gemini/skills/\` | \`~/.gemini/ANTIGRAVITY.md\` | \`~/.gemini/knowledge/\` |" ;;
        agy)           ide_row="| Google Antigravity CLI (agy) | \`~/.gemini/antigravity-cli/skills/\` | \`~/.gemini/antigravity-cli/AGY.md\` | \`~/.gemini/antigravity-cli/knowledge/\` |" ;;
        opencode)      ide_row="| OpenCode | \`~/.config/opencode/skills/\` | \`~/.config/opencode/AGENTS.md\` | — |" ;;
    esac
    if [ -n "$ide_row" ]; then
        sed -i "/| Base (todas)/a\\$ide_row" "$output_file"
    fi
}

# ============================================================================
# HELPER: copiar knowledge sources (subdiretorios) para destino flat
# ============================================================================

copy_knowledge_sources() {
    local dest_dir="$1"
    local ks_dir="devin/knowledge_sources"
    if [ ! -d "$ks_dir" ]; then
        return 1
    fi
    mkdir -p "$dest_dir"
    for ks_subdir in "$ks_dir"/*/; do
        [ -d "$ks_subdir" ] || continue
        local slug
        slug=$(basename "$ks_subdir")
        if [ -f "$ks_subdir/KNOWLEDGE_SOURCE.md" ]; then
            cp "$ks_subdir/KNOWLEDGE_SOURCE.md" "$dest_dir/${slug}.md"
        fi
    done
    return 0
}

# ============================================================================
# VERIFICACAO
# ============================================================================

check_directory() {
    if [ ! -d "skills" ]; then
        log_error "Pasta skills nao encontrada no diretorio atual!"
        log_info "Execute este script a partir do diretorio raiz do repositorio."
        exit 1
    fi
    if [ ! -d "rules" ]; then
        log_warning "Pasta rules nao encontrada no diretorio atual!"
    fi
    if [ ! -d "devin/knowledge_sources" ]; then
        log_warning "Pasta devin/knowledge_sources nao encontrada no diretorio atual!"
    fi
    # registry.json e exclusivo do AI Marketplace (AI Marketplace) - nao faz parte da instalacao
    if [ -d "mcps" ]; then
        log_info "Diretorio mcps/ encontrado"
    fi
    if [ -d "devin/playbooks" ]; then
        log_info "Diretorio devin/playbooks/ encontrado"
    fi
}

# ============================================================================
# INSTALACAO BASE (sempre executa)
# ============================================================================

install_base() {
    log_info "Instalando base (~/.agents/skills)..."

    if [ -d "$HOME/.agents/skills" ]; then
        local backup_dir="$HOME/.agents/skills.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backup: ~/.agents/skills -> $backup_dir"
        mv "$HOME/.agents/skills" "$backup_dir"
    fi

    mkdir -p "$HOME/.agents"
    cp -a skills "$HOME/.agents/skills"
    log_success "Base instalada em ~/.agents/skills"

    # AGENTS_CLI.md -> ~/.agents/AGENTS_CLI.md (instrucoes genericas do harness)
    if [ -f "AGENTS_CLI.md" ]; then
        backup_file_if_exists "$HOME/.agents/AGENTS_CLI.md"
        cp AGENTS_CLI.md "$HOME/.agents/AGENTS_CLI.md"
        log_success "AGENTS_CLI.md -> ~/.agents/AGENTS_CLI.md"
    fi

    # Criar estrutura de templates do Agent Harness em ~/.agents/harness/
    install_harness_templates

    # Ignore files -> ~/.agents/ (templates para otimizacao de tokens LLM)
    local ignore_files=(".aiignore" ".cursorignore" ".geminiignore" ".devinignore" ".claudeignore" ".windsurfignore")
    local copied_ignores=0
    for ignore_file in "${ignore_files[@]}"; do
        if [ -f "$ignore_file" ]; then
            cp "$ignore_file" "$HOME/.agents/$ignore_file"
            copied_ignores=$((copied_ignores + 1))
        fi
    done
    if [ "$copied_ignores" -gt 0 ]; then
        log_success "Ignore files ($copied_ignores) -> ~/.agents/ (templates)"
    fi

    # registry.json e exclusivo do AI Marketplace (AI Marketplace) - nao copiado na instalacao

    # mcps/ -> ~/.agents/mcps/ (Model Context Protocol Servers)
    if [ -d "mcps" ]; then
        backup_dir_if_exists "$HOME/.agents/mcps"
        cp -a mcps/* "$HOME/.agents/mcps/" 2>/dev/null || true
        log_success "MCPs -> ~/.agents/mcps"
    fi

    # devin/playbooks/ -> ~/.agents/playbooks/
    if [ -d "devin/playbooks" ]; then
        backup_dir_if_exists "$HOME/.agents/playbooks"
        cp -a devin/playbooks/* "$HOME/.agents/playbooks/" 2>/dev/null || true
        log_success "Playbooks -> ~/.agents/playbooks"
    fi

    # devin/knowledge_sources/ -> ~/.agents/knowledge/
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.agents/knowledge"
        copy_knowledge_sources "$HOME/.agents/knowledge/"
        log_success "Knowledge Sources -> ~/.agents/knowledge"
    fi

    # Hooks sao instalados por IDE/CLI individualmente (install_hooks_for_ide)
    # Cada IDE tem sua propria estrutura de hooks que deve ser respeitada
}

# ============================================================================
# HARNESS TEMPLATES (estrutura de arquivos do Agent Harness)
# ============================================================================

install_harness_templates() {
    local harness_dir="$HOME/.agents/harness"
    mkdir -p "$harness_dir"

    # CONTEXT.md template
    if [ ! -f "$harness_dir/CONTEXT.md" ]; then
        cat > "$harness_dir/CONTEXT.md" << 'HARNESS_EOF'
# Context Engineering

## Estrategias de Carregamento

| Tipo | Quando | Exemplos |
|------|--------|----------|
| **Always-on** | Sempre carregado | AGENTS.md, hard rules |
| **Pattern-matched** | Por tipo de arquivo | `applyTo: '**/*.cs'` → regras C# |
| **On-demand** | Quando solicitado | Knowledge, design docs |
| **Progressive disclosure** | Codebases grandes | Mapa → headers → conteudo |

## Token Budget

- Reservar 20% para output
- Chunking para arquivos >500 linhas
- Compaction: budget reduction → snip → microcompact → collapse → auto-compact

## Hierarquia de Prioridade

1. Hard Rules (RULES.md)
2. AGENTS.md (SSoT)
3. Skills pattern-matched
4. Knowledge on-demand
5. Historico de sessao
HARNESS_EOF
        log_success "Template -> ~/.agents/harness/CONTEXT.md"
    fi

    # RULES.md template
    if [ ! -f "$harness_dir/RULES.md" ]; then
        cat > "$harness_dir/RULES.md" << 'HARNESS_EOF'
# Guardrails

## Hard Rules (bloqueio imediato)

- Nunca commitar em main/master/develop
- Nunca expor secrets em texto
- Nunca modificar workflows protegidos

## Soft Rules (warning + confirmacao)

- Modificar Dockerfile
- Deploy para producao
- Deletar arquivos

## Permissoes por Ambiente

| Ambiente | Read | Write | Execute | Deploy |
|----------|------|-------|---------|--------|
| dev | Livre | Livre | Sandbox | CI |
| hom | Livre | Gate | Sandbox | CI |
| prod | Livre | Bloqueado | Proibido | Pipeline |

## Tool Permissions

- Read-only por padrao
- Write via gates de aprovacao
- Execute em sandbox com logging
HARNESS_EOF
        log_success "Template -> ~/.agents/harness/RULES.md"
    fi

    # MEMORY.md template
    if [ ! -f "$harness_dir/MEMORY.md" ]; then
        cat > "$harness_dir/MEMORY.md" << 'HARNESS_EOF'
# State Management

> Nunca armazenar PII, secrets ou credenciais.

## Decisoes Tecnicas

| Data | Decisao | Motivo | Alternativas Descartadas |
|------|---------|--------|-------------------------|

## Debitos Tecnicos

| Item | Impacto | Prioridade |
|------|---------|------------|

## Licoes Aprendidas

| Contexto | Erro | Como Evitar |
|----------|------|-------------|

## Politicas de Limpeza

- Memorias de branches deletadas devem ser descartadas
- Fatos desatualizados devem ser removidos
- Verificar just-in-time contra codigo atual antes de usar memoria cross-session
HARNESS_EOF
        log_success "Template -> ~/.agents/harness/MEMORY.md"
    fi

    # TOOLS.md template
    if [ ! -f "$harness_dir/TOOLS.md" ]; then
        cat > "$harness_dir/TOOLS.md" << 'HARNESS_EOF'
# Ferramentas e MCP

## Categorias

| Categoria | Risco | Politica |
|-----------|-------|----------|
| **Read-only** (search, list, grep) | Baixo | Livre |
| **Write** (edit, create, delete) | Medio | Confirmacao |
| **Execute** (run, build, deploy) | Alto | Sandboxed + logged |
| **External** (APIs, webhooks) | Variavel | Rate-limited |

## MCP Servers Disponiveis

- (listar MCP servers configurados)

## APIs Externas

- Headers obrigatorios: (definir por projeto)
- Timeouts: (definir por servico)
- Rate limits: (documentar limites)
HARNESS_EOF
        log_success "Template -> ~/.agents/harness/TOOLS.md"
    fi

    # WORKFLOWS.md template
    if [ ! -f "$harness_dir/WORKFLOWS.md" ]; then
        cat > "$harness_dir/WORKFLOWS.md" << 'HARNESS_EOF'
# Automacao e Workflows

## Verification Loop

```
Agent Output → Lint → Tests → CI → LLM Judge → Human
```

## Workflow Padrao

1. Receber tarefa
2. Carregar AGENTS.md + RULES.md (always-on)
3. Carregar skills e rules pattern-matched
4. Apresentar Execution Plan — aguardar aprovacao
5. Verificar guardrails
6. Executar (sandbox + permissions)
7. Verification loop: lint → test → CI
8. Validar resultado (max 2 iteracoes antes de escalar)
9. Atualizar MEMORY.md

## Trigger Conditions

| Trigger | Workflow |
|---------|----------|
| Issue opened | Analise + plano |
| PR created | Review + validacao |
| CI failed | Diagnostico + fix |
| Schedule | Manutencao + drift |

## Rollback

- Reverter ultimo commit se CI falhar apos 2 tentativas
- Notificar humano antes de rollback em producao
HARNESS_EOF
        log_success "Template -> ~/.agents/harness/WORKFLOWS.md"
    fi

    # README.md template
    if [ ! -f "$harness_dir/README.md" ]; then
        cat > "$harness_dir/README.md" << 'HARNESS_EOF'
# Agent Harness — Documentacao

## O que e

`Agent = Model + Harness`

O harness e o conjunto de arquivos que fornecem contexto, regras e ferramentas
para agentes IA operarem em um repositorio com confiabilidade.

## Estrutura

```
.agents/
├── README.md          # Este arquivo
├── CONTEXT.md         # Como o contexto e entregue ao agente
├── RULES.md           # Guardrails (hard + soft rules)
├── MEMORY.md          # Estado cross-session
├── TOOLS.md           # Ferramentas e MCP
├── WORKFLOWS.md       # Automacao e loops de verificacao
├── skills/            # Uma skill por dominio
│   └── <nome>/SKILL.md
├── rules/             # Uma rule por stack
│   └── <dominio>.instructions.md
└── knowledge/         # Knowledge autocontido
    └── <dominio>.md
```

## Como Skills sao Carregadas

1. **Always-on**: AGENTS.md e RULES.md (carregados em toda sessao)
2. **Pattern-matched**: Rules com `applyTo` ativam por glob de arquivo
3. **On-demand**: Skills e knowledge carregados quando solicitados

## Como Adicionar uma Skill

1. Criar diretorio `.agents/skills/<nome>/`
2. Criar `SKILL.md` com frontmatter YAML (name, description com What/When/Do NOT)
3. Validar: descricao tripartite, sem dependencias implicitas, autocontida

## Compatibilidade por Plataforma

| Plataforma | Le AGENTS.md | Le .agents/ | Skills | Rules |
|------------|-------------|-------------|--------|-------|
| Devin | Sim | Sim | Sim | Via .cursor/rules |
| Claude Code | Sim (CLAUDE.md) | Sim | Sim | Sim |
| Windsurf | Sim | Sim | Sim | Sim |
| VS Code | Sim | Parcial | Sim | Via copilot-instructions |
| Cursor | Sim | Sim | Sim | Sim |
HARNESS_EOF
        log_success "Template -> ~/.agents/harness/README.md"
    fi

    log_success "Harness templates instalados em ~/.agents/harness/"
}

# ============================================================================
# INSTALACAO POR IDE
# ============================================================================

install_vscode() {
    log_info "=== Instalando para VS Code (GitHub Copilot) ==="

    # Skills -> ~/.github/skills
    backup_dir_if_exists "$HOME/.github/skills"
    cp -a skills/* "$HOME/.github/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.github/skills"

    # Rules -> ~/.copilot/instructions + consolidado
    if [ -d "rules" ]; then
        backup_dir_if_exists "$HOME/.copilot/instructions"
        cp -a rules/*.instructions.md "$HOME/.copilot/instructions/" 2>/dev/null || true
        log_success "Rules -> ~/.copilot/instructions"

        mkdir -p "$HOME/.github"
        generate_consolidated_rules "$HOME/.github/copilot-instructions.md" "vscode"
        log_success "Rules consolidadas -> ~/.github/copilot-instructions.md"
    fi

    # Knowledge -> ~/.copilot/knowledge
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.copilot/knowledge"
        copy_knowledge_sources "$HOME/.copilot/knowledge/"
        log_success "Knowledge -> ~/.copilot/knowledge"
    fi

    # Windows: Visual Studio
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]] || [[ "$(uname -s)" == *MINGW* || "$(uname -s)" == *MSYS* ]]; then
        log_info "Detectado ambiente Windows - copiando skills para Visual Studio..."
        local docs_path="${USERPROFILE:-$HOME}/Documents"
        for vs_version in "2022" "2026"; do
            local vs_path="$docs_path/Visual Studio/$vs_version/Skills"
            if [ -d "$(dirname "$vs_path")" ]; then
                backup_dir_if_exists "$vs_path"
                cp -a skills/* "$vs_path/" 2>/dev/null || true
                log_success "Skills -> Visual Studio $vs_version"
            fi
        done
    fi

    # AGENTS_CLI.md -> ~/.github/AGENTS.md (instrucoes genericas do harness)
    if [ -f "AGENTS_CLI.md" ]; then
        mkdir -p "$HOME/.github"
        backup_file_if_exists "$HOME/.github/AGENTS.md"
        cp AGENTS_CLI.md "$HOME/.github/AGENTS.md"
        log_success "AGENTS_CLI.md -> ~/.github/AGENTS.md"
    elif [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.github"
        backup_file_if_exists "$HOME/.github/AGENTS.md"
        cp AGENTS.md "$HOME/.github/AGENTS.md"
        log_success "AGENTS.md -> ~/.github/AGENTS.md"
    fi

    # .aiignore -> ~/.github/.aiignore (ignore file para LLMs)
    if [ -f ".aiignore" ]; then
        cp ".aiignore" "$HOME/.github/.aiignore"
        log_success ".aiignore -> ~/.github/.aiignore"
    fi

    # Hooks -> ~/.github/hooks
    install_hooks_for_ide "vscode" "$HOME/.github/hooks"

    log_success "VS Code (GitHub Copilot) instalado!"
}

install_windsurf() {
    log_info "=== Instalando para Windsurf (Cascade) ==="

    # Skills -> ~/.windsurf/skills
    backup_dir_if_exists "$HOME/.windsurf/skills"
    cp -a skills/* "$HOME/.windsurf/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.windsurf/skills"

    # Rules -> ~/.windsurf/rules + consolidados
    if [ -d "rules" ]; then
        backup_dir_if_exists "$HOME/.windsurf/rules"
        cp -a rules/*.instructions.md "$HOME/.windsurf/rules/" 2>/dev/null || true
        log_success "Rules -> ~/.windsurf/rules"

        generate_consolidated_rules "$HOME/.windsurfrules" "windsurf"
        log_success "Rules consolidadas -> ~/.windsurfrules"

        # Global Rules -> ~/.codeium/windsurf/memories/global_rules.md
        # Ref: https://docs.windsurf.com/windsurf/cascade/memories
        # Escopo global (todos os workspaces), sempre ativo, limite 6.000 chars
        mkdir -p "$HOME/.codeium/windsurf/memories"
        backup_file_if_exists "$HOME/.codeium/windsurf/memories/global_rules.md"
        generate_consolidated_rules "$HOME/.codeium/windsurf/memories/global_rules.md" "windsurf"
        log_success "Global Rules -> ~/.codeium/windsurf/memories/global_rules.md"
        local rules_size
        rules_size=$(wc -c < "$HOME/.codeium/windsurf/memories/global_rules.md" 2>/dev/null || echo 0)
        if [ "$rules_size" -gt 6000 ]; then
            log_warning "global_rules.md excede o limite de 6.000 chars (${rules_size} chars). Windsurf pode truncar o conteudo."
        fi
    fi

    # Knowledge -> ~/.windsurf/knowledge
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.windsurf/knowledge"
        copy_knowledge_sources "$HOME/.windsurf/knowledge/"
        log_success "Knowledge -> ~/.windsurf/knowledge"
    fi

    # AGENTS_CLI.md -> ~/.windsurf/AGENTS.md (instrucoes genericas do harness)
    if [ -f "AGENTS_CLI.md" ]; then
        mkdir -p "$HOME/.windsurf"
        backup_file_if_exists "$HOME/.windsurf/AGENTS.md"
        cp AGENTS_CLI.md "$HOME/.windsurf/AGENTS.md"
        log_success "AGENTS_CLI.md -> ~/.windsurf/AGENTS.md"
    elif [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.windsurf"
        backup_file_if_exists "$HOME/.windsurf/AGENTS.md"
        cp AGENTS.md "$HOME/.windsurf/AGENTS.md"
        log_success "AGENTS.md -> ~/.windsurf/AGENTS.md"
    fi

    # .windsurfignore -> ~/.windsurf/.windsurfignore
    if [ -f ".windsurfignore" ]; then
        cp ".windsurfignore" "$HOME/.windsurf/.windsurfignore"
        log_success ".windsurfignore -> ~/.windsurf/.windsurfignore"
    fi

    # Hooks -> ~/.windsurf/hooks
    install_hooks_for_ide "windsurf" "$HOME/.windsurf/hooks"

    log_success "Windsurf (Cascade) instalado!"
}

install_devin_desktop() {
    log_info "=== Instalando para Devin Desktop (formerly Windsurf) ==="

    # Devin Desktop uses new paths but also reads legacy Windsurf paths
    # Ref: https://docs.devin.ai/desktop/devin-desktop-faq

    # Skills -> ~/.devin/skills (new primary path)
    backup_dir_if_exists "$HOME/.devin/skills"
    cp -a skills/* "$HOME/.devin/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.devin/skills"

    # Rules -> ~/.devin/rules + consolidados
    if [ -d "rules" ]; then
        backup_dir_if_exists "$HOME/.devin/rules"
        cp -a rules/*.instructions.md "$HOME/.devin/rules/" 2>/dev/null || true
        log_success "Rules -> ~/.devin/rules"

        generate_consolidated_rules "$HOME/.devin/rules.md" "devin-desktop"
        log_success "Rules consolidadas -> ~/.devin/rules.md"
    fi

    # Knowledge -> ~/.devin/knowledge
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.devin/knowledge"
        copy_knowledge_sources "$HOME/.devin/knowledge/"
        log_success "Knowledge -> ~/.devin/knowledge"
    fi

    # AGENTS.md -> ~/.devin/AGENTS.md (instrucoes genericas do harness)
    if [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.devin"
        backup_file_if_exists "$HOME/.devin/AGENTS.md"
        cp AGENTS.md "$HOME/.devin/AGENTS.md"
        log_success "AGENTS.md -> ~/.devin/AGENTS.md"
    fi

    # .devinignore -> ~/.devin/.devinignore
    if [ -f ".devinignore" ]; then
        cp ".devinignore" "$HOME/.devin/.devinignore"
        log_success ".devinignore -> ~/.devin/.devinignore"
    fi

    # Also install to legacy Windsurf paths for backward compatibility
    # Devin Desktop reads from legacy paths during transition
    log_info "Instalando tambem em paths legados do Windsurf para compatibilidade..."

    # Skills -> ~/.codeium/windsurf/skills (legacy read)
    backup_dir_if_exists "$HOME/.codeium/windsurf/skills"
    cp -a skills/* "$HOME/.codeium/windsurf/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.codeium/windsurf/skills (legacy)"

    # Knowledge -> ~/.codeium/windsurf/knowledge (legacy read)
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.codeium/windsurf/knowledge"
        copy_knowledge_sources "$HOME/.codeium/windsurf/knowledge/"
        log_success "Knowledge -> ~/.codeium/windsurf/knowledge (legacy)"
    fi

    # Hooks -> ~/.devin/hooks
    install_hooks_for_ide "devin-desktop" "$HOME/.devin/hooks"

    log_success "Devin Desktop instalado!"
}

install_cursor() {
    log_info "=== Instalando para Cursor ==="

    # Skills -> ~/.cursor/skills
    backup_dir_if_exists "$HOME/.cursor/skills"
    cp -a skills/* "$HOME/.cursor/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.cursor/skills"

    # Rules -> ~/.cursor/rules + consolidado
    if [ -d "rules" ]; then
        backup_dir_if_exists "$HOME/.cursor/rules"
        cp -a rules/*.instructions.md "$HOME/.cursor/rules/" 2>/dev/null || true
        log_success "Rules -> ~/.cursor/rules"

        generate_consolidated_rules "$HOME/.cursorrules" "cursor"
        log_success "Rules consolidadas -> ~/.cursorrules"
    fi

    # Knowledge -> ~/.cursor/knowledge
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.cursor/knowledge"
        copy_knowledge_sources "$HOME/.cursor/knowledge/"
        log_success "Knowledge -> ~/.cursor/knowledge"
    fi

    # AGENTS_CLI.md -> ~/.cursor/AGENTS.md (instrucoes genericas do harness)
    if [ -f "AGENTS_CLI.md" ]; then
        mkdir -p "$HOME/.cursor"
        backup_file_if_exists "$HOME/.cursor/AGENTS.md"
        cp AGENTS_CLI.md "$HOME/.cursor/AGENTS.md"
        log_success "AGENTS_CLI.md -> ~/.cursor/AGENTS.md"
    elif [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.cursor"
        backup_file_if_exists "$HOME/.cursor/AGENTS.md"
        cp AGENTS.md "$HOME/.cursor/AGENTS.md"
        log_success "AGENTS.md -> ~/.cursor/AGENTS.md"
    fi

    # .cursorignore -> ~/.cursor/.cursorignore
    if [ -f ".cursorignore" ]; then
        cp ".cursorignore" "$HOME/.cursor/.cursorignore"
        log_success ".cursorignore -> ~/.cursor/.cursorignore"
    fi

    # Hooks -> ~/.cursor/hooks
    install_hooks_for_ide "cursor" "$HOME/.cursor/hooks"

    log_success "Cursor instalado!"
}

install_devin() {
    log_info "=== Instalando para Devin / Devin Review / Devin CLI ==="

    # Devin suporta skills em repo-relative paths que tambem funcionam em ~/.devin/
    # Ref: https://docs.devin.ai/product-guides/skills#supported-skill-file-locations
    # Paths suportados (repo-relative):
    #   .agents/skills/<name>/SKILL.md  (recomendado)
    #   .github/skills/<name>/SKILL.md
    #   .claude/skills/<name>/SKILL.md
    #   .cursor/skills/<name>/SKILL.md
    #   .codex/skills/<name>/SKILL.md
    #   .cognition/skills/<name>/SKILL.md
    #   .windsurf/skills/<name>/SKILL.md

    # Skills -> ~/.agents/skills (path recomendado pela doc oficial)
    # Ja instalado pelo install_base(), verificamos aqui
    if [ -d "$HOME/.agents/skills" ]; then
        log_success "Skills -> ~/.agents/skills (recomendado, instalado via base)"
    fi

    # Skills -> ~/.cognition/skills (path Devin-specific)
    backup_dir_if_exists "$HOME/.cognition/skills"
    cp -a skills/* "$HOME/.cognition/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.cognition/skills"

    # Skills -> ~/.devin/skills (compatibilidade)
    backup_dir_if_exists "$HOME/.devin/skills"
    cp -a skills/* "$HOME/.devin/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.devin/skills"

    # Knowledge -> ~/.devin/knowledge
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.devin/knowledge"
        copy_knowledge_sources "$HOME/.devin/knowledge/"
        log_success "Knowledge -> ~/.devin/knowledge"
    fi

    # Devin CLI (Terminal) - Skills -> ~/.config/devin/skills/
    # Ref: https://cli.devin.ai/docs/extensibility/skills/overview#where-skills-live
    backup_dir_if_exists "$HOME/.config/devin/skills"
    cp -a skills/* "$HOME/.config/devin/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.config/devin/skills (Devin CLI)"

    # Devin CLI - Knowledge -> ~/.config/devin/knowledge/
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.config/devin/knowledge"
        copy_knowledge_sources "$HOME/.config/devin/knowledge/"
        log_success "Knowledge -> ~/.config/devin/knowledge (Devin CLI)"
    fi

    # Rules -> ~/.cursor/rules e ~/.windsurfrules (para Devin Review)
    # Devin CLI le rules de .cursor/rules/*.md, .cursorrules, .windsurf/rules/*.md, AGENTS.md
    # Ref: https://cli.devin.ai/docs/extensibility/rules
    if [ -d "rules" ]; then
        if [ ! -d "$HOME/.cursor/rules" ] || [ -z "$(ls -A "$HOME/.cursor/rules" 2>/dev/null)" ]; then
            backup_dir_if_exists "$HOME/.cursor/rules"
            cp -a rules/*.instructions.md "$HOME/.cursor/rules/" 2>/dev/null || true
            log_success "Rules -> ~/.cursor/rules (para Devin Review / Devin CLI)"
        else
            log_info "~/.cursor/rules ja existe, pulando (instale --cursor para atualizar)"
        fi

        if [ ! -f "$HOME/.windsurfrules" ]; then
            generate_consolidated_rules "$HOME/.windsurfrules" "devin"
            log_success "Rules consolidadas -> ~/.windsurfrules (para Devin Review / Devin CLI)"
        else
            log_info "~/.windsurfrules ja existe, pulando (instale --windsurf para atualizar)"
        fi
    fi

    # AGENTS_CLI.md -> ~/.devin/AGENTS.md (instrucoes genericas do harness)
    if [ -f "AGENTS_CLI.md" ]; then
        mkdir -p "$HOME/.devin"
        backup_file_if_exists "$HOME/.devin/AGENTS.md"
        cp AGENTS_CLI.md "$HOME/.devin/AGENTS.md"
        log_success "AGENTS_CLI.md -> ~/.devin/AGENTS.md"
    elif [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.devin"
        backup_file_if_exists "$HOME/.devin/AGENTS.md"
        cp AGENTS.md "$HOME/.devin/AGENTS.md"
        log_success "AGENTS.md -> ~/.devin/AGENTS.md"
    fi

    # .devinignore -> ~/.devin/.devinignore
    if [ -f ".devinignore" ]; then
        cp ".devinignore" "$HOME/.devin/.devinignore"
        log_success ".devinignore -> ~/.devin/.devinignore"
    fi

    # registry.json e exclusivo do AI Marketplace (AI Marketplace) - nao copiado na instalacao

    # mcps/ -> ~/.devin/mcps/
    if [ -d "mcps" ]; then
        backup_dir_if_exists "$HOME/.devin/mcps"
        cp -a mcps/* "$HOME/.devin/mcps/" 2>/dev/null || true
        log_success "MCPs -> ~/.devin/mcps"
    fi

    # devin/playbooks/ -> ~/.devin/playbooks/
    if [ -d "devin/playbooks" ]; then
        backup_dir_if_exists "$HOME/.devin/playbooks"
        cp -a devin/playbooks/* "$HOME/.devin/playbooks/" 2>/dev/null || true
        log_success "Playbooks -> ~/.devin/playbooks"
    fi

    # devin/knowledge_sources/ -> ~/.devin/knowledge_sources/
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.devin/knowledge_sources"
        copy_knowledge_sources "$HOME/.devin/knowledge_sources/"
        log_success "Knowledge Sources -> ~/.devin/knowledge_sources"
    fi

    # Hooks -> ~/.devin/hooks
    install_hooks_for_ide "devin" "$HOME/.devin/hooks"

    log_success "Devin / Devin Review / Devin CLI instalado!"
}

install_claude() {
    log_info "=== Instalando para Claude Code ==="

    # Garantir que o diretorio base existe
    mkdir -p "$HOME/.claude"

    # Skills -> ~/.claude/skills
    backup_dir_if_exists "$HOME/.claude/skills"
    cp -a skills/* "$HOME/.claude/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.claude/skills"

    # Rules -> ~/.claude/rules
    if [ -d "rules" ]; then
        backup_dir_if_exists "$HOME/.claude/rules"
        cp -a rules/*.instructions.md "$HOME/.claude/rules/" 2>/dev/null || true
        log_success "Rules -> ~/.claude/rules"
    fi

    # Knowledge -> ~/.claude/knowledge
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.claude/knowledge"
        copy_knowledge_sources "$HOME/.claude/knowledge/"
        log_success "Knowledge -> ~/.claude/knowledge"
    fi

    # AGENTS_CLI.md -> ~/.claude/CLAUDE.md (instrucoes globais para Claude Code)
    if [ -f "AGENTS_CLI.md" ]; then
        backup_file_if_exists "$HOME/.claude/CLAUDE.md"
        cp AGENTS_CLI.md "$HOME/.claude/CLAUDE.md"
        log_success "AGENTS_CLI.md -> ~/.claude/CLAUDE.md"
    fi

    # settings.json -> ~/.claude/settings.json (configuracoes e permissoes)
    # Ref: https://docs.anthropic.com/en/docs/claude-code/settings
    # Configura permissoes padrao e preferencias globais do Claude Code
    if [ ! -f "$HOME/.claude/settings.json" ]; then
        cat > "$HOME/.claude/settings.json" << 'SETTINGS_EOF'
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "MultiEdit",
      "Write",
      "Glob",
      "Grep",
      "LS",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(git branch*)",
      "Bash(git checkout -b *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(npm run *)",
      "Bash(npx *)",
      "Bash(dotnet build*)",
      "Bash(dotnet test*)",
      "Bash(mvn *)",
      "Bash(terraform plan*)",
      "Bash(terraform validate*)",
      "Bash(pytest*)",
      "Bash(cat *)",
      "Bash(find *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(wc *)"
    ],
    "deny": [
      "Bash(git merge * main)",
      "Bash(git merge * master)"
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_SKILLS": "true"
  }
}
SETTINGS_EOF
        log_success "settings.json -> ~/.claude/settings.json"
    else
        log_info "~/.claude/settings.json ja existe, mantendo configuracoes do usuario"
    fi

    # commands/ -> ~/.claude/commands (slash commands customizados)
    # Ref: https://docs.anthropic.com/en/docs/claude-code/slash-commands
    mkdir -p "$HOME/.claude/commands"
    
    # Comando /plan — gerar execution plan
    cat > "$HOME/.claude/commands/plan.md" << 'CMD_EOF'
Gere um Execution Plan seguindo o formato obrigatorio:

1. Goal and context
2. Impacted files and modules
3. Implementation strategy
4. Risks and mitigations
5. Validation steps (tests, build, lint)

Analise o contexto atual do projeto e a solicitacao do usuario: $ARGUMENTS
CMD_EOF
    
    # Comando /review — revisar codigo
    cat > "$HOME/.claude/commands/review.md" << 'CMD_EOF'
Revise o codigo seguindo as rules do Agent Skills:

- Verifique aderencia aos padroes em ~/.claude/rules/
- Valide seguranca (OWASP Top 10, secrets, headers)
- Cheque convencoes de nomenclatura
- Verifique cobertura de testes minima
- Identifique riscos e sugira mitigacoes

Contexto: $ARGUMENTS
CMD_EOF

    # Comando /skill — listar ou carregar skills
    cat > "$HOME/.claude/commands/skill.md" << 'CMD_EOF'
Liste as skills disponiveis em ~/.claude/skills/ ou carregue uma skill especifica.

Se nenhum argumento for fornecido, liste todas as skills com nome e descricao.
Se um nome de skill for fornecido, leia e aplique o SKILL.md correspondente.

Argumento: $ARGUMENTS
CMD_EOF

    log_success "Commands -> ~/.claude/commands/"

    # .claudeignore -> ~/.claude/.claudeignore
    if [ -f ".claudeignore" ]; then
        cp ".claudeignore" "$HOME/.claude/.claudeignore"
        log_success ".claudeignore -> ~/.claude/.claudeignore"
    fi

    # Hooks -> ~/.claude/hooks
    install_hooks_for_ide "claude" "$HOME/.claude/hooks"

    log_success "Claude Code instalado!"
}

install_gemini() {
    log_info "=== Instalando para Gemini CLI (Google) ==="

    # Garantir que o diretorio base existe
    mkdir -p "$HOME/.gemini"

    # Skills -> ~/.gemini/skills
    # Gemini CLI descobre skills em ~/.gemini/skills/ (user-level)
    # Cada skill e um diretorio contendo SKILL.md
    # Ref: https://geminicli.com/docs/
    backup_dir_if_exists "$HOME/.gemini/skills"
    cp -a skills/* "$HOME/.gemini/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.gemini/skills"

    # Rules -> ~/.gemini/GEMINI.md (contexto global consolidado)
    # Gemini CLI usa GEMINI.md como arquivo de contexto e instrucoes globais
    # Similar ao .cursorrules e .windsurfrules para outros agentes
    if [ -d "rules" ]; then
        generate_consolidated_rules "$HOME/.gemini/GEMINI.md" "gemini"
        log_success "Rules consolidadas -> ~/.gemini/GEMINI.md"
    fi

    # Knowledge -> ~/.gemini/knowledge
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.gemini/knowledge"
        copy_knowledge_sources "$HOME/.gemini/knowledge/"
        log_success "Knowledge -> ~/.gemini/knowledge"
    fi

    # AGENTS_CLI.md -> ~/.gemini/AGENTS.md (instrucoes genericas do harness)
    if [ -f "AGENTS_CLI.md" ]; then
        mkdir -p "$HOME/.gemini"
        backup_file_if_exists "$HOME/.gemini/AGENTS.md"
        cp AGENTS_CLI.md "$HOME/.gemini/AGENTS.md"
        log_success "AGENTS_CLI.md -> ~/.gemini/AGENTS.md"
    elif [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.gemini"
        backup_file_if_exists "$HOME/.gemini/AGENTS.md"
        cp AGENTS.md "$HOME/.gemini/AGENTS.md"
        log_success "AGENTS.md -> ~/.gemini/AGENTS.md"
    fi

    # .geminiignore -> ~/.gemini/.geminiignore
    if [ -f ".geminiignore" ]; then
        cp ".geminiignore" "$HOME/.gemini/.geminiignore"
        log_success ".geminiignore -> ~/.gemini/.geminiignore"
    fi

    # Hooks -> ~/.gemini/hooks
    install_hooks_for_ide "gemini" "$HOME/.gemini/hooks"

    log_success "Gemini CLI (Google) instalado!"
}

install_antigravity() {
    log_info "=== Instalando para Google Antigravity IDE ==="

    # Garantir que o diretorio base existe
    mkdir -p "$HOME/.gemini"

    # Skills -> ~/.gemini/skills (shared skills directory)
    # Antigravity IDE descobre skills em ~/.gemini/skills/ (shared across all Antigravity tools)
    # Cada skill e um diretorio contendo SKILL.md
    # Ref: https://antigravity.google/docs/ide-overview
    # Nota: Este diretorio e compartilhado com todos os produtos Antigravity (IDE, CLI, SDK)
    if [ ! -d "$HOME/.gemini/skills" ] || [ -z "$(ls -A $HOME/.gemini/skills 2>/dev/null)" ]; then
        backup_dir_if_exists "$HOME/.gemini/skills"
        cp -a skills/* "$HOME/.gemini/skills/" 2>/dev/null || true
        log_success "Skills -> ~/.gemini/skills (global - compartilhado IDE/CLI/SDK)"
    else
        log_info "Skills -> ~/.gemini/skills (ja existe, pulando)"
    fi

    # Skills -> .agent/skills (workspace-specific)
    # Antigravity tambem suporta skills no workspace em .agent/skills/
    # Ref: https://codelabs.developers.google.com/getting-started-with-antigravity-skills
    # Nota: Skills no workspace sao especificas do projeto atual
    if [ ! -d ".agent/skills" ] || [ -z "$(ls -A .agent/skills 2>/dev/null)" ]; then
        backup_dir_if_exists ".agent/skills"
        mkdir -p .agent
        cp -a skills/* ".agent/skills/" 2>/dev/null || true
        log_success "Skills -> .agent/skills (workspace - especifico do projeto)"
    else
        log_info "Skills -> .agent/skills (ja existe, pulando)"
    fi

    # Rules -> ~/.gemini/ANTIGRAVITY.md (contexto global consolidado)
    # Antigravity IDE usa ANTIGRAVITY.md como arquivo de contexto e instrucoes globais
    # Nota: Antigravity tambem e compativel com CLAUDE.md (99% compatibilidade)
    if [ -d "rules" ]; then
        generate_consolidated_rules "$HOME/.gemini/ANTIGRAVITY.md" "antigravity"
        log_success "Rules consolidadas -> ~/.gemini/ANTIGRAVITY.md"
    fi

    # CLAUDE.md -> .agent/CLAUDE.md (workspace-specific, compativel com Antigravity)
    # Antigravity e 99% compativel com Claude Code - pode usar CLAUDE.md nativamente
    if [ -f "CLAUDE.md" ] && [ ! -f ".agent/CLAUDE.md" ]; then
        mkdir -p .agent
        backup_file_if_exists ".agent/CLAUDE.md"
        cp CLAUDE.md ".agent/CLAUDE.md"
        log_success "CLAUDE.md -> .agent/CLAUDE.md (compatibilidade Claude Code)"
    elif [ -f "CLAUDE.md" ]; then
        log_info "CLAUDE.md -> .agent/CLAUDE.md (ja existe, pulando)"
    fi

    # Knowledge -> ~/.gemini/knowledge (compartilhado com Gemini CLI)
    if [ -d "devin/knowledge_sources" ]; then
        if [ ! -d "$HOME/.gemini/knowledge" ] || [ -z "$(ls -A $HOME/.gemini/knowledge 2>/dev/null)" ]; then
            backup_dir_if_exists "$HOME/.gemini/knowledge"
            copy_knowledge_sources "$HOME/.gemini/knowledge/"
            log_success "Knowledge -> ~/.gemini/knowledge"
        else
            log_info "Knowledge -> ~/.gemini/knowledge (ja existe, pulando)"
        fi
    fi

    # Knowledge -> .agent/knowledge (workspace-specific)
    if [ -d "devin/knowledge_sources" ]; then
        if [ ! -d ".agent/knowledge" ] || [ -z "$(ls -A .agent/knowledge 2>/dev/null)" ]; then
            backup_dir_if_exists ".agent/knowledge"
            mkdir -p .agent
            copy_knowledge_sources ".agent/knowledge/"
            log_success "Knowledge -> .agent/knowledge (workspace)"
        else
            log_info "Knowledge -> .agent/knowledge (ja existe, pulando)"
        fi
    fi

    # AGENTS_CLI.md -> ~/.gemini/AGENTS.md (instrucoes genericas do harness)
    # Compartilhado com todos os produtos Antigravity
    if [ ! -f "$HOME/.gemini/AGENTS.md" ]; then
        if [ -f "AGENTS_CLI.md" ]; then
            mkdir -p "$HOME/.gemini"
            backup_file_if_exists "$HOME/.gemini/AGENTS.md"
            cp AGENTS_CLI.md "$HOME/.gemini/AGENTS.md"
            log_success "AGENTS_CLI.md -> ~/.gemini/AGENTS.md"
        elif [ -f "AGENTS.md" ]; then
            mkdir -p "$HOME/.gemini"
            backup_file_if_exists "$HOME/.gemini/AGENTS.md"
            cp AGENTS.md "$HOME/.gemini/AGENTS.md"
            log_success "AGENTS.md -> ~/.gemini/AGENTS.md"
        fi
    else
        log_info "AGENTS.md -> ~/.gemini/AGENTS.md (ja existe, pulando)"
    fi

    # AGENTS.md -> .agent/AGENTS.md (workspace-specific)
    if [ ! -f ".agent/AGENTS.md" ]; then
        if [ -f "AGENTS.md" ]; then
            mkdir -p .agent
            backup_file_if_exists ".agent/AGENTS.md"
            cp AGENTS.md ".agent/AGENTS.md"
            log_success "AGENTS.md -> .agent/AGENTS.md (workspace)"
        fi
    else
        log_info "AGENTS.md -> .agent/AGENTS.md (ja existe, pulando)"
    fi

    # .geminiignore -> ~/.gemini/.geminiignore (compartilhado)
    if [ -f ".geminiignore" ] && [ ! -f "$HOME/.gemini/.geminiignore" ]; then
        cp ".geminiignore" "$HOME/.gemini/.geminiignore"
        log_success ".geminiignore -> ~/.gemini/.geminiignore"
    elif [ -f ".geminiignore" ]; then
        log_info ".geminiignore -> ~/.gemini/.geminiignore (ja existe, pulando)"
    fi

    # Hooks -> ~/.gemini/hooks (compartilhado com Gemini CLI)
    # Nota: Antigravity e Gemini CLI compartilham o mesmo diretorio de hooks
    # Se ja existir hooks do Gemini, mantemos eles (sao compativeis)
    if [ ! -d "$HOME/.gemini/hooks" ] || [ -z "$(ls -A $HOME/.gemini/hooks 2>/dev/null)" ]; then
        install_hooks_for_ide "antigravity" "$HOME/.gemini/hooks"
        log_success "Hooks -> ~/.gemini/hooks"
    else
        log_info "Hooks -> ~/.gemini/hooks (ja existe, pulando - hooks do Gemini CLI sao compatíveis)"
    fi

    log_success "Google Antigravity IDE instalado!"
    log_info "Nota: Antigravity e 99% compativel com Claude Code - skills podem ser compartilhadas"
}

install_agy() {
    log_info "=== Instalando para Google Antigravity CLI (agy) ==="

    # Garantir que o diretorio base existe
    mkdir -p "$HOME/.gemini/antigravity-cli"

    # Skills -> ~/.gemini/antigravity-cli/skills (CLI-specific)
    # Antigravity CLI descobre skills em ~/.gemini/antigravity-cli/skills/ (CLI-specific)
    # Cada skill e um diretorio contendo SKILL.md
    # Ref: https://antigravity.google/docs/cli-overview
    backup_dir_if_exists "$HOME/.gemini/antigravity-cli/skills"
    cp -a skills/* "$HOME/.gemini/antigravity-cli/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.gemini/antigravity-cli/skills (CLI-specific)"

    # Skills -> .agent/skills (workspace-specific, compartilhado com IDE)
    # Antigravity CLI tambem suporta skills no workspace em .agent/skills/
    # Ref: https://codelabs.developers.google.com/getting-started-with-antigravity-skills
    if [ ! -d ".agent/skills" ] || [ -z "$(ls -A .agent/skills 2>/dev/null)" ]; then
        backup_dir_if_exists ".agent/skills"
        mkdir -p .agent
        cp -a skills/* ".agent/skills/" 2>/dev/null || true
        log_success "Skills -> .agent/skills (workspace - compartilhado com IDE)"
    else
        log_info "Skills -> .agent/skills (ja existe, pulando)"
    fi

    # Rules -> ~/.gemini/antigravity-cli/AGY.md (contexto global consolidado)
    # Antigravity CLI usa AGY.md como arquivo de contexto e instrucoes globais
    # Nota: Antigravity tambem e compativel com CLAUDE.md (99% compatibilidade)
    if [ -d "rules" ]; then
        generate_consolidated_rules "$HOME/.gemini/antigravity-cli/AGY.md" "agy"
        log_success "Rules consolidadas -> ~/.gemini/antigravity-cli/AGY.md"
    fi

    # CLAUDE.md -> .agent/CLAUDE.md (workspace-specific, compativel com Antigravity)
    # Antigravity CLI e 99% compativel com Claude Code - pode usar CLAUDE.md nativamente
    if [ -f "CLAUDE.md" ] && [ ! -f ".agent/CLAUDE.md" ]; then
        mkdir -p .agent
        backup_file_if_exists ".agent/CLAUDE.md"
        cp CLAUDE.md ".agent/CLAUDE.md"
        log_success "CLAUDE.md -> .agent/CLAUDE.md (compatibilidade Claude Code)"
    elif [ -f "CLAUDE.md" ]; then
        log_info "CLAUDE.md -> .agent/CLAUDE.md (ja existe, pulando)"
    fi

    # Knowledge -> ~/.gemini/antigravity-cli/knowledge
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.gemini/antigravity-cli/knowledge"
        copy_knowledge_sources "$HOME/.gemini/antigravity-cli/knowledge/"
        log_success "Knowledge -> ~/.gemini/antigravity-cli/knowledge"
    fi

    # Knowledge -> .agent/knowledge (workspace-specific, compartilhado com IDE)
    if [ -d "devin/knowledge_sources" ]; then
        if [ ! -d ".agent/knowledge" ] || [ -z "$(ls -A .agent/knowledge 2>/dev/null)" ]; then
            backup_dir_if_exists ".agent/knowledge"
            mkdir -p .agent
            copy_knowledge_sources ".agent/knowledge/"
            log_success "Knowledge -> .agent/knowledge (workspace)"
        else
            log_info "Knowledge -> .agent/knowledge (ja existe, pulando)"
        fi
    fi

    # AGENTS_CLI.md -> ~/.gemini/antigravity-cli/AGENTS.md (instrucoes genericas do harness)
    if [ -f "AGENTS_CLI.md" ]; then
        mkdir -p "$HOME/.gemini/antigravity-cli"
        backup_file_if_exists "$HOME/.gemini/antigravity-cli/AGENTS.md"
        cp AGENTS_CLI.md "$HOME/.gemini/antigravity-cli/AGENTS.md"
        log_success "AGENTS_CLI.md -> ~/.gemini/antigravity-cli/AGENTS.md"
    elif [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.gemini/antigravity-cli"
        backup_file_if_exists "$HOME/.gemini/antigravity-cli/AGENTS.md"
        cp AGENTS.md "$HOME/.gemini/antigravity-cli/AGENTS.md"
        log_success "AGENTS.md -> ~/.gemini/antigravity-cli/AGENTS.md"
    fi

    # AGENTS.md -> .agent/AGENTS.md (workspace-specific, compartilhado com IDE)
    if [ ! -f ".agent/AGENTS.md" ]; then
        if [ -f "AGENTS.md" ]; then
            mkdir -p .agent
            backup_file_if_exists ".agent/AGENTS.md"
            cp AGENTS.md ".agent/AGENTS.md"
            log_success "AGENTS.md -> .agent/AGENTS.md (workspace)"
        fi
    else
        log_info "AGENTS.md -> .agent/AGENTS.md (ja existe, pulando)"
    fi

    # .geminiignore -> ~/.gemini/antigravity-cli/.geminiignore
    if [ -f ".geminiignore" ]; then
        cp ".geminiignore" "$HOME/.gemini/antigravity-cli/.geminiignore"
        log_success ".geminiignore -> ~/.gemini/antigravity-cli/.geminiignore"
    fi

    # Hooks -> ~/.gemini/antigravity-cli/hooks
    install_hooks_for_ide "agy" "$HOME/.gemini/antigravity-cli/hooks"

    log_success "Google Antigravity CLI (agy) instalado!"
    log_info "Nota: Antigravity CLI e 99% compativel com Claude Code - skills podem ser compartilhadas"
}

install_openclaw() {
    log_info "=== Instalando para OpenClaw ==="

    # Garantir que o diretorio base existe
    mkdir -p "$HOME/.openclaw"

    # Skills -> ~/.openclaw/skills
    backup_dir_if_exists "$HOME/.openclaw/skills"
    cp -a skills/* "$HOME/.openclaw/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.openclaw/skills"

    # Rules -> ~/.openclaw/rules
    if [ -d "rules" ]; then
        backup_dir_if_exists "$HOME/.openclaw/rules"
        cp -a rules/*.instructions.md "$HOME/.openclaw/rules/" 2>/dev/null || true
        log_success "Rules -> ~/.openclaw/rules"
    fi

    # Knowledge -> ~/.openclaw/knowledge
    if [ -d "devin/knowledge_sources" ]; then
        backup_dir_if_exists "$HOME/.openclaw/knowledge"
        copy_knowledge_sources "$HOME/.openclaw/knowledge/"
        log_success "Knowledge -> ~/.openclaw/knowledge"
    fi

    # AGENTS_CLI.md -> ~/.openclaw/AGENTS.md (instrucoes genericas do harness)
    if [ -f "AGENTS_CLI.md" ]; then
        mkdir -p "$HOME/.openclaw"
        backup_file_if_exists "$HOME/.openclaw/AGENTS.md"
        cp AGENTS_CLI.md "$HOME/.openclaw/AGENTS.md"
        log_success "AGENTS_CLI.md -> ~/.openclaw/AGENTS.md"
    elif [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.openclaw"
        backup_file_if_exists "$HOME/.openclaw/AGENTS.md"
        cp AGENTS.md "$HOME/.openclaw/AGENTS.md"
        log_success "AGENTS.md -> ~/.openclaw/AGENTS.md"
    fi

    log_success "OpenClaw instalado!"
}

install_opencode() {
    log_info "=== Instalando para OpenCode ==="

    # Garantir que o diretorio base existe
    mkdir -p "$HOME/.config/opencode"

    # Skills -> ~/.config/opencode/skills (primary path)
    # OpenCode also reads ~/.agents/skills (universal) and ~/.claude/skills (compat)
    backup_dir_if_exists "$HOME/.config/opencode/skills"
    cp -a skills/* "$HOME/.config/opencode/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.config/opencode/skills"

    # Create global opencode.json with $schema if not present
    if [ ! -f "$HOME/.config/opencode/opencode.json" ]; then
        cat > "$HOME/.config/opencode/opencode.json" << 'OPENCODE_CONFIG_EOF'
{
  "$schema": "https://opencode.ai/config.json"
}
OPENCODE_CONFIG_EOF
        log_success "opencode.json -> ~/.config/opencode/opencode.json"
    else
        log_info "~/.config/opencode/opencode.json ja existe, mantendo configuracao do usuario"
    fi

    # AGENTS.md -> ~/.config/opencode/AGENTS.md (global rules for OpenCode)
    # Also append stripped rules/*.instructions.md so OpenCode loads the rules without relying on the instructions field.
    if [ -f "AGENTS_CLI.md" ]; then
        backup_file_if_exists "$HOME/.config/opencode/AGENTS.md"
        cp AGENTS_CLI.md "$HOME/.config/opencode/AGENTS.md"
        log_success "AGENTS_CLI.md -> ~/.config/opencode/AGENTS.md"
    elif [ -f "AGENTS.md" ]; then
        backup_file_if_exists "$HOME/.config/opencode/AGENTS.md"
        cp AGENTS.md "$HOME/.config/opencode/AGENTS.md"
        log_success "AGENTS.md -> ~/.config/opencode/AGENTS.md"
    fi
    if [ -f "$HOME/.config/opencode/AGENTS.md" ] && [ -d "rules" ]; then
        for rule_file in rules/*.instructions.md; do
            [ -f "$rule_file" ] || continue
            {
                echo
                echo "---"
                awk 'BEGIN{fm=0} /^---$/{fm++; if(fm<=2) next} fm>=2||fm==0{print}' "$rule_file" \
                    | sed '/^---$/d' \
                    | cat -s
            } >> "$HOME/.config/opencode/AGENTS.md"
        done
        log_success "Regras consolidadas -> ~/.config/opencode/AGENTS.md"
    fi

    # .opencodeignore -> ~/.config/opencode/.opencodeignore
    if [ -f ".opencodeignore" ]; then
        cp ".opencodeignore" "$HOME/.config/opencode/.opencodeignore"
        log_success ".opencodeignore -> ~/.config/opencode/.opencodeignore"
    fi

    # Workspace-specific config (per-project) -> .opencode/
    if [ ! -d ".opencode/skills" ] || [ -z "$(ls -A .opencode/skills 2>/dev/null)" ]; then
        backup_dir_if_exists ".opencode/skills"
        mkdir -p .opencode
        cp -a skills/* ".opencode/skills/" 2>/dev/null || true
        log_success "Skills -> .opencode/skills (workspace)"
    else
        log_info "Skills -> .opencode/skills (ja existe, pulando)"
    fi

    if [ ! -f ".opencode/AGENTS.md" ]; then
        if [ -f "AGENTS.md" ]; then
            mkdir -p .opencode
            backup_file_if_exists ".opencode/AGENTS.md"
            cp AGENTS.md ".opencode/AGENTS.md"
            log_success "AGENTS.md -> .opencode/AGENTS.md (workspace)"
        fi
    else
        log_info "AGENTS.md -> .opencode/AGENTS.md (ja existe, pulando)"
    fi
    if [ -f ".opencode/AGENTS.md" ] && [ -d "rules" ]; then
        for rule_file in rules/*.instructions.md; do
            [ -f "$rule_file" ] || continue
            {
                echo
                echo "---"
                awk 'BEGIN{fm=0} /^---$/{fm++; if(fm<=2) next} fm>=2||fm==0{print}' "$rule_file" \
                    | sed '/^---$/d' \
                    | cat -s
            } >> ".opencode/AGENTS.md"
        done
        log_success "Regras consolidadas -> .opencode/AGENTS.md (workspace)"
    fi

    # Optional: install OpenCode plugins if present
    if [ -d "hooks/opencode/plugins" ]; then
        mkdir -p "$HOME/.config/opencode/plugins"
        cp -a hooks/opencode/plugins/* "$HOME/.config/opencode/plugins/" 2>/dev/null || true
        log_success "Plugins -> ~/.config/opencode/plugins"
    fi

    log_success "OpenCode instalado!"
    log_info "Nota: OpenCode carrega skills automaticamente via ~/.config/opencode/skills/ e ~/.agents/skills/"
    log_info "Nota: OpenCode nao usa hooks shell; use plugins em ~/.config/opencode/plugins/ se necessario"
}

# ============================================================================
# RTK (Rust Token Killer) — CLI proxy para reducao de tokens
# ============================================================================

install_rtk() {
    log_info "=== Instalando RTK (Rust Token Killer) ==="

    local RTK_VERSION="${RTK_VERSION:-0.42.0}"
    local RTK_INSTALL_DIR="${HOME}/.local/bin"
    local RTK_BINARY="${RTK_INSTALL_DIR}/rtk"
    # Prioridade: --github-token param > GITHUB_TOKEN env var
    local TOKEN="${GITHUB_TOKEN_PARAM:-${GITHUB_TOKEN:-}}"
    local GH_AUTH_HEADER=""

    [ -n "${TOKEN}" ] && GH_AUTH_HEADER="Authorization: Bearer ${TOKEN}"

    # ---- 1. Verificar se ja esta instalado -----------------------------------
    if command -v rtk &>/dev/null; then
        local current_version
        current_version=$(rtk --version 2>/dev/null || echo "unknown")
        log_info "RTK ja instalado: $current_version"
        return 0
    fi

    if [ -f "$RTK_BINARY" ]; then
        local current_version
        current_version=$("$RTK_BINARY" --version 2>/dev/null || echo "unknown")
        log_info "RTK ja instalado: $current_version"
        return 0
    fi

    # ---- 2. Detectar OS, arquitetura e target --------------------------------
    local OS ARCH TARGET ASSET_FILTER EXT="tar.gz"

    case "$(uname -s)" in
        Linux*)          OS="linux";;
        Darwin*)         OS="darwin";;
        MINGW*|MSYS*|CYGWIN*|Windows_NT) OS="windows";;
        *)
            log_warning "WARNING: OS nao suportado para RTK: $(uname -s). Pulando instalacao do RTK."
            return 0
            ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64)  ARCH="x86_64";;
        arm64|aarch64) ARCH="aarch64";;
        *)
            log_warning "WARNING: Arquitetura nao suportada para RTK: $(uname -m). Pulando instalacao do RTK."
            return 0
            ;;
    esac

    case "${OS}-${ARCH}" in
        linux-x86_64)   TARGET="x86_64-unknown-linux-musl";;
        linux-aarch64)  TARGET="aarch64-unknown-linux-gnu";;
        darwin-x86_64)  TARGET="x86_64-apple-darwin";;
        darwin-aarch64) TARGET="aarch64-apple-darwin";;
        windows-x86_64) TARGET="x86_64-pc-windows-msvc"; EXT="zip";;
        windows-aarch64)
            log_warning "WARNING: Windows ARM nao suportado pelo RTK. Pulando instalacao."
            return 0
            ;;
    esac

    ASSET_FILTER="$TARGET"
    log_info "Detectado: $OS $ARCH (target: $TARGET)"

    # ---- 3. Obter asset ID via GitHub API ------------------------------------
    local API_RESP ASSET_ID=""

    API_RESP=$(curl -sL ${GH_AUTH_HEADER:+-H "$GH_AUTH_HEADER"} \
        "https://api.github.com/repos/rtk-ai/rtk/releases/tags/v${RTK_VERSION}" 2>/dev/null || echo "")

    if [ -n "$API_RESP" ] && command -v python3 &>/dev/null; then
        ASSET_ID=$(echo "$API_RESP" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    ids = [str(a['id']) for a in data.get('assets', [])
           if '${ASSET_FILTER}' in a.get('name', '')]
    if ids: print(ids[0])
except: pass
" 2>/dev/null || echo "")
    fi

    # Fallback: asset IDs conhecidos para versoes estáveis
    if [ -z "$ASSET_ID" ]; then
        case "${RTK_VERSION}-${TARGET}" in
            0.42.0-x86_64-unknown-linux-musl) ASSET_ID="419581643";;
        esac
        if [ -n "$ASSET_ID" ]; then
            log_info "Usando asset ID do cache local para v${RTK_VERSION}."
        fi
    fi

    # ---- 4. Download via GitHub API (asset ID) ou URL direta -----------------
    local TEMP_DIR
    TEMP_DIR=$(mktemp -d)
    local DOWNLOAD_OK=false

    # Tentativa 1: GitHub API com asset ID
    if [ -n "$ASSET_ID" ]; then
        log_info "Baixando RTK v${RTK_VERSION} (asset=${ASSET_ID})..."
        if curl -fsSL ${GH_AUTH_HEADER:+-H "$GH_AUTH_HEADER"} \
            -H "Accept: application/octet-stream" \
            "https://api.github.com/repos/rtk-ai/rtk/releases/assets/${ASSET_ID}" \
            -o "${TEMP_DIR}/rtk.${EXT}" 2>/dev/null; then
            DOWNLOAD_OK=true
        fi
    fi

    # Tentativa 2: URL direta do release
    if [ "$DOWNLOAD_OK" = false ]; then
        local DIRECT_URL="https://github.com/rtk-ai/rtk/releases/download/v${RTK_VERSION}/rtk-${TARGET}.${EXT}"
        log_info "Tentando download direto: $DIRECT_URL"
        if curl -fsSL "$DIRECT_URL" -o "${TEMP_DIR}/rtk.${EXT}" 2>/dev/null; then
            DOWNLOAD_OK=true
        fi
    fi

    if [ "$DOWNLOAD_OK" = false ]; then
        log_warning "WARNING: Falha ao baixar RTK (sem rede/proxy ou API rate-limited). Pulando instalacao do RTK."
        rm -rf "$TEMP_DIR"
        return 0
    fi

    # ---- 5. Extrair e instalar -----------------------------------------------
    mkdir -p "$RTK_INSTALL_DIR"

    if [ "$EXT" = "zip" ]; then
        # Windows: extrair .zip
        if command -v unzip &>/dev/null; then
            unzip -qo "${TEMP_DIR}/rtk.${EXT}" -d "$TEMP_DIR" 2>/dev/null
        else
            log_warning "WARNING: unzip nao disponivel. Pulando instalacao do RTK no Windows."
            rm -rf "$TEMP_DIR"
            return 0
        fi
        if [ -f "${TEMP_DIR}/rtk.exe" ]; then
            mv "${TEMP_DIR}/rtk.exe" "${RTK_INSTALL_DIR}/rtk.exe"
            RTK_BINARY="${RTK_INSTALL_DIR}/rtk.exe"
        else
            log_warning "WARNING: Binario rtk.exe nao encontrado no archive. Pulando instalacao do RTK."
            rm -rf "$TEMP_DIR"
            return 0
        fi
    else
        # Linux/macOS: extrair .tar.gz
        if ! tar -xzf "${TEMP_DIR}/rtk.${EXT}" -C "$TEMP_DIR" 2>/dev/null; then
            log_warning "WARNING: Falha ao extrair RTK. Arquivo corrompido? Pulando instalacao do RTK."
            rm -rf "$TEMP_DIR"
            return 0
        fi
        if [ -f "${TEMP_DIR}/rtk" ]; then
            mv "${TEMP_DIR}/rtk" "$RTK_BINARY"
            chmod +x "$RTK_BINARY"
        else
            log_warning "WARNING: Binario rtk nao encontrado no archive. Pulando instalacao do RTK."
            rm -rf "$TEMP_DIR"
            return 0
        fi
    fi

    rm -rf "$TEMP_DIR"

    # ---- 6. Verificar instalacao ---------------------------------------------
    if [ -f "$RTK_BINARY" ]; then
        local installed_version
        installed_version=$("$RTK_BINARY" --version 2>/dev/null || echo "v${RTK_VERSION}")
        log_success "RTK instalado: $installed_version em $RTK_BINARY"

        if ! echo "$PATH" | grep -q "$RTK_INSTALL_DIR"; then
            log_info "Adicione ao PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi
    else
        log_warning "WARNING: Instalacao do RTK falhou silenciosamente. Pulando."
    fi
}

install_hooks_for_ide() {
    local ide="$1"
    local hooks_dest="$2"
    local hooks_src="hooks/${ide}"

    if [ ! -d "$hooks_src" ]; then
        return 0
    fi

    mkdir -p "$hooks_dest"

    # Copiar todos os arquivos do subdiretorio da IDE
    cp -a "$hooks_src"/* "$hooks_dest/" 2>/dev/null || true

    # Copiar session-start-base.sh para dentro do hooks dir da IDE
    if [ -f "hooks/session-start-base.sh" ]; then
        cp "hooks/session-start-base.sh" "$hooks_dest/session-start-base.sh"
    fi

    # Garantir que scripts sao executaveis
    chmod +x "$hooks_dest"/session-start 2>/dev/null || true
    chmod +x "$hooks_dest"/*.sh 2>/dev/null || true

    log_success "Hooks -> $hooks_dest ($ide)"
}

# ============================================================================
# VERIFICACAO POS-INSTALACAO
# ============================================================================

verify_installation() {
    echo
    log_info "=== Verificacao da instalacao ==="

    if [ -d "$HOME/.agents/skills" ]; then
        local count
        count=$(find "$HOME/.agents/skills" -maxdepth 1 -type d | wc -l)
        count=$((count - 1))
        log_success "Base: ~/.agents/skills ($count skills)"
    fi
    [ -f "$HOME/.agents/AGENTS_CLI.md" ] && log_success "Base: ~/.agents/AGENTS_CLI.md (harness instructions)"
    [ -d "$HOME/.agents/harness" ] && log_success "Base: ~/.agents/harness/ (harness templates)"

    [ -d "$HOME/.agents/mcps" ] && log_success "Base: ~/.agents/mcps"
    [ -d "$HOME/.agents/playbooks" ] && log_success "Base: ~/.agents/playbooks"
    [ -d "$HOME/.agents/knowledge" ] && log_success "Base: ~/.agents/knowledge"

    if [ "$INSTALL_VSCODE" = true ]; then
        echo
        log_info "VS Code (GitHub Copilot):"
        [ -d "$HOME/.github/skills" ] && log_success "  Skills: ~/.github/skills"
        [ -d "$HOME/.copilot/instructions" ] && log_success "  Rules: ~/.copilot/instructions"
        [ -f "$HOME/.github/copilot-instructions.md" ] && log_success "  Rules consolidadas: ~/.github/copilot-instructions.md"
        [ -d "$HOME/.copilot/knowledge" ] && log_success "  Knowledge: ~/.copilot/knowledge"
        [ -f "$HOME/.github/AGENTS.md" ] && log_success "  AGENTS.md: ~/.github/AGENTS.md"
    fi

    if [ "$INSTALL_WINDSURF" = true ]; then
        echo
        log_info "Windsurf (Cascade):"
        [ -d "$HOME/.windsurf/skills" ] && log_success "  Skills: ~/.windsurf/skills"
        [ -d "$HOME/.windsurf/rules" ] && log_success "  Rules: ~/.windsurf/rules"
        [ -f "$HOME/.windsurfrules" ] && log_success "  Rules consolidadas: ~/.windsurfrules"
        [ -f "$HOME/.codeium/windsurf/memories/global_rules.md" ] && log_success "  Global Rules: ~/.codeium/windsurf/memories/global_rules.md"
        [ -d "$HOME/.windsurf/knowledge" ] && log_success "  Knowledge: ~/.windsurf/knowledge"
        [ -f "$HOME/.windsurf/AGENTS.md" ] && log_success "  AGENTS.md: ~/.windsurf/AGENTS.md"
    fi

    if [ "$INSTALL_DEVIN_DESKTOP" = true ]; then
        echo
        log_info "Devin Desktop (formerly Windsurf):"
        [ -d "$HOME/.devin/skills" ] && log_success "  Skills: ~/.devin/skills"
        [ -d "$HOME/.devin/rules" ] && log_success "  Rules: ~/.devin/rules"
        [ -f "$HOME/.devin/rules.md" ] && log_success "  Rules consolidadas: ~/.devin/rules.md"
        [ -d "$HOME/.devin/knowledge" ] && log_success "  Knowledge: ~/.devin/knowledge"
        [ -f "$HOME/.devin/AGENTS.md" ] && log_success "  AGENTS.md: ~/.devin/AGENTS.md"
        [ -d "$HOME/.codeium/windsurf/skills" ] && log_success "  Skills (legacy): ~/.codeium/windsurf/skills"
        [ -d "$HOME/.codeium/windsurf/knowledge" ] && log_success "  Knowledge (legacy): ~/.codeium/windsurf/knowledge"
    fi

    if [ "$INSTALL_CURSOR" = true ]; then
        echo
        log_info "Cursor:"
        [ -d "$HOME/.cursor/skills" ] && log_success "  Skills: ~/.cursor/skills"
        [ -d "$HOME/.cursor/rules" ] && log_success "  Rules: ~/.cursor/rules"
        [ -f "$HOME/.cursorrules" ] && log_success "  Rules consolidadas: ~/.cursorrules"
        [ -d "$HOME/.cursor/knowledge" ] && log_success "  Knowledge: ~/.cursor/knowledge"
        [ -f "$HOME/.cursor/AGENTS.md" ] && log_success "  AGENTS.md: ~/.cursor/AGENTS.md"
    fi

    if [ "$INSTALL_DEVIN" = true ]; then
        echo
        log_info "Devin / Devin Review / Devin CLI:"
        [ -d "$HOME/.agents/skills" ] && log_success "  Skills (recomendado): ~/.agents/skills"
        [ -d "$HOME/.cognition/skills" ] && log_success "  Skills (Devin-specific): ~/.cognition/skills"
        [ -d "$HOME/.devin/skills" ] && log_success "  Skills (compatibilidade): ~/.devin/skills"
        [ -d "$HOME/.devin/knowledge" ] && log_success "  Knowledge: ~/.devin/knowledge"

        [ -d "$HOME/.devin/mcps" ] && log_success "  MCPs: ~/.devin/mcps"
        [ -d "$HOME/.devin/playbooks" ] && log_success "  Playbooks: ~/.devin/playbooks"
        [ -d "$HOME/.devin/knowledge_sources" ] && log_success "  Knowledge Sources: ~/.devin/knowledge_sources"
        [ -d "$HOME/.config/devin/skills" ] && log_success "  Skills (Devin CLI): ~/.config/devin/skills"
        [ -d "$HOME/.config/devin/knowledge" ] && log_success "  Knowledge (Devin CLI): ~/.config/devin/knowledge"
        [ -d "$HOME/.cursor/rules" ] && log_success "  Rules (Devin Review/CLI): ~/.cursor/rules"
        [ -f "$HOME/.windsurfrules" ] && log_success "  Rules (Devin Review/CLI): ~/.windsurfrules"
        [ -f "$HOME/.devin/AGENTS.md" ] && log_success "  AGENTS.md: ~/.devin/AGENTS.md"
    fi

    if [ "$INSTALL_CLAUDE" = true ]; then
        echo
        log_info "Claude Code:"
        [ -d "$HOME/.claude/skills" ] && log_success "  Skills: ~/.claude/skills"
        [ -d "$HOME/.claude/rules" ] && log_success "  Rules: ~/.claude/rules"
        [ -d "$HOME/.claude/knowledge" ] && log_success "  Knowledge: ~/.claude/knowledge"
        [ -f "$HOME/.claude/CLAUDE.md" ] && log_success "  CLAUDE.md: ~/.claude/CLAUDE.md"
        [ -f "$HOME/.claude/settings.json" ] && log_success "  Settings: ~/.claude/settings.json"
        [ -d "$HOME/.claude/commands" ] && log_success "  Commands: ~/.claude/commands/"
        [ -f "$HOME/.claude/AGENTS.md" ] && log_success "  AGENTS.md: ~/.claude/AGENTS.md"
    fi

    if [ "$INSTALL_GEMINI" = true ]; then
        echo
        log_info "Gemini CLI (Google):"
        [ -d "$HOME/.gemini/skills" ] && log_success "  Skills: ~/.gemini/skills"
        [ -f "$HOME/.gemini/GEMINI.md" ] && log_success "  Rules consolidadas: ~/.gemini/GEMINI.md"
        [ -d "$HOME/.gemini/knowledge" ] && log_success "  Knowledge: ~/.gemini/knowledge"
        [ -f "$HOME/.gemini/AGENTS.md" ] && log_success "  AGENTS.md: ~/.gemini/AGENTS.md"
    fi

    if [ "$INSTALL_ANTIGRAVITY" = true ]; then
        echo
        log_info "Google Antigravity IDE:"
        [ -d "$HOME/.gemini/skills" ] && log_success "  Skills (global): ~/.gemini/skills"
        [ -d ".agent/skills" ] && log_success "  Skills (workspace): .agent/skills"
        [ -f "$HOME/.gemini/ANTIGRAVITY.md" ] && log_success "  Rules consolidadas: ~/.gemini/ANTIGRAVITY.md"
        [ -f ".agent/CLAUDE.md" ] && log_success "  CLAUDE.md (workspace): .agent/CLAUDE.md"
        [ -d "$HOME/.gemini/knowledge" ] && log_success "  Knowledge (global): ~/.gemini/knowledge"
        [ -d ".agent/knowledge" ] && log_success "  Knowledge (workspace): .agent/knowledge"
        [ -f "$HOME/.gemini/AGENTS.md" ] && log_success "  AGENTS.md (global): ~/.gemini/AGENTS.md"
        [ -f ".agent/AGENTS.md" ] && log_success "  AGENTS.md (workspace): .agent/AGENTS.md"
    fi

    if [ "$INSTALL_AGY" = true ]; then
        echo
        log_info "Google Antigravity CLI (agy):"
        [ -d "$HOME/.gemini/antigravity-cli/skills" ] && log_success "  Skills (CLI-specific): ~/.gemini/antigravity-cli/skills"
        [ -d ".agent/skills" ] && log_success "  Skills (workspace): .agent/skills"
        [ -f "$HOME/.gemini/antigravity-cli/AGY.md" ] && log_success "  Rules consolidadas: ~/.gemini/antigravity-cli/AGY.md"
        [ -f ".agent/CLAUDE.md" ] && log_success "  CLAUDE.md (workspace): .agent/CLAUDE.md"
        [ -d "$HOME/.gemini/antigravity-cli/knowledge" ] && log_success "  Knowledge (CLI-specific): ~/.gemini/antigravity-cli/knowledge"
        [ -d ".agent/knowledge" ] && log_success "  Knowledge (workspace): .agent/knowledge"
        [ -f "$HOME/.gemini/antigravity-cli/AGENTS.md" ] && log_success "  AGENTS.md (CLI-specific): ~/.gemini/antigravity-cli/AGENTS.md"
        [ -f ".agent/AGENTS.md" ] && log_success "  AGENTS.md (workspace): .agent/AGENTS.md"
    fi

    if [ "$INSTALL_OPENCLAW" = true ]; then
        echo
        log_info "OpenClaw:"
        [ -d "$HOME/.openclaw/skills" ] && log_success "  Skills: ~/.openclaw/skills"
        [ -d "$HOME/.openclaw/rules" ] && log_success "  Rules: ~/.openclaw/rules"
        [ -d "$HOME/.openclaw/knowledge" ] && log_success "  Knowledge: ~/.openclaw/knowledge"
        [ -f "$HOME/.openclaw/AGENTS.md" ] && log_success "  AGENTS.md: ~/.openclaw/AGENTS.md"
    fi

    if [ "$INSTALL_OPENCODE" = true ]; then
        echo
        log_info "OpenCode:"
        [ -d "$HOME/.config/opencode/skills" ] && log_success "  Skills: ~/.config/opencode/skills"
        [ -f "$HOME/.config/opencode/AGENTS.md" ] && log_success "  AGENTS.md: ~/.config/opencode/AGENTS.md"
        [ -f "$HOME/.config/opencode/opencode.json" ] && log_success "  opencode.json: ~/.config/opencode/opencode.json"
        [ -d ".opencode/skills" ] && log_success "  Skills (workspace): .opencode/skills"
        [ -f ".opencode/AGENTS.md" ] && log_success "  AGENTS.md (workspace): .opencode/AGENTS.md"
    fi

    echo
    log_info "Skills disponiveis:"
    find "$HOME/.agents/skills" -maxdepth 1 -type d -not -path "$HOME/.agents/skills" | \
        sed 's|.*/||' | \
        sort | \
        while read -r skill; do
        echo "  - $skill"
    done
}

# ============================================================================
# INSTRUCOES POS-INSTALACAO
# ============================================================================

show_post_install() {
    echo
    echo "Desinstalacao:"
    echo "  rm -rf ~/.agents"

    if [ "$INSTALL_VSCODE" = true ]; then
        echo "  rm -rf ~/.github/skills ~/.copilot/instructions ~/.copilot/knowledge"
        echo "  rm -f ~/.github/copilot-instructions.md ~/.github/AGENTS.md"
    fi
    if [ "$INSTALL_WINDSURF" = true ]; then
        echo "  rm -rf ~/.windsurf/skills ~/.windsurf/rules ~/.windsurf/knowledge"
        echo "  rm -f ~/.windsurfrules ~/.windsurf/AGENTS.md"
        echo "  rm -f ~/.codeium/windsurf/memories/global_rules.md"
    fi
    if [ "$INSTALL_DEVIN_DESKTOP" = true ]; then
        echo "  rm -rf ~/.devin/skills ~/.devin/rules ~/.devin/knowledge"
        echo "  rm -f ~/.devin/rules.md ~/.devin/AGENTS.md"
        echo "  rm -rf ~/.codeium/windsurf/skills ~/.codeium/windsurf/knowledge"
    fi
    if [ "$INSTALL_CURSOR" = true ]; then
        echo "  rm -rf ~/.cursor/skills ~/.cursor/rules ~/.cursor/knowledge"
        echo "  rm -f ~/.cursorrules ~/.cursor/AGENTS.md"
    fi
    if [ "$INSTALL_DEVIN" = true ]; then
        echo "  rm -rf ~/.cognition/skills"
        echo "  rm -rf ~/.devin/skills ~/.devin/knowledge"
        echo "  rm -f ~/.devin/AGENTS.md"
        echo "  rm -rf ~/.devin/mcps ~/.devin/playbooks ~/.devin/knowledge_sources"
        echo "  rm -rf ~/.config/devin/skills ~/.config/devin/knowledge"
    fi
    if [ "$INSTALL_CLAUDE" = true ]; then
        echo "  rm -rf ~/.claude/skills ~/.claude/rules ~/.claude/knowledge ~/.claude/commands"
        echo "  rm -f ~/.claude/AGENTS.md ~/.claude/CLAUDE.md ~/.claude/settings.json"
    fi
    if [ "$INSTALL_GEMINI" = true ]; then
        echo "  rm -rf ~/.gemini/skills ~/.gemini/knowledge"
        echo "  rm -f ~/.gemini/GEMINI.md ~/.gemini/AGENTS.md"
    fi
    if [ "$INSTALL_ANTIGRAVITY" = true ]; then
        echo "  rm -rf ~/.gemini/skills ~/.gemini/knowledge"
        echo "  rm -f ~/.gemini/ANTIGRAVITY.md ~/.gemini/AGENTS.md"
        echo "  rm -rf .agent/skills .agent/knowledge"
        echo "  rm -f .agent/CLAUDE.md .agent/AGENTS.md"
    fi
    if [ "$INSTALL_AGY" = true ]; then
        echo "  rm -rf ~/.gemini/antigravity-cli/skills ~/.gemini/antigravity-cli/knowledge"
        echo "  rm -f ~/.gemini/antigravity-cli/AGY.md ~/.gemini/antigravity-cli/AGENTS.md"
        echo "  rm -rf .agent/skills .agent/knowledge"
        echo "  rm -f .agent/CLAUDE.md .agent/AGENTS.md"
    fi
    if [ "$INSTALL_OPENCLAW" = true ]; then
        echo "  rm -rf ~/.openclaw/skills ~/.openclaw/rules ~/.openclaw/knowledge"
        echo "  rm -f ~/.openclaw/AGENTS.md"
    fi
    if [ "$INSTALL_OPENCODE" = true ]; then
        echo "  rm -rf ~/.config/opencode/skills"
        echo "  rm -f ~/.config/opencode/AGENTS.md ~/.config/opencode/opencode.json"
        echo "  rm -rf .opencode/skills"
        echo "  rm -f .opencode/AGENTS.md"
    fi

    echo
    echo "  Para limpar backups: ./rm-backup.sh"
    echo
}

# ============================================================================
# PREVIEW (dry-run)
# ============================================================================

show_preview() {
    echo "========================================"
    echo "  Agent Skills - Preview (dry-run)"
    echo "========================================"
    echo

    local ides_selecionadas=""
    [ "$INSTALL_VSCODE" = true ] && ides_selecionadas="${ides_selecionadas} VS-Code"
    [ "$INSTALL_WINDSURF" = true ] && ides_selecionadas="${ides_selecionadas} Windsurf"
    [ "$INSTALL_DEVIN_DESKTOP" = true ] && ides_selecionadas="${ides_selecionadas} Devin-Desktop"
    [ "$INSTALL_CURSOR" = true ] && ides_selecionadas="${ides_selecionadas} Cursor"
    [ "$INSTALL_DEVIN" = true ] && ides_selecionadas="${ides_selecionadas} Devin"
    [ "$INSTALL_CLAUDE" = true ] && ides_selecionadas="${ides_selecionadas} Claude"
    [ "$INSTALL_GEMINI" = true ] && ides_selecionadas="${ides_selecionadas} Gemini"
    [ "$INSTALL_ANTIGRAVITY" = true ] && ides_selecionadas="${ides_selecionadas} Antigravity"
    [ "$INSTALL_AGY" = true ] && ides_selecionadas="${ides_selecionadas} AGY"
    [ "$INSTALL_OPENCLAW" = true ] && ides_selecionadas="${ides_selecionadas} OpenClaw"
    [ "$INSTALL_OPENCODE" = true ] && ides_selecionadas="${ides_selecionadas} OpenCode"
    log_info "IDEs/CLIs selecionadas:${ides_selecionadas}"

    echo
    log_info "Acoes que seriam executadas:"
    echo "  - Copiar skills para ~/.agents/skills/"
    [ "$INSTALL_VSCODE" = true ] && echo "  - Copiar skills para ~/.github/skills/ e ~/.copilot/instructions/"
    [ "$INSTALL_WINDSURF" = true ] && echo "  - Copiar skills para ~/.windsurf/skills/ e ~/.windsurf/rules/"
    [ "$INSTALL_DEVIN_DESKTOP" = true ] && echo "  - Copiar skills para ~/.devin/skills/ e ~/.devin/rules/"
    [ "$INSTALL_CURSOR" = true ] && echo "  - Copiar skills para ~/.cursor/skills/ e ~/.cursor/rules/"
    [ "$INSTALL_DEVIN" = true ] && echo "  - Copiar skills para ~/.devin/skills/ e ~/.config/devin/skills/"
    [ "$INSTALL_CLAUDE" = true ] && echo "  - Copiar skills para ~/.claude/skills/ e ~/.claude/rules/"
    [ "$INSTALL_GEMINI" = true ] && echo "  - Copiar skills para ~/.gemini/skills/ e regras para ~/.gemini/GEMINI.md"
    [ "$INSTALL_ANTIGRAVITY" = true ] && echo "  - Copiar skills para ~/.gemini/skills/ e .agent/skills/"
    [ "$INSTALL_AGY" = true ] && echo "  - Copiar skills para ~/.gemini/antigravity-cli/skills/"
    [ "$INSTALL_OPENCLAW" = true ] && echo "  - Copiar skills para ~/.openclaw/skills/ e ~/.openclaw/rules/"
    [ "$INSTALL_OPENCODE" = true ] && echo "  - Copiar skills para ~/.config/opencode/skills/ (e ~/.agents/skills/ como universal)"
    [ "$INSTALL_OPENCODE" = true ] && echo "  - Criar/atualizar ~/.config/opencode/opencode.json e ~/.config/opencode/AGENTS.md"
    [ "$INSTALL_OPENCODE" = true ] && echo "  - Criar .opencode/skills/ e .opencode/AGENTS.md (workspace)"
    echo "  - Instalar/atualizar RTK (binario global)"
    echo
    log_info "Nenhuma alteracao foi feita."
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo "========================================"
    echo "  Agent Skills - Instalador"
    echo "========================================"
    echo

    local ides_selecionadas=""
    [ "$INSTALL_VSCODE" = true ] && ides_selecionadas="${ides_selecionadas} VS-Code"
    [ "$INSTALL_WINDSURF" = true ] && ides_selecionadas="${ides_selecionadas} Windsurf"
    [ "$INSTALL_DEVIN_DESKTOP" = true ] && ides_selecionadas="${ides_selecionadas} Devin-Desktop"
    [ "$INSTALL_CURSOR" = true ] && ides_selecionadas="${ides_selecionadas} Cursor"
    [ "$INSTALL_DEVIN" = true ] && ides_selecionadas="${ides_selecionadas} Devin"
    [ "$INSTALL_CLAUDE" = true ] && ides_selecionadas="${ides_selecionadas} Claude"
    [ "$INSTALL_GEMINI" = true ] && ides_selecionadas="${ides_selecionadas} Gemini"
    [ "$INSTALL_ANTIGRAVITY" = true ] && ides_selecionadas="${ides_selecionadas} Antigravity"
    [ "$INSTALL_AGY" = true ] && ides_selecionadas="${ides_selecionadas} AGY"
    [ "$INSTALL_OPENCLAW" = true ] && ides_selecionadas="${ides_selecionadas} OpenClaw"
    [ "$INSTALL_OPENCODE" = true ] && ides_selecionadas="${ides_selecionadas} OpenCode"
    log_info "IDEs/CLIs selecionadas:${ides_selecionadas}"
    echo

    check_directory

    if [ "$DRY_RUN" = true ]; then
        show_preview
        exit 0
    fi

    install_base
    install_rtk

    [ "$INSTALL_VSCODE" = true ] && install_vscode
    [ "$INSTALL_WINDSURF" = true ] && install_windsurf
    [ "$INSTALL_DEVIN_DESKTOP" = true ] && install_devin_desktop
    [ "$INSTALL_CURSOR" = true ] && install_cursor
    [ "$INSTALL_DEVIN" = true ] && install_devin
    [ "$INSTALL_CLAUDE" = true ] && install_claude
    [ "$INSTALL_GEMINI" = true ] && install_gemini
    [ "$INSTALL_ANTIGRAVITY" = true ] && install_antigravity
    [ "$INSTALL_AGY" = true ] && install_agy
    [ "$INSTALL_OPENCLAW" = true ] && install_openclaw
    [ "$INSTALL_OPENCODE" = true ] && install_opencode

    verify_installation
    show_post_install

    log_success "Instalacao concluida com sucesso!"
}

parse_args "$@"
main
