#!/bin/bash

# Script para remover todos os backups criados pelo install.sh
# Remove diretórios e arquivos terminados em .backup.* nos diretórios HOME dos agentes
# Suporta: VS Code, Windsurf, Cursor, Devin, Claude, Gemini CLI, OpenClaw

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

show_help() {
    echo
    echo -e "${BLUE}agents-skills - Cleanup Script${NC}"
    echo
    echo -e "${YELLOW}Uso:${NC}"
    echo "  ./rm-backup.sh [opcoes]"
    echo
    echo -e "${YELLOW}Opcoes:${NC}"
    echo "  --help, -h     Exibe esta mensagem de ajuda"
    echo "  --dry-run, -d  Lista os backups que seriam removidos (sem remover)"
    echo "  --verbose, -v  Modo verboso"
    echo
    echo -e "${YELLOW}O que sera limpo:${NC}"
    echo "  - Backups de skills em ~/.agents/, ~/.windsurf/, ~/.cursor/, etc."
    echo "  - Backups de rules consolidadas (.windsurfrules, .cursorrules)"
    echo "  - Backups de arquivos de conhecimento (knowledge/)"
    echo "  - Backups de arquivos de memoria (OpenClaw, Gemini)"
    echo "  - Backups do Visual Studio (Windows)"
    echo
}

# Variaveis de controle
DRY_RUN=false
VERBOSE=false

remove_backups() {
    local total_removed=0
    local dirs=(
        "$HOME/.agents"
        "$HOME/.devin"
        "$HOME/.claude"
        "$HOME/.windsurf"
        "$HOME/.github"
        "$HOME/.copilot"
        "$HOME/.cursor"
        "$HOME/.gemini"
        "$HOME/.cognition"
        "$HOME/.config/cognition"
        "$HOME/.openclaw"
    )

    log_info "Iniciando limpeza de backups..."
    echo

    # Remove backups nos diretórios principais
    for base in "${dirs[@]}"; do
        if [ ! -d "$base" ]; then
            [ "$VERBOSE" = true ] && log_warning "Diretório não encontrado: $base"
            continue
        fi

        log_info "Verificando backups em $base..."
        
        local found_backups
        if [ "$DRY_RUN" = true ]; then
            found_backups=$(find "$base" -maxdepth 2 -name '*.backup.*' 2>/dev/null || true)
            if [ -n "$found_backups" ]; then
                echo "$found_backups"
                total_removed=$((total_removed + $(echo "$found_backups" | wc -l)))
            fi
        else
            local removed_count
            removed_count=$(find "$base" -maxdepth 2 -name '*.backup.*' -exec rm -rf {} + 2>/dev/null | wc -l || true)
            if [ "$removed_count" -gt 0 ]; then
                log_success "Removidos $removed_count backups em $base"
                total_removed=$((total_removed + removed_count))
            else
                [ "$VERBOSE" = true ] && log_info "Nenhum backup encontrado em $base"
            fi
        fi
    done

    echo
    log_info "Verificando backups de arquivos consolidados..."

    # Remove backups de arquivos consolidados no nível HOME
    local consolidated_files=(
        ".windsurfrules.backup.*"
        ".cursorrules.backup.*"
        "AGENTS.md.backup.*"
    )

    for pattern in "${consolidated_files[@]}"; do
        local found_files
        if [ "$DRY_RUN" = true ]; then
            found_files=$(find "$HOME" -maxdepth 1 -name "$pattern" 2>/dev/null || true)
            if [ -n "$found_files" ]; then
                echo "$found_files"
                total_removed=$((total_removed + $(echo "$found_files" | wc -l)))
            fi
        else
            local removed_count
            removed_count=$(find "$HOME" -maxdepth 1 -name "$pattern" -exec rm -f {} + 2>/dev/null | wc -l || true)
            if [ "$removed_count" -gt 0 ]; then
                log_success "Removidos $removed_count backups de $pattern"
                total_removed=$((total_removed + removed_count))
            fi
        fi
    done

    # Remove backups de arquivos específicos do Gemini
    if [ -d "$HOME/.gemini" ]; then
        local gemini_files=(
            "GEMINI.md.backup.*"
            "MEMORY.md.backup.*"
        )
        
        for pattern in "${gemini_files[@]}"; do
            local found_files
            if [ "$DRY_RUN" = true ]; then
                found_files=$(find "$HOME/.gemini" -maxdepth 1 -name "$pattern" 2>/dev/null || true)
                if [ -n "$found_files" ]; then
                    echo "$found_files"
                    total_removed=$((total_removed + $(echo "$found_files" | wc -l)))
                fi
            else
                local removed_count
                removed_count=$(find "$HOME/.gemini" -maxdepth 1 -name "$pattern" -exec rm -f {} + 2>/dev/null | wc -l || true)
                if [ "$removed_count" -gt 0 ]; then
                    log_success "Removidos $removed_count backups de Gemini ($pattern)"
                    total_removed=$((total_removed + removed_count))
                fi
            fi
        done
    fi

    # Remove backups de OpenClaw
    if [ -d "$HOME/.openclaw" ]; then
        log_info "Verificando backups de OpenClaw..."
        
        local openclaw_patterns=(
            "*.backup.*"
            "workspace/memory/*.backup.*"
            "workspace/memory/MEMORY.md.backup.*"
            "workspace/memory/AGENTS.md.backup.*"
            "workspace/memory/*.md.backup.*"
        )
        
        for pattern in "${openclaw_patterns[@]}"; do
            local found_files
            if [ "$DRY_RUN" = true ]; then
                found_files=$(find "$HOME/.openclaw" -name "$pattern" 2>/dev/null || true)
                if [ -n "$found_files" ]; then
                    echo "$found_files"
                    total_removed=$((total_removed + $(echo "$found_files" | wc -l)))
                fi
            else
                local removed_count
                removed_count=$(find "$HOME/.openclaw" -name "$pattern" -exec rm -rf {} + 2>/dev/null | wc -l || true)
                if [ "$removed_count" -gt 0 ]; then
                    log_success "Removidos $removed_count backups de OpenClaw ($pattern)"
                    total_removed=$((total_removed + removed_count))
                fi
            fi
        done
    fi

    # Remove backups de copilot-instructions.md
    if [ -d "$HOME/.github" ]; then
        local found_files
        if [ "$DRY_RUN" = true ]; then
            found_files=$(find "$HOME/.github" -maxdepth 1 -name 'copilot-instructions.md.backup.*' 2>/dev/null || true)
            if [ -n "$found_files" ]; then
                echo "$found_files"
                total_removed=$((total_removed + $(echo "$found_files" | wc -l)))
            fi
        else
            local removed_count
            removed_count=$(find "$HOME/.github" -maxdepth 1 -name 'copilot-instructions.md.backup.*' -exec rm -f {} + 2>/dev/null | wc -l || true)
            if [ "$removed_count" -gt 0 ]; then
                log_success "Removidos $removed_count backups de copilot-instructions.md"
                total_removed=$((total_removed + removed_count))
            fi
        fi
    fi

    # Remove backups de Visual Studio no Windows
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]] || [[ "$(uname -s)" == *MINGW* || "$(uname -s)" == *MSYS* ]]; then
        log_info "Verificando backups do Visual Studio (Windows)..."
        
        if [ -n "$USERPROFILE" ]; then
            local docs_path="$USERPROFILE/Documents"
        else
            local docs_path="$HOME/Documents"
        fi
        
        for vsdir in "$docs_path/Visual Studio/2022/Skills" "$docs_path/Visual Studio/2026/Skills"; do
            if [ -d "$(dirname "$vsdir")" ]; then
                local found_files
                if [ "$DRY_RUN" = true ]; then
                    found_files=$(find "$(dirname "$vsdir")" -maxdepth 2 -name 'Skills.backup.*' 2>/dev/null || true)
                    if [ -n "$found_files" ]; then
                        echo "$found_files"
                        total_removed=$((total_removed + $(echo "$found_files" | wc -l)))
                    fi
                else
                    local removed_count
                    removed_count=$(find "$(dirname "$vsdir")" -maxdepth 2 -name 'Skills.backup.*' -exec rm -rf {} + 2>/dev/null | wc -l || true)
                    if [ "$removed_count" -gt 0 ]; then
                        log_success "Removidos $removed_count backups do Visual Studio"
                        total_removed=$((total_removed + removed_count))
                    fi
                fi
            fi
        done
    fi

    echo
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: $total_removed backups encontrados para remoção"
        log_info "Execute novamente sem --dry-run para remover os backups"
    else
        if [ "$total_removed" -gt 0 ]; then
            log_success "Removidos $total_removed backups com sucesso!"
        else
            log_info "Nenhum backup encontrado para remover"
        fi
    fi
}

# Parse arguments
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --dry-run|-d)
                DRY_RUN=true
                ;;
            --verbose|-v)
                VERBOSE=true
                ;;
            *)
                log_error "Opção desconhecida: $1"
                echo "Use --help para ver as opções disponíveis."
                exit 1
                ;;
        esac
        shift
    done
}

# Main execution
main() {
    echo "========================================"
    echo "  agents-skills - Cleanup Script"
    echo "========================================"
    echo
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "MODO DRY RUN - Nenhum arquivo será removido"
    fi
    
    if [ "$VERBOSE" = true ]; then
        log_info "Modo verboso ativado"
    fi
    
    echo
    
    remove_backups
}

parse_args "$@"
main
