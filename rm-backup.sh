#!/bin/bash

# Script para remover todos os backups criados pelo install.sh
# Remove diretórios e arquivos terminados em .backup.* nos diretórios HOME dos agentes

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

remove_backups() {
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
    )

    for base in "${dirs[@]}"; do
        log_info "Removendo backups em $base..."
        find "$base" -maxdepth 2 -name '*.backup.*' -exec rm -rf {} + 2>/dev/null || true
    done

    # Remove backups de copilot-instructions.md
    if [ -d "$HOME/.github" ]; then
        find "$HOME/.github" -maxdepth 1 -name 'copilot-instructions.md.backup.*' -exec rm -f {} + 2>/dev/null || true
    fi

    # Remove backups de .windsurfrules e .cursorrules
    find "$HOME" -maxdepth 1 -name '.windsurfrules.backup.*' -exec rm -f {} + 2>/dev/null || true
    find "$HOME" -maxdepth 1 -name '.cursorrules.backup.*' -exec rm -f {} + 2>/dev/null || true

    # Remove backups de Visual Studio no Windows
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]] || [[ "$(uname -s)" == *MINGW* || "$(uname -s)" == *MSYS* ]]; then
        if [ -n "$USERPROFILE" ]; then
            local docs_path="$USERPROFILE/Documents"
        else
            local docs_path="$HOME/Documents"
        fi
        for vsdir in "$docs_path/Visual Studio/2022/Skills" "$docs_path/Visual Studio/2026/Skills"; do
            find "$(dirname "$vsdir")" -maxdepth 2 -name 'Skills.backup.*' -exec rm -rf {} + 2>/dev/null || true
        done
    fi

    log_success "Backups removidos com sucesso!"
}

remove_backups
