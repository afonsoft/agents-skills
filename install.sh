#!/bin/bash

# Script de instalacao das skills, rules e knowledge do agents-skills
# Suporta instalacao seletiva por IDE ou instalacao completa
#
# Uso:
#   ./install.sh --all, -a        Instala para todas as IDEs/CLIs
#   ./install.sh --vscode, -v     Instala para VS Code (GitHub Copilot)
#   ./install.sh --windsurf, -w   Instala para Windsurf (Cascade)
#   ./install.sh --cursor, -c     Instala para Cursor
#   ./install.sh --devin, -d      Instala para Devin / Devin Review / Devin CLI
#   ./install.sh --claude         Instala para Claude Code
#   ./install.sh --gemini, -g     Instala para Gemini CLI (Google)
#   ./install.sh --help, -h       Exibe ajuda
#
# Multiplas IDEs/CLIs podem ser combinadas:
#   ./install.sh --vscode --cursor --devin --gemini

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
INSTALL_CURSOR=false
INSTALL_DEVIN=false
INSTALL_CLAUDE=false
INSTALL_GEMINI=false
INSTALL_OPENCLAW=false

# ============================================================================
# HELP
# ============================================================================

show_help() {
    echo
    echo -e "${CYAN}agents-skills - Instalador${NC}"
    echo
    echo -e "${YELLOW}Uso:${NC}"
    echo "  ./install.sh [opcoes]"
    echo
    echo -e "${YELLOW}Opcoes de IDE:${NC}"
    echo "  --vscode,   -v          Instala para VS Code (GitHub Copilot)"
    echo "  --windsurf, -w          Instala para Windsurf (Cascade)"
    echo "  --cursor,   -c          Instala para Cursor"
    echo "  --devin,    -d          Instala para Devin / Devin Review / Devin CLI"
    echo "  --claude                Instala para Claude Code"
    echo "  --gemini,   -g          Instala para Gemini CLI (Google)"
    echo "  --openclaw, -o          Instala para OpenClaw"
    echo "  --all,      -a          Instala para todas as IDEs/CLIs"
    echo
    echo -e "${YELLOW}Outras opcoes:${NC}"
    echo "  --help, -h              Exibe esta mensagem de ajuda"
    echo
    echo -e "${YELLOW}Exemplos:${NC}"
    echo "  ./install.sh --all                    # Todas as IDEs"
    echo "  ./install.sh --vscode                 # Apenas VS Code"
    echo "  ./install.sh --devin --claude         # Devin + Claude"
    echo "  ./install.sh --windsurf --vscode      # Windsurf + VS Code"
    echo "  ./install.sh --gemini                 # Apenas Gemini CLI"
    echo "  ./install.sh -a                       # Todas as IDEs/CLIs (atalho)"
    echo "  ./install.sh -d -c -w                 # Devin + Claude + Windsurf (atalho)"
    echo "  ./install.sh -c                       # Apenas Claude Code (atalho)"
    echo
    echo -e "${YELLOW}O que sera instalado:${NC}"
    echo
    echo "  IDE/CLI      Skills              Rules                    Knowledge"
    echo "  ------------ ------------------- ------------------------ -------------------"
    echo "  VS Code      ~/.github/skills    ~/.copilot/instructions  ~/.copilot/knowledge"
    echo "                                   ~/.github/copilot-instructions.md (consolidado)"
    echo "  Windsurf     ~/.windsurf/skills  ~/.windsurf/rules        ~/.windsurf/knowledge"
    echo "                                   ~/.windsurfrules (consolidado)"
    echo "                                   ~/.codeium/windsurf/memories/global_rules.md (global, sempre ativo)"
    echo "  Cursor       ~/.cursor/skills    ~/.cursor/rules          ~/.cursor/knowledge"
    echo "                                   ~/.cursorrules (consolidado)"
    echo "  Devin        ~/.agents/skills     ~/.devin/skills         ~/.devin/knowledge"
    echo "               + ~/.cognition/skills  (legacy)"
    echo "               + ~/.config/cognition/skills  (Devin CLI)"
    echo "               + ~/.config/cognition/knowledge  (Devin CLI)"
    echo "               + AGENTS.md -> ~/.devin/AGENTS.md"
    echo "  Claude       ~/.claude/skills    ~/.claude/rules          ~/.claude/knowledge"
    echo "                                   ~/.claude/CLAUDE.md (instrucoes globais)"
    echo "                                   ~/.claude/settings.json (permissoes)"
    echo "                                   ~/.claude/commands/ (slash commands)"
    echo "  Gemini CLI   ~/.gemini/skills    ~/.gemini/GEMINI.md      ~/.gemini/knowledge"
    echo "  OpenClaw     ~/.openclaw/skills  ~/.openclaw/workspace/memory/MEMORY.md"
    echo
    echo "  Base: ~/.agents/skills (sempre instalado)"
    echo
    echo -e "${YELLOW}Documentacao:${NC}"
    echo "  VS Code:   https://code.visualstudio.com/docs/copilot/customization/custom-instructions"
    echo "  Windsurf:  https://docs.windsurf.com/windsurf/cascade/agents-md"
    echo "  Cursor:    https://docs.cursor.com/context/rules"
    echo "  Devin:     https://docs.devin.ai/work-with-devin/devin-review"
    echo "  Devin CLI: https://cli.devin.ai/docs/extensibility/skills/overview"
    echo "  Claude:    https://docs.anthropic.com/en/docs/claude-code"
    echo "             https://docs.anthropic.com/en/docs/claude-code/slash-commands"
    echo "  Gemini:    https://geminicli.com/docs/"
    echo "  OpenClaw:  https://docs.openclaw.ai/tools/skills"
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
                INSTALL_CURSOR=true
                INSTALL_DEVIN=true
                INSTALL_CLAUDE=true
                INSTALL_GEMINI=true
                INSTALL_OPENCLAW=true
                ;;
            --vscode|-v)
                INSTALL_VSCODE=true
                ;;
            --windsurf|-w)
                INSTALL_WINDSURF=true
                ;;
            --cursor|-c)
                INSTALL_CURSOR=true
                ;;
            --devin|-d)
                INSTALL_DEVIN=true
                ;;
            --claude)
                INSTALL_CLAUDE=true
                ;;
            --gemini|-g)
                INSTALL_GEMINI=true
                ;;
            --openclaw|-o)
                INSTALL_OPENCLAW=true
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
    backup_file_if_exists "$output_file"
    echo "<!-- Auto-generated from agents-skills rules -->" > "$output_file"
    echo "" >> "$output_file"
    for rule_file in rules/*.instructions.md; do
        if [ -f "$rule_file" ]; then
            cat "$rule_file" >> "$output_file"
            echo "" >> "$output_file"
            echo "---" >> "$output_file"
            echo "" >> "$output_file"
        fi
    done
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
    if [ ! -d "knowledge" ]; then
        log_warning "Pasta knowledge nao encontrada no diretorio atual!"
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
        generate_consolidated_rules "$HOME/.github/copilot-instructions.md"
        log_success "Rules consolidadas -> ~/.github/copilot-instructions.md"
    fi

    # Knowledge -> ~/.copilot/knowledge
    if [ -d "knowledge" ]; then
        backup_dir_if_exists "$HOME/.copilot/knowledge"
        cp -a knowledge/* "$HOME/.copilot/knowledge/" 2>/dev/null || true
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

    # AGENTS.md -> ~/.github/AGENTS.md
    if [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.github"
        backup_file_if_exists "$HOME/.github/AGENTS.md"
        cp AGENTS.md "$HOME/.github/AGENTS.md"
        log_success "AGENTS.md -> ~/.github/AGENTS.md"
    fi

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

        generate_consolidated_rules "$HOME/.windsurfrules"
        log_success "Rules consolidadas -> ~/.windsurfrules"

        # Global Rules -> ~/.codeium/windsurf/memories/global_rules.md
        # Ref: https://docs.windsurf.com/windsurf/cascade/memories
        # Escopo global (todos os workspaces), sempre ativo, limite 6.000 chars
        mkdir -p "$HOME/.codeium/windsurf/memories"
        backup_file_if_exists "$HOME/.codeium/windsurf/memories/global_rules.md"
        generate_consolidated_rules "$HOME/.codeium/windsurf/memories/global_rules.md"
        log_success "Global Rules -> ~/.codeium/windsurf/memories/global_rules.md"
        local rules_size
        rules_size=$(wc -c < "$HOME/.codeium/windsurf/memories/global_rules.md" 2>/dev/null || echo 0)
        if [ "$rules_size" -gt 6000 ]; then
            log_warning "global_rules.md excede o limite de 6.000 chars (${rules_size} chars). Windsurf pode truncar o conteudo."
        fi
    fi

    # Knowledge -> ~/.windsurf/knowledge (memories)
    if [ -d "knowledge" ]; then
        backup_dir_if_exists "$HOME/.windsurf/knowledge"
        cp -a knowledge/* "$HOME/.windsurf/knowledge/" 2>/dev/null || true
        log_success "Knowledge -> ~/.windsurf/knowledge"
    fi

    # AGENTS.md -> ~/.windsurf/AGENTS.md
    if [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.windsurf"
        backup_file_if_exists "$HOME/.windsurf/AGENTS.md"
        cp AGENTS.md "$HOME/.windsurf/AGENTS.md"
        log_success "AGENTS.md -> ~/.windsurf/AGENTS.md"
    fi

    log_success "Windsurf (Cascade) instalado!"
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

        generate_consolidated_rules "$HOME/.cursorrules"
        log_success "Rules consolidadas -> ~/.cursorrules"
    fi

    # Knowledge -> ~/.cursor/knowledge
    if [ -d "knowledge" ]; then
        backup_dir_if_exists "$HOME/.cursor/knowledge"
        cp -a knowledge/* "$HOME/.cursor/knowledge/" 2>/dev/null || true
        log_success "Knowledge -> ~/.cursor/knowledge"
    fi

    # AGENTS.md -> ~/.cursor/AGENTS.md
    if [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.cursor"
        backup_file_if_exists "$HOME/.cursor/AGENTS.md"
        cp AGENTS.md "$HOME/.cursor/AGENTS.md"
        log_success "AGENTS.md -> ~/.cursor/AGENTS.md"
    fi

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
    if [ -d "knowledge" ]; then
        backup_dir_if_exists "$HOME/.devin/knowledge"
        cp -a knowledge/* "$HOME/.devin/knowledge/" 2>/dev/null || true
        log_success "Knowledge -> ~/.devin/knowledge"
    fi

    # Devin CLI (Terminal) - Skills -> ~/.config/cognition/skills/
    # Ref: https://cli.devin.ai/docs/extensibility/skills/overview#where-skills-live
    backup_dir_if_exists "$HOME/.config/cognition/skills"
    cp -a skills/* "$HOME/.config/cognition/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.config/cognition/skills (Devin CLI)"

    # Devin CLI - Knowledge -> ~/.config/cognition/knowledge/
    if [ -d "knowledge" ]; then
        backup_dir_if_exists "$HOME/.config/cognition/knowledge"
        cp -a knowledge/* "$HOME/.config/cognition/knowledge/" 2>/dev/null || true
        log_success "Knowledge -> ~/.config/cognition/knowledge (Devin CLI)"
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
            generate_consolidated_rules "$HOME/.windsurfrules"
            log_success "Rules consolidadas -> ~/.windsurfrules (para Devin Review / Devin CLI)"
        else
            log_info "~/.windsurfrules ja existe, pulando (instale --windsurf para atualizar)"
        fi
    fi

    # AGENTS.md -> ~/.devin/AGENTS.md
    if [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.devin"
        backup_file_if_exists "$HOME/.devin/AGENTS.md"
        cp AGENTS.md "$HOME/.devin/AGENTS.md"
        log_success "AGENTS.md -> ~/.devin/AGENTS.md"
    fi

    log_success "Devin / Devin Review / Devin CLI instalado!"
}

install_claude() {
    log_info "=== Instalando para Claude Code ==="

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
    if [ -d "knowledge" ]; then
        backup_dir_if_exists "$HOME/.claude/knowledge"
        cp -a knowledge/* "$HOME/.claude/knowledge/" 2>/dev/null || true
        log_success "Knowledge -> ~/.claude/knowledge"
    fi

    # CLAUDE.md -> ~/.claude/CLAUDE.md (instrucoes globais para Claude Code)
    # Ref: https://docs.anthropic.com/en/docs/claude-code/memory
    # CLAUDE.md e carregado automaticamente como contexto global em todas as sessoes
    if [ -d "rules" ]; then
        backup_file_if_exists "$HOME/.claude/CLAUDE.md"
        echo "# CLAUDE.md — agents-skills" > "$HOME/.claude/CLAUDE.md"
        echo "" >> "$HOME/.claude/CLAUDE.md"
        echo "> Auto-generated from agents-skills rules" >> "$HOME/.claude/CLAUDE.md"
        echo "" >> "$HOME/.claude/CLAUDE.md"
        echo "## Skills" >> "$HOME/.claude/CLAUDE.md"
        echo "" >> "$HOME/.claude/CLAUDE.md"
        echo "Skills disponiveis em \`~/.claude/skills/\`. Cada subdiretorio contem um \`SKILL.md\`." >> "$HOME/.claude/CLAUDE.md"
        echo "Ao receber uma solicitacao, verifique se alguma skill se aplica e carregue-a antes de responder." >> "$HOME/.claude/CLAUDE.md"
        echo "" >> "$HOME/.claude/CLAUDE.md"
        echo "## Knowledge" >> "$HOME/.claude/CLAUDE.md"
        echo "" >> "$HOME/.claude/CLAUDE.md"
        echo "Knowledge sources disponiveis em \`~/.claude/knowledge/\`. Consulte conforme necessidade do contexto." >> "$HOME/.claude/CLAUDE.md"
        echo "" >> "$HOME/.claude/CLAUDE.md"
        echo "## Rules" >> "$HOME/.claude/CLAUDE.md"
        echo "" >> "$HOME/.claude/CLAUDE.md"
        echo "Rules detalhadas em \`~/.claude/rules/\`. Arquivos \`.instructions.md\` com YAML frontmatter." >> "$HOME/.claude/CLAUDE.md"
        echo "" >> "$HOME/.claude/CLAUDE.md"
        echo "---" >> "$HOME/.claude/CLAUDE.md"
        echo "" >> "$HOME/.claude/CLAUDE.md"
        # Incluir global-rules inline para contexto imediato
        if [ -f "rules/global-rules.instructions.md" ]; then
            cat "rules/global-rules.instructions.md" >> "$HOME/.claude/CLAUDE.md"
        fi
        log_success "CLAUDE.md -> ~/.claude/CLAUDE.md"
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
Revise o codigo seguindo as rules do agents-skills:

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

    # AGENTS.md -> ~/.claude/AGENTS.md
    if [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.claude"
        backup_file_if_exists "$HOME/.claude/AGENTS.md"
        cp AGENTS.md "$HOME/.claude/AGENTS.md"
        log_success "AGENTS.md -> ~/.claude/AGENTS.md"
    fi

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
        generate_consolidated_rules "$HOME/.gemini/GEMINI.md"
        log_success "Rules consolidadas -> ~/.gemini/GEMINI.md"
    fi

    # Knowledge -> ~/.gemini/knowledge
    if [ -d "knowledge" ]; then
        backup_dir_if_exists "$HOME/.gemini/knowledge"
        cp -a knowledge/* "$HOME/.gemini/knowledge/" 2>/dev/null || true
        log_success "Knowledge -> ~/.gemini/knowledge"
    fi

    # Memory files para Gemini CLI (contexto persistente)
    # Gemini CLI suporta arquivos de memoria no workspace
    mkdir -p "$HOME/.gemini/memory"
    if [ -f "MEMORY.md" ]; then
        backup_file_if_exists "$HOME/.gemini/MEMORY.md"
        cp MEMORY.md "$HOME/.gemini/MEMORY.md"
        log_success "MEMORY.md -> ~/.gemini/MEMORY.md"
    fi

    # AGENTS.md -> ~/.gemini/AGENTS.md
    if [ -f "AGENTS.md" ]; then
        mkdir -p "$HOME/.gemini"
        backup_file_if_exists "$HOME/.gemini/AGENTS.md"
        cp AGENTS.md "$HOME/.gemini/AGENTS.md"
        log_success "AGENTS.md -> ~/.gemini/AGENTS.md"
    fi

    log_success "Gemini CLI (Google) instalado!"
}

install_openclaw() {
    log_info "=== Instalando para OpenClaw ==="

    # OpenClaw usa skills em ~/.openclaw/skills e workspace/skills
    # Ref: https://docs.openclaw.ai/tools/skills
    # Skills -> ~/.openclaw/skills (managed skills)
    backup_dir_if_exists "$HOME/.openclaw/skills"
    cp -a skills/* "$HOME/.openclaw/skills/" 2>/dev/null || true
    log_success "Skills -> ~/.openclaw/skills"

    # Memory files -> ~/.openclaw/workspace/memory/
    # OpenClaw usa memoria em Markdown no workspace
    # Ref: https://docs.openclaw.ai/concepts/memory
    mkdir -p "$HOME/.openclaw/workspace/memory"
    
    # MEMORY.md -> ~/.openclaw/workspace/memory/MEMORY.md
    if [ -f "MEMORY.md" ]; then
        backup_file_if_exists "$HOME/.openclaw/workspace/memory/MEMORY.md"
        cp MEMORY.md "$HOME/.openclaw/workspace/memory/MEMORY.md"
        log_success "MEMORY.md -> ~/.openclaw/workspace/memory/MEMORY.md"
    fi
    
    # Knowledge -> ~/.openclaw/workspace/memory/ (como arquivos de memoria)
    if [ -d "knowledge" ]; then
        backup_dir_if_exists "$HOME/.openclaw/workspace/memory/knowledge"
        cp -a knowledge/* "$HOME/.openclaw/workspace/memory/" 2>/dev/null || true
        log_success "Knowledge -> ~/.openclaw/workspace/memory/"
    fi
    
    # Criar estrutura de memoria diaria se necessario
    local today=$(date +%Y-%m-%d)
    mkdir -p "$HOME/.openclaw/workspace/memory"
    if [ ! -f "$HOME/.openclaw/workspace/memory/$today.md" ]; then
        echo "# Memory Log - $today" > "$HOME/.openclaw/workspace/memory/$today.md"
        echo "" >> "$HOME/.openclaw/workspace/memory/$today.md"
        log_success "Daily memory file created: ~/.openclaw/workspace/memory/$today.md"
    fi

    # AGENTS.md -> ~/.openclaw/workspace/AGENTS.md
    if [ -f "AGENTS.md" ]; then
        backup_file_if_exists "$HOME/.openclaw/workspace/AGENTS.md"
        cp AGENTS.md "$HOME/.openclaw/workspace/AGENTS.md"
        log_success "AGENTS.md -> ~/.openclaw/workspace/AGENTS.md"
    fi

    log_success "OpenClaw instalado!"
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
        [ -d "$HOME/.config/cognition/skills" ] && log_success "  Skills (Devin CLI): ~/.config/cognition/skills"
        [ -d "$HOME/.config/cognition/knowledge" ] && log_success "  Knowledge (Devin CLI): ~/.config/cognition/knowledge"
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
        [ -f "$HOME/.gemini/MEMORY.md" ] && log_success "  Memory: ~/.gemini/MEMORY.md"
    fi

    if [ "$INSTALL_OPENCLAW" = true ]; then
        echo
        log_info "OpenClaw:"
        [ -d "$HOME/.openclaw/skills" ] && log_success "  Skills: ~/.openclaw/skills"
        [ -f "$HOME/.openclaw/workspace/memory/MEMORY.md" ] && log_success "  Memory: ~/.openclaw/workspace/memory/MEMORY.md"
        [ -d "$HOME/.openclaw/workspace/memory" ] && log_success "  Memory dir: ~/.openclaw/workspace/memory/"
        [ -f "$HOME/.openclaw/workspace/AGENTS.md" ] && log_success "  AGENTS.md: ~/.openclaw/workspace/AGENTS.md"
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
    fi
    if [ "$INSTALL_CURSOR" = true ]; then
        echo "  rm -rf ~/.cursor/skills ~/.cursor/rules ~/.cursor/knowledge"
        echo "  rm -f ~/.cursorrules ~/.cursor/AGENTS.md"
    fi
    if [ "$INSTALL_DEVIN" = true ]; then
        echo "  rm -rf ~/.cognition/skills"
        echo "  rm -rf ~/.devin/skills ~/.devin/knowledge"
        echo "  rm -f ~/.devin/AGENTS.md"
        echo "  rm -rf ~/.config/cognition/skills ~/.config/cognition/knowledge"
    fi
    if [ "$INSTALL_CLAUDE" = true ]; then
        echo "  rm -rf ~/.claude/skills ~/.claude/rules ~/.claude/knowledge ~/.claude/commands"
        echo "  rm -f ~/.claude/AGENTS.md ~/.claude/CLAUDE.md ~/.claude/settings.json"
    fi
    if [ "$INSTALL_GEMINI" = true ]; then
        echo "  rm -rf ~/.gemini/skills ~/.gemini/knowledge"
        echo "  rm -f ~/.gemini/GEMINI.md ~/.gemini/AGENTS.md ~/.gemini/MEMORY.md"
    fi
    if [ "$INSTALL_OPENCLAW" = true ]; then
        echo "  rm -rf ~/.openclaw/skills ~/.openclaw/workspace/memory"
        echo "  rm -f ~/.openclaw/workspace/AGENTS.md"
    fi

    echo
    echo "  Para limpar backups: ./rm-backup.sh"
    echo
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo "========================================"
    echo "  agents-skills - Instalador"
    echo "========================================"
    echo

    local ides_selecionadas=""
    [ "$INSTALL_VSCODE" = true ] && ides_selecionadas="${ides_selecionadas} VS-Code"
    [ "$INSTALL_WINDSURF" = true ] && ides_selecionadas="${ides_selecionadas} Windsurf"
    [ "$INSTALL_CURSOR" = true ] && ides_selecionadas="${ides_selecionadas} Cursor"
    [ "$INSTALL_DEVIN" = true ] && ides_selecionadas="${ides_selecionadas} Devin"
    [ "$INSTALL_CLAUDE" = true ] && ides_selecionadas="${ides_selecionadas} Claude"
    [ "$INSTALL_GEMINI" = true ] && ides_selecionadas="${ides_selecionadas} Gemini"
    [ "$INSTALL_OPENCLAW" = true ] && ides_selecionadas="${ides_selecionadas} OpenClaw"
    log_info "IDEs/CLIs selecionadas:${ides_selecionadas}"
    echo

    check_directory
    install_base

    [ "$INSTALL_VSCODE" = true ] && install_vscode
    [ "$INSTALL_WINDSURF" = true ] && install_windsurf
    [ "$INSTALL_CURSOR" = true ] && install_cursor
    [ "$INSTALL_DEVIN" = true ] && install_devin
    [ "$INSTALL_CLAUDE" = true ] && install_claude
    [ "$INSTALL_GEMINI" = true ] && install_gemini
    [ "$INSTALL_OPENCLAW" = true ] && install_openclaw

    verify_installation
    show_post_install

    log_success "Instalacao concluida com sucesso!"
}

parse_args "$@"
main
