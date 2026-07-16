#!/bin/bash

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS="Linux";;
        Darwin*)    OS="Mac";;
        CYGWIN*)    OS="Windows";;
        MINGW*)     OS="Windows";;
        MSYS*)      OS="Windows";;
        *)          OS="Unknown";;
    esac
    export OS
}

detect_os

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
ROOT="$(pwd)"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG="${ROOT}/git_cleanup_${TIMESTAMP}.log"
VERBOSE=true  # Ativado por padrão para melhor feedback
DRY_RUN=false
SHOW_HELP=false
DISK_SPACE_BEFORE=0
DISK_SPACE_AFTER=0

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
    echo "  - Package manager caches (npm, yarn, nuget, pip, go, cargo, gradle, maven, composer, gem)"
    echo "  - Docker (containers parados, imagens, volumes, redes, build cache, logs)"
    echo "  - Cache de gerenciadores de pacote do sistema (Chocolatey, Scoop)"
    echo "  - Arquivos temporarios do sistema (Temp, INetCache, CrashDumps no Windows)"
    echo "  - Crash reports e dumps (WER, Minidump, memory.dmp)"
    echo "  - Lixeira do Windows"
    echo "  - Identificacao de arquivos grandes (ISO, IMG, VMDK, backups)"
    echo "  - Windows-specific cache directories (no Windows)"
    echo "  - Logs detalhados com cores e timestamps"
}

# Funções de log - Terminal (resumido) e Arquivo (detalhado)
log_info() {
    local message="$1"
    local detailed_msg="$2"
    # Terminal: mensagem resumida
    echo -e "${BLUE}[INFO]${NC} $message"
    # Arquivo: mensagem detalhada se fornecida, senão a mesma
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] ${detailed_msg:-$message}" >> "$LOG"
}

log_success() {
    local message="$1"
    local detailed_msg="$2"
    # Terminal: mensagem resumida
    echo -e "${GREEN}[SUCCESS]${NC} $message"
    # Arquivo: mensagem detalhada se fornecida, senão a mesma
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] ${detailed_msg:-$message}" >> "$LOG"
}

log_warning() {
    local message="$1"
    local detailed_msg="$2"
    # Terminal: mensagem resumida
    echo -e "${YELLOW}[WARNING]${NC} $message"
    # Arquivo: mensagem detalhada se fornecida, senão a mesma
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] ${detailed_msg:-$message}" >> "$LOG"
}

log_error() {
    local message="$1"
    local detailed_msg="$2"
    # Terminal: mensagem resumida
    echo -e "${RED}[ERROR]${NC} $message"
    # Arquivo: mensagem detalhada se fornecida, senão a mesma
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] ${detailed_msg:-$message}" >> "$LOG"
}

# Função para log detalhado apenas no arquivo
log_detail() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DETAIL] $message" >> "$LOG"
}

log_header() {
    local title="$1"
    {
        echo "=================================================================="
        echo "${CYAN}$title${NC}"
        echo "Data/Hora: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=================================================================="
    } >> "$LOG"
   
    echo -e "${CYAN}==================================================================${NC}"
    echo -e "${CYAN}$title${NC}"
    echo -e "${CYAN}Data/Hora: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}==================================================================${NC}"
}

# Função para obter espaço em disco disponível (em KB)
get_disk_space() {
    local path="${1:-$ROOT}"
    local space_kb=0
   
    case "$OS" in
        Linux)
            space_kb=$(df -k "$path" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
            ;;
        Mac)
            space_kb=$(df -k "$path" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
            ;;
        Windows)
            # No Windows/Git Bash, usa df -k que funciona
            space_kb=$(df -k "$path" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
            ;;
        *)
            space_kb=$(df -k "$path" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
            ;;
    esac
   
    echo "$space_kb"
}

# Função para formatar espaço em disco para exibição
format_disk_space() {
    local space_kb="$1"
    local space_mb=$((space_kb / 1024))
    local space_gb=$((space_mb / 1024))
   
    if [ "$space_gb" -gt 0 ]; then
        echo "${space_gb}GB"
    elif [ "$space_mb" -gt 0 ]; then
        echo "${space_mb}MB"
    else
        echo "${space_kb}KB"
    fi
}

# Função para obter e registrar espaço em disco
log_disk_space() {
    local label="$1"
    local space_kb=$(get_disk_space)
    local space_formatted=$(format_disk_space "$space_kb")
   
    # Registra no log
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Espaço em disco $label: $space_formatted ($space_kb KB)" >> "$LOG"
   
    # Retorna apenas o valor numérico para captura
    echo "$space_kb"
}

# Função para exibir espaço em disco (resumido no terminal)
show_disk_space() {
    local label="$1"
    local space_kb=$(get_disk_space)
    local space_formatted=$(format_disk_space "$space_kb")
   
    # Terminal: mensagem resumida
    echo -e "${BLUE}[INFO]${NC} Espaço em disco $label: $space_formatted"
    # Arquivo: mensagem detalhada
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Espaço em disco $label: $space_formatted ($space_kb KB)" >> "$LOG"
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
    echo -e "${BLUE}[REPO]${NC} Processando: $REPO"
    echo -e "${BLUE}[PATH]${NC} Diretório atual: $(pwd)"
   
    cd "$REPO" || {
        log_error "Nao foi possivel acessar: $REPO"
        return 1
    }
   
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        log_warning "Nao parece ser um repositorio Git valido. Pulando..."
        return
    fi
   
    # Estatísticas antes
    log_info "Coletando estatisticas..." "Coletando estatisticas antes da limpeza do repositorio: $repo_name"
    show_repo_stats "$REPO" "ANTES"
   
    if [ "$DRY_RUN" = true ]; then
        log_warning "MODO DRY-RUN: Operacoes seriam executadas"
        return
    fi
   
    # Operações Git
    log_info "Atualizando referencias remotas..." "Executando fetch para atualizar referencias remotas..."
    git fetch -p 2>&1 | while IFS= read -r line; do
        log_detail "Fetch: $line"
    done
   
    log_info "Sincronizando com remoto..." "Executando pull para sincronizar com remoto..."
    git pull 2>&1 | while IFS= read -r line; do
        log_detail "Pull: $line"
    done
   
    log_info "Limpando historico local..." "Limpando reflog (removendo historico local)..."
    git reflog expire --expire=now --all 2>&1 | while IFS= read -r line; do
        log_detail "Reflog: $line"
    done
   
    log_info "Executando garbage collection..." "Executando garbage collection..."
    git gc --prune=now 2>&1 | while IFS= read -r line; do
        log_detail "GC: $line"
    done
   
    log_info "Limpando arquivos..." "Limpando arquivos nao rastreados..."
    git clean -df 2>&1 | while IFS= read -r line; do
        log_detail "Clean: $line"
    done
   
    log_info "Limpando ignorados..." "Limpando arquivos ignorados..."
    git clean -dfX 2>&1 | while IFS= read -r line; do
        log_detail "CleanX: $line"
    done
   
    # Remove build output directories
    log_info "Removendo diretorios de build..." "Removendo diretorios de build (bin, obj, .vs, node_modules)..."
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
    log_info "Buscando build recursivamente..." "Buscando diretorios de build recursivamente..."
    local recursive_dirs_removed=$(find . -type d \( -name bin -o -name obj -o -name .vs -o -name node_modules -o -name dist -o -name build -o -name target -o -name out \) -exec rm -rf {} + 2>/dev/null | wc -l)
    if [ "$recursive_dirs_removed" -gt 0 ]; then
        log_success "Diretorios removidos: $recursive_dirs_removed" "Diretorios de build removidos recursivamente: $recursive_dirs_removed"
    fi
   
    # Estatísticas depois
    log_info "Coletando estatisticas finais..." "Coletando estatisticas depois da limpeza..."
    show_repo_stats "$REPO" "DEPOIS"
   
    # Resumo da limpeza
    log_success "Limpeza concluida: $repo_name" "Limpeza concluida para: $repo_name"
    log_info "Resumo: $build_dirs_removed dirs, ${build_size_freed} bytes, $recursive_dirs_removed recursivos" "Resumo: Diretorios build removidos: $build_dirs_removed (${build_size_freed} bytes), Recursivos: $recursive_dirs_removed"
   
    cd - > /dev/null
}

# Função para limpar caches de gerenciadores de pacotes (executada uma vez após todos os repositórios)
cleanup_package_caches() {
    log_header "LIMPANDO CACHES DE PACOTES"
   
    # Clean package manager caches
    log_info "Limpando caches..." "Limpando caches de gerenciadores de pacotes..."
   
    # NPM cache cleanup
    if command -v npm &> /dev/null; then
        log_info "Limpando cache NPM..." "Limpando cache do NPM..."
        npm cache clean --force 2>&1 | while IFS= read -r line; do
            log_detail "NPM: $line"
        done
        log_success "Cache NPM limpo" "Cache do NPM limpo"
    else
        log_warning "NPM nao encontrado" "NPM nao encontrado, pulando limpeza de cache"
    fi
   
    # Yarn cache cleanup
    if command -v yarn &> /dev/null; then
        log_info "Limpando cache Yarn..." "Limpando cache do Yarn..."
        yarn cache clean 2>&1 | while IFS= read -r line; do
            log_detail "Yarn: $line"
        done
        log_success "Cache Yarn limpo" "Cache do Yarn limpo"
    else
        log_warning "Yarn nao encontrado" "Yarn nao encontrado, pulando limpeza de cache"
    fi
   
    # NuGet cache cleanup (works on both Linux and Windows)
    if command -v dotnet &> /dev/null; then
        log_info "Limpando cache NuGet..." "Limpando cache do NuGet..."
        # Usa timeout para evitar travamento e captura saida
        timeout 30s dotnet nuget locals all --clear 2>&1 | while IFS= read -r line; do
            log_detail "NuGet: $line"
        done
        if [ $? -eq 0 ]; then
            log_success "Cache NuGet limpo" "Cache do NuGet limpo"
        elif [ $? -eq 124 ]; then
            log_warning "Timeout NuGet" "Timeout ao limpar cache do NuGet (30s) - pulando"
        else
            log_warning "Erro NuGet" "Erro ao limpar cache do NuGet - continuando"
        fi
    else
        log_warning "dotnet/NuGet nao encontrado" "dotnet/NuGet nao encontrado, pulando limpeza de cache"
    fi
   
    # Windows-specific additional cleanups
    if [ "$OS" = "Windows" ]; then
        log_info "Executando limpezas Windows..." "Executando limpezas especificas para Windows..."
       
        # Clean Windows package cache directories if they exist
        local windows_cache_dirs=(
            "$LOCALAPPDATA/npm-cache"
            "$LOCALAPPDATA/yarn/cache"
            "$LOCALAPPDATA/NuGet/v3-cache"
            "$APPDATA/npm-cache"
            "$APPDATA/yarn/cache"
        )
       
        for cache_dir in "${windows_cache_dirs[@]}"; do
            if [ -d "$cache_dir" ]; then
                local dir_size=$(du -sb "$cache_dir" 2>/dev/null | cut -f1 || echo "0")
                if [ "$VERBOSE" = true ]; then
                    echo -e "  ${YELLOW}Removendo cache Windows:${NC} $cache_dir (${dir_size} bytes)"
                fi
                rm -rf "$cache_dir"/* 2>/dev/null
                if [ $? -eq 0 ]; then
                    log_success "Cache Windows removido: $cache_dir"
                else
                    log_warning "Nao foi possivel remover: $cache_dir"
                fi
            fi
        done
    fi
   
    # Linux-specific additional cleanups
    if [ "$OS" = "Linux" ]; then
        log_info "Executando limpezas Linux..." "Executando limpezas especificas para Linux..."
       
        # Clean Linux package cache directories if they exist
        local linux_cache_dirs=(
            "$HOME/.npm"
            "$HOME/.cache/yarn"
            "$HOME/.cache/npm"
            "$HOME/.nuget/packages"
            "$HOME/.local/share/NuGet"
            "/tmp/NuGetScratch"
            "/var/cache/npm"
            "/var/cache/yarn"
        )
       
        for cache_dir in "${linux_cache_dirs[@]}"; do
            if [ -d "$cache_dir" ]; then
                local dir_size=$(du -sb "$cache_dir" 2>/dev/null | cut -f1 || echo "0")
                if [ "$VERBOSE" = true ]; then
                    echo -e "  ${YELLOW}Removendo cache Linux:${NC} $cache_dir (${dir_size} bytes)"
                fi
                rm -rf "$cache_dir"/* 2>/dev/null
                if [ $? -eq 0 ]; then
                    log_success "Cache Linux removido: $cache_dir"
                else
                    log_warning "Nao foi possivel remover: $cache_dir"
                fi
            fi
        done
    fi
   
    # Mac-specific additional cleanups
    if [ "$OS" = "Mac" ]; then
        log_info "Executando limpezas Mac..." "Executando limpezas especificas para Mac..."
       
        # Clean macOS package cache directories if they exist
        local mac_cache_dirs=(
            "$HOME/.npm"
            "$HOME/Library/Caches/Yarn"
            "$HOME/Library/Caches/npm"
            "$HOME/.nuget/packages"
            "$HOME/.local/share/NuGet"
            "$HOME/Library/Caches/NuGet"
            "/tmp/NuGetScratch"
        )
       
        for cache_dir in "${mac_cache_dirs[@]}"; do
            if [ -d "$cache_dir" ]; then
                local dir_size=$(du -sb "$cache_dir" 2>/dev/null | cut -f1 || echo "0")
                if [ "$VERBOSE" = true ]; then
                    echo -e "  ${YELLOW}Removendo cache Mac:${NC} $cache_dir (${dir_size} bytes)"
                fi
                rm -rf "$cache_dir"/* 2>/dev/null
                if [ $? -eq 0 ]; then
                    log_success "Cache Mac removido: $cache_dir"
                else
                    log_warning "Nao foi possivel remover: $cache_dir"
                fi
            fi
        done
    fi
   
    # Pip cache cleanup
    if command -v pip &> /dev/null || command -v pip3 &> /dev/null; then
        local pip_cmd="pip"
        command -v pip3 &> /dev/null && pip_cmd="pip3"
        log_info "Limpando cache Pip..." "Limpando cache do Pip..."
        $pip_cmd cache purge 2>&1 | while IFS= read -r line; do
            log_detail "Pip: $line"
        done
        log_success "Cache Pip limpo" "Cache do Pip limpo"
    else
        log_warning "Pip nao encontrado" "Pip nao encontrado, pulando limpeza de cache"
    fi

    # Go cache cleanup
    if command -v go &> /dev/null; then
        log_info "Limpando cache Go..." "Limpando cache de build e modulos do Go..."
        go clean -cache 2>&1 | while IFS= read -r line; do
            log_detail "Go: $line"
        done
        go clean -modcache 2>&1 | while IFS= read -r line; do
            log_detail "Go: $line"
        done
        log_success "Cache Go limpo" "Cache do Go limpo"
    else
        log_warning "Go nao encontrado" "Go nao encontrado, pulando limpeza de cache"
    fi

    # Composer cache cleanup
    if command -v composer &> /dev/null; then
        log_info "Limpando cache Composer..." "Limpando cache do Composer..."
        composer clear-cache 2>&1 | while IFS= read -r line; do
            log_detail "Composer: $line"
        done
        log_success "Cache Composer limpo" "Cache do Composer limpo"
    else
        log_warning "Composer nao encontrado" "Composer nao encontrado, pulando limpeza de cache"
    fi

    # Gem cache cleanup
    if command -v gem &> /dev/null; then
        log_info "Limpando cache Gem..." "Limpando cache do Gem (Ruby)..."
        gem cleanup 2>&1 | while IFS= read -r line; do
            log_detail "Gem: $line"
        done
        log_success "Cache Gem limpo" "Cache do Gem limpo"
    else
        log_warning "Gem nao encontrado" "Gem nao encontrado, pulando limpeza de cache"
    fi

    # Cargo (Rust), Gradle e Maven nao possuem comando de clear cache universal:
    # remove diretamente os diretorios de cache/registry preservando toolchains instaladas
    local dev_cache_dirs=(
        "$HOME/.cargo/registry/cache"
        "$HOME/.cargo/registry/src"
        "$HOME/.cargo/git/checkouts"
        "$HOME/.gradle/caches"
        "$HOME/.m2/repository"
    )

    for cache_dir in "${dev_cache_dirs[@]}"; do
        if [ -d "$cache_dir" ]; then
            local dir_size=$(du -sb "$cache_dir" 2>/dev/null | cut -f1 || echo "0")
            if [ "$VERBOSE" = true ]; then
                echo -e "  ${YELLOW}Removendo cache:${NC} $cache_dir (${dir_size} bytes)"
            fi
            rm -rf "$cache_dir"/* 2>/dev/null
            if [ $? -eq 0 ]; then
                log_success "Cache removido: $cache_dir (${dir_size} bytes)"
            else
                log_warning "Nao foi possivel remover: $cache_dir"
            fi
        else
            log_detail "Cache nao encontrado, pulando: $cache_dir"
        fi
    done

    # Chocolatey cache cleanup (Windows)
    if command -v choco &> /dev/null; then
        log_info "Limpando cache do Chocolatey..." "Limpando cache de pacotes do Chocolatey..."
        choco cache remove --all -y 2>&1 | while IFS= read -r line; do
            log_detail "Choco: $line"
        done
        log_success "Cache Chocolatey limpo" "Cache do Chocolatey limpo"
    else
        log_warning "Chocolatey nao encontrado" "Chocolatey (choco) nao encontrado, pulando limpeza de cache"
    fi

    # Scoop cache cleanup (Windows)
    if command -v scoop &> /dev/null; then
        log_info "Limpando cache do Scoop..." "Limpando cache de pacotes do Scoop..."
        scoop cache rm '*' 2>&1 | while IFS= read -r line; do
            log_detail "Scoop: $line"
        done
        log_success "Cache Scoop limpo" "Cache do Scoop limpo"
    else
        log_warning "Scoop nao encontrado" "Scoop nao encontrado, pulando limpeza de cache"
    fi

    log_success "Limpeza de caches concluida" "Limpeza de caches de pacotes concluida com sucesso"
}

# Função para limpar Docker (containers, imagens, volumes, redes, build cache e logs)
cleanup_docker() {
    log_header "LIMPANDO DOCKER"

    if ! command -v docker &> /dev/null; then
        log_warning "Docker nao encontrado" "Docker nao encontrado, pulando limpeza"
        return
    fi

    if ! docker info &> /dev/null; then
        log_warning "Docker daemon indisponivel" "Docker instalado mas daemon nao esta rodando, pulando limpeza"
        return
    fi

    # Helper: executa docker com timeout se disponivel (sintaxe Unix), sem timeout caso contrario
    local docker_timeout=""
    if command -v timeout &> /dev/null && timeout --version &> /dev/null 2>&1; then
        docker_timeout="timeout 120s"
    fi

    log_info "Removendo containers parados..." "Removendo containers parados (docker container prune -f)..."
    $docker_timeout docker container prune -f 2>&1 | while IFS= read -r line; do
        log_detail "Docker Container: $line"
    done

    log_info "Removendo imagens nao utilizadas..." "Removendo imagens nao utilizadas (docker image prune -af)..."
    $docker_timeout docker image prune -af 2>&1 | while IFS= read -r line; do
        log_detail "Docker Image: $line"
    done

    log_info "Removendo volumes nao utilizados..." "Removendo volumes nao utilizados (docker volume prune -f)..."
    $docker_timeout docker volume prune -f 2>&1 | while IFS= read -r line; do
        log_detail "Docker Volume: $line"
    done

    log_info "Removendo redes nao utilizadas..." "Removendo redes nao utilizadas (docker network prune -f)..."
    $docker_timeout docker network prune -f 2>&1 | while IFS= read -r line; do
        log_detail "Docker Network: $line"
    done

    log_info "Limpando build cache do Docker..." "Limpando historico de build (docker builder prune -af)..."
    $docker_timeout docker builder prune -af 2>&1 | while IFS= read -r line; do
        log_detail "Docker Builder: $line"
    done

    # Trunca logs de containers em execucao (best-effort; caminho pode nao estar
    # acessivel diretamente no Windows quando o Docker Desktop usa backend WSL2/Hyper-V)
    log_info "Truncando logs de containers ativos..." "Truncando arquivos de log de containers em execucao..."
    docker ps -q 2>/dev/null | while IFS= read -r container_id; do
        local log_path=$(docker inspect --format='{{.LogPath}}' "$container_id" 2>/dev/null)
        if [ -n "$log_path" ] && [ -f "$log_path" ]; then
            : > "$log_path" 2>/dev/null && log_detail "Log truncado: $container_id -> $log_path"
        fi
    done

    # Limpeza final comprehensiva: sistema + volumes nao utilizados
    log_info "Limpeza final do sistema Docker..." "Executando docker system prune -a --volumes -f..."
    $docker_timeout docker system prune -a --volumes -f 2>&1 | while IFS= read -r line; do
        log_detail "Docker System: $line"
    done

    log_success "Limpeza do Docker concluida" "Limpeza do Docker (containers, imagens, volumes, redes, build cache, logs, system prune) concluida"
}

# Função para limpar arquivos temporários do sistema
cleanup_temp_files() {
    log_header "LIMPANDO ARQUIVOS TEMPORARIOS"

    local temp_dirs=()

    case "$OS" in
        Windows)
            temp_dirs+=(
                "$TEMP"
                "$TMP"
                "$LOCALAPPDATA/Temp"
                "$LOCALAPPDATA/Microsoft/Windows/INetCache"
                "$LOCALAPPDATA/Microsoft/Windows/Explorer"
                "$LOCALAPPDATA/CrashDumps"
                "$LOCALAPPDATA/Microsoft/Windows/WER"
            )
            ;;
        Linux)
            temp_dirs+=("/tmp" "/var/tmp")
            ;;
        Mac)
            temp_dirs+=("/tmp" "$TMPDIR")
            ;;
    esac

    for dir in "${temp_dirs[@]}"; do
        if [ -n "$dir" ] && [ -d "$dir" ]; then
            local dir_size=$(du -sb "$dir" 2>/dev/null | cut -f1 || echo "0")
            log_info "Limpando temporarios: $dir..." "Limpando diretorio temporario: $dir (${dir_size} bytes)"
            if [ "$VERBOSE" = true ]; then
                echo -e "  ${YELLOW}Limpando:${NC} $dir (${dir_size} bytes)"
            fi
            find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null
            log_success "Temporarios limpos: $dir" "Diretorio temporario limpo: $dir (${dir_size} bytes)"
        else
            log_detail "Diretorio temporario nao encontrado ou nao aplicavel: $dir"
        fi
    done

    log_success "Limpeza de temporarios concluida" "Limpeza de arquivos temporarios do sistema concluida"
}

# Função para limpar core dumps e crash reports
cleanup_crash_reports() {
    log_header "LIMPANDO CRASH REPORTS"

    case "$OS" in
        Windows)
            local wer_dirs=(
                "$LOCALAPPDATA/Microsoft/Windows/WER/ReportQueue"
                "$LOCALAPPDATA/Microsoft/Windows/WER/ReportArchive"
                "$LOCALAPPDATA/CrashDumps"
            )
            for dir in "${wer_dirs[@]}"; do
                if [ -d "$dir" ]; then
                    local dir_size=$(du -sb "$dir" 2>/dev/null | cut -f1 || echo "0")
                    if [ "$VERBOSE" = true ]; then
                        echo -e "  ${YELLOW}Removendo:${NC} $dir (${dir_size} bytes)"
                    fi
                    rm -rf "$dir"/* 2>/dev/null
                    log_success "Crash reports removidos: $dir (${dir_size} bytes)"
                else
                    log_detail "Diretorio de crash report nao encontrado: $dir"
                fi
            done

            # Minidumps e memory.dmp do Windows (requer permissao de administrador)
            local minidump_dir="$WINDIR/Minidump"
            if [ -n "$WINDIR" ] && [ -d "$minidump_dir" ]; then
                local dump_size=$(du -sb "$minidump_dir" 2>/dev/null | cut -f1 || echo "0")
                rm -rf "$minidump_dir"/* 2>/dev/null
                log_success "Minidumps removidos (${dump_size} bytes)" "Minidumps removidos de $minidump_dir (${dump_size} bytes)"
            fi

            local memory_dump="$WINDIR/memory.dmp"
            if [ -n "$WINDIR" ] && [ -f "$memory_dump" ]; then
                local dump_size=$(du -sb "$memory_dump" 2>/dev/null | cut -f1 || echo "0")
                rm -f "$memory_dump" 2>/dev/null
                log_success "memory.dmp removido (${dump_size} bytes)" "Arquivo $memory_dump removido (${dump_size} bytes)"
            fi
            ;;
        Linux)
            if [ -d "/var/crash" ]; then
                rm -rf /var/crash/* 2>/dev/null
                log_success "Crash reports removidos: /var/crash"
            fi
            if [ -d "/var/lib/systemd/coredump" ]; then
                find /var/lib/systemd/coredump -type f -delete 2>/dev/null
                log_success "Coredumps do systemd removidos"
            fi
            ;;
        Mac)
            local mac_crash_dir="$HOME/Library/Logs/DiagnosticReports"
            if [ -d "$mac_crash_dir" ]; then
                rm -rf "$mac_crash_dir"/* 2>/dev/null
                log_success "Crash reports removidos: $mac_crash_dir"
            fi
            ;;
    esac

    log_success "Limpeza de crash reports concluida" "Limpeza de core dumps e crash reports concluida"
}

# Função para esvaziar a lixeira (Windows)
cleanup_recycle_bin() {
    if [ "$OS" != "Windows" ]; then
        return
    fi

    log_header "ESVAZIANDO LIXEIRA"

    if command -v powershell.exe &> /dev/null; then
        log_info "Esvaziando lixeira..." "Esvaziando lixeira via PowerShell (Clear-RecycleBin)..."
        powershell.exe -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" 2>&1 | while IFS= read -r line; do
            log_detail "RecycleBin: $line"
        done
        log_success "Lixeira esvaziada" "Lixeira esvaziada com sucesso"
    else
        log_warning "PowerShell nao encontrado" "powershell.exe nao encontrado, pulando esvaziamento da lixeira"
    fi
}

# Função para identificar (sem remover) arquivos grandes: ISOs, imagens de VM e backups
identify_large_files() {
    log_header "IDENTIFICANDO ARQUIVOS GRANDES"

    local patterns=("*.iso" "*.img" "*.vmdk" "*.vdi" "*.ova" "*.vhd" "*.vhdx" "*.bak")
    local found_any=false

    for pattern in "${patterns[@]}"; do
        local large_files=$(find "$ROOT" -type f -iname "$pattern" -size +100M 2>/dev/null)
        if [ -n "$large_files" ]; then
            found_any=true
            local count=$(echo "$large_files" | wc -l)
            log_warning "Encontrados $count arquivo(s) grande(s) ($pattern)" "Arquivos grandes encontrados com padrao $pattern: $count"
            echo "$large_files" | while IFS= read -r file; do
                local fsize=$(du -sh "$file" 2>/dev/null | cut -f1 || echo "?")
                echo -e "  ${YELLOW}$file${NC} ($fsize)"
                log_detail "Arquivo grande: $file ($fsize)"
            done
        fi
    done

    if [ "$found_any" = false ]; then
        log_info "Nenhum arquivo grande encontrado" "Nenhum arquivo grande (ISO/IMG/VMDK/backup) encontrado em $ROOT"
    fi
}

# Função para varrer pastas recursivamente
scan_folder() {
    local DIR="$1"
    local BASENAME=$(basename "$DIR")
   
    # Ignora pastas que não vale varrer
    case "$BASENAME" in
        .git|node_modules|bin|obj|.vs|.idea|dist|build|target|out)
        log_detail "Ignorando pasta: $BASENAME"
        return
        ;;
    esac
   
    # Achou repo -> limpa e continua varrendo outras pastas no mesmo nível
    if [[ -d "${DIR}/.git" ]]; then
        cleanup_repo "$DIR"
        # Não faz return aqui para continuar varrendo outras pastas
    fi
   
    # Percore subpastas (se não for repo ou mesmo sendo repo)
    log_detail "Explorando subpastas de: $BASENAME"
   
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
   
    # Registra espaço em disco antes da limpeza
    log_header "ESPAÇO EM DISCO - ANTES DA LIMPEZA"
    show_disk_space "ANTES"
    DISK_SPACE_BEFORE=$(log_disk_space "ANTES")
    echo
   
    # Executa limpeza de caches, Docker, crash reports, lixeira e temporarios antes de varrer os repositórios
    if [ "$DRY_RUN" = false ]; then
        cleanup_package_caches
        cleanup_docker
        cleanup_crash_reports
        cleanup_recycle_bin
        cleanup_temp_files
    else
        log_info "MODO DRY-RUN: Limpeza de caches, Docker, crash reports, lixeira e temporarios seria executada antes do scan dos repositórios"
    fi
   
    # Inicia o scan
    log_info "Iniciando scan de repositorios Git em: $ROOT"
    scan_folder "$ROOT"
   
    # Identifica arquivos grandes (apenas informativo, nao remove nada)
    identify_large_files
   
    # Registra espaço em disco depois da limpeza
    echo
    log_header "ESPAÇO EM DISCO - DEPOIS DA LIMPEZA"
    show_disk_space "DEPOIS"
    DISK_SPACE_AFTER=$(log_disk_space "DEPOIS")
   
    # Calcula e exibe a diferença (espaço recuperado = depois - antes)
    local space_recovered_kb=$((DISK_SPACE_AFTER - DISK_SPACE_BEFORE))
    local space_recovered_formatted=$(format_disk_space "$space_recovered_kb")
   
    if [ "$space_recovered_kb" -gt 0 ]; then
        local space_recovered_mb=$((space_recovered_kb / 1024))
        local space_recovered_gb=$((space_recovered_mb / 1024))
       
        log_success "Espaço recuperado: $space_recovered_formatted ($space_recovered_kb KB)"
       
        if [ "$VERBOSE" = true ]; then
            echo -e "${GREEN}Espaço recuperado: $space_recovered_formatted ($space_recovered_kb KB)${NC}"
            if [ "$space_recovered_gb" -gt 0 ]; then
                echo -e "${GREEN}≈ $space_recovered_gb GB recuperados${NC}"
            elif [ "$space_recovered_mb" -gt 0 ]; then
                echo -e "${GREEN}≈ $space_recovered_mb MB recuperados${NC}"
            fi
        fi
    elif [ "$space_recovered_kb" -lt 0 ]; then
        local space_used_kb=$((-space_recovered_kb))
        local space_used_formatted=$(format_disk_space "$space_used_kb")
        log_warning "Espaço em disco aumentou em: $space_used_formatted (pode haver atividade simultânea)"
        if [ "$VERBOSE" = true ]; then
            echo -e "${YELLOW}Espaço em disco aumentou em: $space_used_formatted (pode haver atividade simultânea)${NC}"
        fi
    else
        log_info "Nenhuma mudança significativa no espaço em disco"
        if [ "$VERBOSE" = true ]; then
            echo -e "${BLUE}Nenhuma mudança significativa no espaço em disco${NC}"
        fi
    fi
   
    # Resumo final
    echo
    if [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}==================================================================${NC}"
        echo -e "${GREEN}Scan concluido!${NC}"
        echo -e "${GREEN}Log detalhado salvo em: ${LOG}${NC}"
        echo -e "${GREEN}Espaço recuperado: $space_recovered_formatted${NC}"
        echo -e "${GREEN}==================================================================${NC}"
    else
        echo "Scan concluido. Log salvo em: ${LOG}"
        echo "Espaço recuperado: $space_recovered_formatted"
    fi
}

# Execução
main "$@"
