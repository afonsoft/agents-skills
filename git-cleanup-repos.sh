#!/bin/bash

ROOT="$(pwd)"

# Log com timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG="${ROOT}/git_cleanup_${TIMESTAMP}.log"

# Cabeçalho do log
{
    echo "=================================================================="
    echo "Git cleanup scan - ROOT: ${ROOT}"
    echo "Data/Hora: $(date)"
    echo "=================================================================="
} >> "$LOG"

echo ""
echo "ROOT: ${ROOT}"
echo "Log:  ${LOG}"
echo ""

# Função para limpar um repositório
cleanup_repo() {
    local REPO="$1"
    
    {
        echo "----------------------------------------------------------"
        echo "[REPO] ${REPO}"
        echo "----------------------------------------------------------"
    } >> "$LOG"
    
    echo "[REPO] ${REPO}"
    
    cd "$REPO" || return
    
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "  - NAO parece repo Git valido. Pulando..." | tee -a "$LOG"
        return
    fi
    
    echo "  - Antes:" >> "$LOG"
    git count-objects -v >> "$LOG" 2>&1
    
    echo "  - fetch -p" >> "$LOG"
    git fetch -p >> "$LOG" 2>&1
    
    echo "  - pull" >> "$LOG"
    git pull >> "$LOG" 2>&1
    
    echo "  - reflog expire --expire=now --all" >> "$LOG"
    git reflog expire --expire=now --all >> "$LOG" 2>&1
    
    echo "  - git gc --prune=now" >> "$LOG"
    git gc --prune=now >> "$LOG" 2>&1

    echo "  - git clean -df" >> "$LOG"
    git clean -df >> "$LOG" 2>&1

    echo "  - git clean -dfX" >> "$LOG"
    git clean -dfX >> "$LOG" 2>&1
    
    # Remove build output directories
    echo "  - Removendo diretórios de build (bin, obj, .vs, node_modules)..." >> "$LOG"
    for dir in bin obj .vs node_modules; do
        if [[ -d "$dir" ]]; then
            echo "    - Removendo $dir/" >> "$LOG"
            rm -rf "$dir" >> "$LOG" 2>&1
        fi
    done
    
    # Also remove these directories recursively in subfolders
    echo "  - Removendo diretórios de build recursivamente..." >> "$LOG"
    find . -type d \( -name bin -o -name obj -o -name .vs -o -name node_modules \) -exec rm -rf {} + 2>/dev/null >> "$LOG" 2>&1
    
    echo "  - Depois:" >> "$LOG"
    git count-objects -v >> "$LOG" 2>&1
}

# Função para varrer pastas recursivamente
scan_folder() {
    local DIR="$1"
    local BASENAME=$(basename "$DIR")
    
    # Ignora pastas que não vale varrer
    case "$BASENAME" in
        .git|node_modules|bin|obj|.vs|.idea)
            return
            ;;
    esac
    
    # Achou repo -> limpa UMA vez e não desce mais
    if [[ -d "${DIR}/.git" ]]; then
        cleanup_repo "$DIR"
        return
    fi
    
    # Não é repo -> percorre subpastas
    for subdir in "$DIR"/*/ ; do
        [[ -d "$subdir" ]] && scan_folder "$subdir"
    done
}

# Inicia o scan
scan_folder "$ROOT"

echo ""
echo "Finalizado. Veja o log em: ${LOG}"
