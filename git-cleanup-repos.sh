#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Variáveis padrão
ROOT="${1:-$(pwd)}"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG="${ROOT}/git_cleanup_${TIMESTAMP}.log"
VERBOSE=false
DRY_RUN=false
SHOW_HELP=false

# Função de help
show_help() {
    echo -e "${CYAN}Git Repository Cleanup Script${NC}"
    echo
    echo -e "${YELLOW}Uso:${NC}"
    echo "  $0 [opcoes] [caminho]"
    echo
    echo -e "${YELLOW}Opcoes:${NC}"
    echo "  -h, --help      Exibe esta mensagem de ajuda"
    echo "  -v, --verbose   Modo detalhado com cores"
    echo "  -d, --dry-run   Simula operacoes sem executar"
    echo "  -q, --quiet     Modo silencioso (sem output colorido)"
    echo
    echo -e "${YELLOW}Exemplos:${NC}"
    echo "  $0                           # Usa diretorio atual"
    echo "  $0 /meus/projetos          # Usa diretorio especifico"
    echo "  $0 -v --dry-run /meus/projetos # Modo detalhado + simulacao"
    echo
    echo -e "${YELLOW}O que sera limpo:${NC}"
    echo "  - Git fetch, pull, reflog cleanup"
    echo "  - Garbage collection (git gc)"
    echo "  - Build artifacts (bin, obj, .vs, node_modules)"
    echo "  - Logs detalhados com cores e timestamps"
}

# Funções de log coloridas
log_info() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" >> "$LOG"
}

log_success() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] $1" >> "$LOG"
}

log_warning() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${YELLOW}[WARNING]${NC} $1"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $1" >> "$LOG"
}

log_error() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${RED}[ERROR]${NC} $1"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >> "$LOG"
}

log_header() {
    local title="$1"
    {
        echo "=================================================================="
        echo "${CYAN}$title${NC}"
        echo "Data/Hora: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=================================================================="
    } >> "$LOG"
    
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}==================================================================${NC}"
        echo -e "${CYAN}$title${NC}"
        echo -e "${CYAN}Data/Hora: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
        echo -e "${CYAN}==================================================================${NC}"
    fi
}

# Parse de argumentos
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                SHOW_HELP=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -q|--quiet)
                VERBOSE=false
                shift
                ;;
            -*)
                log_error "Opcao desconhecida: $1"
                show_help
                exit 1
                ;;
            *)
                # Se não começa com-, é o path
                if [[ "$1" != -* ]]; then
                    ROOT="$1"
                    LOG="${ROOT}/git_cleanup_${TIMESTAMP}.log"
                    shift
                else
                    log_error "Opcao desconhecida: $1"
                    show_help
                    exit 1
                fi
                ;;
        esac
    done
}

# Função para exibir estatísticas do repositório
show_repo_stats() {
    local repo_path="$1"
    local label="$2"
    
    if [ ! -d "$repo_path/.git" ]; then
        return
    fi
    
    cd "$repo_path" || return
    
    local object_count=$(git count-objects 2>/dev/null | grep -o '[0-9]\+' | head -1 || echo "0")
    local size_bytes=$(git du 2>/dev/null | tail -1 | cut -f1 || echo "0")
    local branch_count=$(git branch -a 2>/dev/null | wc -l || echo "0")
    local remote_count=$(git remote 2>/dev/null | wc -l || echo "0")
    
    if [ "$VERBOSE" = true ]; then
        echo -e "  ${PURPLE}$label${NC}"
        echo -e "    ${WHITE}Objetos:${NC} $object_count"
        echo -e "    ${WHITE}Tamanho:${NC} $size_bytes bytes"
        echo -e "    ${WHITE}Branches:${NC} $branch_count"
        echo -e "    ${WHITE}Remotos:${NC} $remote_count"
    fi
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') [STATS] $label - Objects: $object_count, Size: $size_bytes, Branches: $branch_count, Remotes: $remote_count" >> "$LOG"
}

# Função para limpar um repositório
cleanup_repo() {
    local REPO="$1"
    local repo_name=$(basename "$REPO")
    
    log_header " Limpando Repositório: $repo_name"
    
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[REPO]${NC} $REPO"
    fi
    
    cd "$REPO" || {
        log_error "Nao foi possivel acessar: $REPO"
        return 1
    }
    
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        log_warning "Nao parece ser um repositorio Git valido. Pulando..."
        return
    fi
    
    # Estatísticas antes
    log_info "Coletando estatisticas antes da limpeza..."
    show_repo_stats "$REPO" "ANTES"
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "MODO DRY-RUN: Operacoes seriam executadas"
        return
    fi
    
    # Operações Git
    log_info "Executando fetch para atualizar referencias remotas..."
    git fetch -p 2>&1 | while IFS= read -r line; do
        log_info "Fetch: $line"
    done
    
    log_info "Executando pull para sincronizar com remoto..."
    git pull 2>&1 | while IFS= read -r line; do
        log_info "Pull: $line"
    done
    
    log_info "Limpando reflog (removendo historico local)..."
    git reflog expire --expire=now --all 2>&1 | while IFS= read -r line; do
        log_info "Reflog: $line"
    done
    
    log_info "Executando garbage collection..."
    git gc --prune=now 2>&1 | while IFS= read -r line; do
        log_info "GC: $line"
    done
    
    log_info "Limpando arquivos nao rastreados..."
    git clean -df 2>&1 | while IFS= read -r line; do
        log_info "Clean: $line"
    done
    
    log_info "Limpando arquivos ignorados..."
    git clean -dfX 2>&1 | while IFS= read -r line; do
        log_info "CleanX: $line"
    done
    
    # Remove build output directories
    log_info "Removendo diretorios de build (bin, obj, .vs, node_modules)..."
    local build_dirs_removed=0
    local build_size_freed=0
    
    for dir in bin obj .vs node_modules dist build target out; do
        if [[ -d "$dir" ]]; then
            local dir_size=$(du -sb "$dir" 2>/dev/null | cut -f1 || echo "0")
            if [ "$VERBOSE" = true ]; then
                echo -e "  ${YELLOW}Removendo:${NC} $dir/ (${dir_size} bytes)"
            fi
            rm -rf "$dir" 2>/dev/null
            if [ $? -eq 0 ]; then
                ((build_dirs_removed++))
                ((build_size_freed += dir_size))
                log_success "Diretorio removido: $dir/ (${dir_size} bytes)"
            else
                log_error "Falha ao remover: $dir/"
            fi
        fi
    done
    
    # Remove build directories recursively
    log_info "Buscando diretorios de build recursivamente..."
    local recursive_dirs_removed=$(find . -type d \( -name bin -o -name obj -o -name .vs -o -name node_modules -o -name dist -o -name build -o -name target -o -name out \) -exec rm -rf {} + 2>/dev/null | wc -l)
    if [ "$recursive_dirs_removed" -gt 0 ]; then
        log_success "Diretorios de build removidos recursivamente: $recursive_dirs_removed"
    fi
    
    # Estatísticas depois
    log_info "Coletando estatisticas depois da limpeza..."
    show_repo_stats "$REPO" "DEPOIS"
    
    # Resumo da limpeza
    log_success "Limpeza concluida para: $repo_name"
    log_info "Resumo: Diretorios build removidos: $build_dirs_removed (${build_size_freed} bytes), Recursivos: $recursive_dirs_removed"
    
    cd - > /dev/null
}

# Função para varrer pastas recursivamente
scan_folder() {
    local DIR="$1"
    local BASENAME=$(basename "$DIR")
    
    # Ignora pastas que não vale varrer
    case "$BASENAME" in
        .git|node_modules|bin|obj|.vs|.idea|dist|build|target|out)
            if [ "$VERBOSE" = true ]; then
                log_info "Ignorando pasta: $BASENAME"
            fi
            return
            ;;
    esac
    
    # Achou repo -> limpa UMA vez e não desce mais
    if [[ -d "${DIR}/.git" ]]; then
        cleanup_repo "$DIR"
        return
    fi
    
    # Não é repo -> percorre subpastas
    if [ "$VERBOSE" = true ]; then
        log_info "Explorando subpastas de: $BASENAME"
    fi
    
    for subdir in "$DIR"/*/ ; do
        [[ -d "$subdir" ]] && scan_folder "$subdir"
    done
}

# Função principal
main() {
    # Parse de argumentos
    parse_args "$@"
    
    # Exibe help se solicitado
    if [ "$SHOW_HELP" = true ]; then
        show_help
        exit 0
    fi
    
    # Cabeçalho
    echo
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}==================================================================${NC}"
        echo -e "${CYAN}Git Repository Cleanup Script${NC}"
        echo -e "${CYAN}ROOT: ${ROOT}${NC}"
        echo -e "${CYAN}Log: ${LOG}${NC}"
        echo -e "${CYAN}Modo: $([ "$DRY_RUN" = true ] && echo "DRY-RUN" || echo "EXECUCAO")${NC}"
        echo -e "${CYAN}Verbose: $([ "$VERBOSE" = true ] && echo "SIM" || echo "NAO")${NC}"
        echo -e "${CYAN}==================================================================${NC}"
    else
        echo "ROOT: ${ROOT}"
        echo "Log: ${LOG}"
    fi
    echo
    
    # Inicia o scan
    log_info "Iniciando scan de repositorios Git em: $ROOT"
    scan_folder "$ROOT"
    
    # Resumo final
    echo
    if [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}==================================================================${NC}"
        echo -e "${GREEN}Scan concluido!${NC}"
        echo -e "${GREEN}Log detalhado salvo em: ${LOG}${NC}"
        echo -e "${GREEN}==================================================================${NC}"
    else
        echo "Scan concluido. Log salvo em: ${LOG}"
    fi
}

# Execução
main "$@"
