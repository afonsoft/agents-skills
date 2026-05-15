#!/bin/bash

# clear-up.sh - Script de limpeza de disco para Ubuntu/Linux
# Remove logs, arquivos temporários e libera espaço em disco de forma segura
#
# Uso:
#   sudo ./clear-up.sh           # Execução normal
#   sudo ./clear-up.sh --dry-run # Simulação (sem remover)
#   sudo ./clear-up.sh --verbose  # Modo detalhado
#   sudo ./clear-up.sh --help    # Ajuda

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variáveis de controle
DRY_RUN=false
VERBOSE=false
INTERACTIVE=true
INSTALL_BLEACHBIT=false
TOTAL_FREED=0

# Funções de log
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

log_verbose() {
    [ "$VERBOSE" = true ] && echo -e "${CYAN}[VERBOSE]${NC} $1"
}

# Função de ajuda
show_help() {
    echo
    echo -e "${CYAN}clear-up.sh - Script de Limpeza de Disco${NC}"
    echo
    echo -e "${YELLOW}Uso:${NC}"
    echo "  sudo ./clear-up.sh [opcoes]"
    echo
    echo -e "${YELLOW}Opcoes:${NC}"
    echo "  --help, -h     Exibe esta mensagem de ajuda"
    echo "  --dry-run, -d  Simula a limpeza sem remover arquivos"
    echo "  --verbose, -v  Modo detalhado"
    echo "  --force, -f    Modo não-interativo (pula confirmacoes)"
    echo "  --bleachbit, -b Instala e executa BleachBit para limpeza profunda"
    echo
    echo -e "${YELLOW}O que sera limpo:${NC}"
    echo "  - Logs do sistema (*.log, log*)"
    echo "  - Cache de pacotes (apt)"
    echo "  - Arquivos temporários"
    echo "  - Cache de aplicativos"
    echo "  - Kernels antigos"
    echo "  - Docker (se instalado)"
    echo "  - Snap packages antigos"
    echo "  - aaPanel (se instalado)"
    echo "  - Journal do systemd"
    echo "  - Caches de desenvolvimento (pip, npm, yarn, cargo, go, gradle, maven, composer, nuget, gem)"
    echo "  - Flatpak (runtimes não utilizados)"
    echo "  - Core dumps e crash reports"
    echo "  - Pacotes órfãos e configurações residuais"
    echo "  - Locales não utilizados e cache de fontes"
    echo "  - Swap e cache de memória do kernel"
    echo "  - Filas de email (Postfix/Exim) e logs de mail"
    echo "  - Identificação de arquivos grandes (ISO, IMG, VMDK)"
    echo "  - Arquivos antigos do sistema (.dpkg-old, .bak, logs rotacionados)"
    echo "  - Caches do sistema (ldconfig, APT lists, PackageKit, ícones)"
    echo "  - BleachBit para limpeza profunda (com --bleachbit)"
    echo
    echo -e "${YELLOW}AVISO:${NC} Execute como root/sudo para acesso completo"
    echo
}

# Verifica se está rodando como root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Este script precisa ser executado como root/sudo"
        echo "Use: sudo ./clear-up.sh"
        exit 1
    fi
}

# Função para calcular tamanho de arquivo/diretório
get_size() {
    local path="$1"
    if [ -e "$path" ]; then
        du -sh "$path" 2>/dev/null | cut -f1 || echo "0"
    else
        echo "0"
    fi
}

# Função para remover arquivos com contagem
remove_files() {
    local pattern="$1"
    local description="$2"
    local path="${3:-.}"
    
    log_info "Limpando: $description"
    
    local files_found=0
    local size_before=0
    local size_after=0
    
    if [ "$DRY_RUN" = true ]; then
        files_found=$(find "$path" -name "$pattern" -type f 2>/dev/null | wc -l)
        if [ "$files_found" -gt 0 ]; then
            size_before=$(find "$path" -name "$pattern" -type f -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1)
            log_warning "DRY RUN: $files_found arquivos ($size_before) seriam removidos"
            echo "  Padrão: $pattern"
            find "$path" -name "$pattern" -type f 2>/dev/null | head -5 | sed 's/^/    /'
            [ "$files_found" -gt 5 ] && echo "    ... e $((files_found - 5)) mais"
        else
            log_verbose "Nenhum arquivo encontrado para: $pattern"
        fi
    else
        # Calcular tamanho antes
        size_before=$(find "$path" -name "$pattern" -type f -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 2>/dev/null || echo "0")
        
        # Remover arquivos
        files_found=$(find "$path" -name "$pattern" -type f -delete -print 2>/dev/null | wc -l)
        
        if [ "$files_found" -gt 0 ]; then
            log_success "Removidos $files_found arquivos ($size_before)"
            TOTAL_FREED=$((TOTAL_FREED + 1))
        else
            log_verbose "Nenhum arquivo encontrado para: $pattern"
        fi
    fi
}

# Função para remover diretórios
remove_directory() {
    local dir="$1"
    local description="$2"
    
    if [ ! -d "$dir" ]; then
        log_verbose "Diretório não encontrado: $dir"
        return
    fi
    
    local size=$(get_size "$dir")
    log_info "Limpando: $description ($size)"
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Diretório $dir ($size) seria removido"
    else
        if [ "$INTERACTIVE" = true ]; then
            echo -n "Remover $dir? (y/N): "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                rm -rf "$dir" 2>/dev/null || log_error "Erro ao remover $dir"
                log_success "Removido: $dir ($size)"
                TOTAL_FREED=$((TOTAL_FREED + 1))
            else
                log_info "Pulando: $dir"
            fi
        else
            rm -rf "$dir" 2>/dev/null || log_error "Erro ao remover $dir"
            log_success "Removido: $dir ($size)"
            TOTAL_FREED=$((TOTAL_FREED + 1))
        fi
    fi
}

# Limpeza de logs do sistema
clean_system_logs() {
    log_info "=== Limpando Logs do Sistema ==="
    
    # Logs em /var/log
    remove_files "*.log" "Logs do sistema (*.log)" "/var/log"
    remove_files "log*" "Logs com prefixo 'log'" "/var/log"
    remove_files "*.log.*" "Logs rotacionados" "/var/log"
    
    # Logs específicos
    remove_files "syslog*" "Logs do sistema" "/var/log"
    remove_files "auth.log*" "Logs de autenticação" "/var/log"
    remove_files "kern.log*" "Logs do kernel" "/var/log"
    remove_files "dpkg.log*" "Logs do dpkg" "/var/log"
    remove_files "apt.log*" "Logs do apt" "/var/log"
    
    # Limpar conteúdo de logs ativos (manter arquivos, limpar conteúdo)
    if [ "$DRY_RUN" = false ]; then
        for log_file in /var/log/syslog /var/log/kern.log /var/log/auth.log; do
            if [ -f "$log_file" ]; then
                local size=$(get_size "$log_file")
                log_info "Limpando conteúdo de: $log_file ($size)"
                > "$log_file" 2>/dev/null || log_warning "Não foi possível limpar $log_file"
            fi
        done
    fi
}

# Limpeza de cache do APT
clean_apt_cache() {
    log_info "=== Limpando Cache do APT ==="
    
    if [ -d "/var/cache/apt" ]; then
        local size=$(get_size "/var/cache/apt")
        log_info "Cache do APT: $size"
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Cache do APT ($size) seria limpo"
        else
            apt-get clean 2>/dev/null || log_error "Erro ao limpar cache do apt"
            apt-get autoclean 2>/dev/null || log_warning "Erro no autoclean do apt"
            apt-get autoremove -y 2>/dev/null || log_warning "Erro no autoremove do apt"
            log_success "Cache do APT limpo"
        fi
    fi
}

# Limpeza de arquivos temporários
clean_temp_files() {
    log_info "=== Limpando Arquivos Temporários ==="
    
    # /tmp
    if [ -d "/tmp" ]; then
        remove_directory "/tmp/*" "Arquivos temporários (/tmp)"
    fi
    
    # /var/tmp
    if [ -d "/var/tmp" ]; then
        remove_directory "/var/tmp/*" "Arquivos temporários do sistema (/var/tmp)"
    fi
    
    # Temp do usuário
    remove_files "*.tmp" "Arquivos temporários (*.tmp)" "/home"
    remove_files "*.temp" "Arquivos temporários (*.temp)" "/home"
    remove_files "~*" "Arquivos de backup do editor" "/home"
    remove_files "#*#" "Arquivos de backup do Emacs" "/home"
    remove_files ".#*" "Arquivos de lock do Emacs" "/home"
    
    # Cache de thumbnails
    remove_directory "/home/*/.cache/thumbnails/*" "Cache de thumbnails"
}

# Limpeza de cache de aplicativos
clean_application_cache() {
    log_info "=== Limpando Cache de Aplicativos ==="
    
    # Cache geral dos usuários
    remove_directory "/home/*/.cache/*" "Cache de aplicativos dos usuários"
    
    # Cache específicos comuns
    remove_directory "/home/*/.mozilla/firefox/*/cache2" "Cache do Firefox"
    remove_directory "/home/*/.cache/google-chrome/*" "Cache do Chrome"
    remove_directory "/home/*/.cache/mozilla/firefox/*" "Cache do Mozilla"
    remove_directory "/home/*/.local/share/Trash/files/*" "Lixeira dos usuários"
    
    # Cache do sistema
    remove_directory "/var/cache/man/*" "Cache de páginas de manual"
    remove_directory "/usr/share/man/man*/*.gz" "Man pages comprimidas"
}

# Limpeza de kernels antigos
clean_old_kernels() {
    log_info "=== Limpando Kernels Antigos ==="
    
    if command -v apt-get >/dev/null 2>&1; then
        local current_kernel=$(uname -r | sed 's/-.*//g')
        local old_kernels=$(dpkg -l 'linux-*' | sed '/^ii/!d;/'"$current_kernel"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d')
        
        if [ -n "$old_kernels" ]; then
            log_info "Kernels antigos encontrados:"
            echo "$old_kernels" | head -5
            
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: Kernels antigos seriam removidos"
            else
                if [ "$INTERACTIVE" = true ]; then
                    echo -n "Remover kernels antigos? (y/N): "
                    read -r response
                    if [[ "$response" =~ ^[Yy]$ ]]; then
                        echo "$old_kernels" | xargs apt-get purge -y 2>/dev/null || log_error "Erro ao remover kernels"
                        log_success "Kernels antigos removidos"
                    else
                        log_info "Pulando remoção de kernels"
                    fi
                else
                    echo "$old_kernels" | xargs apt-get purge -y 2>/dev/null || log_error "Erro ao remover kernels"
                    log_success "Kernels antigos removidos"
                fi
            fi
        else
            log_verbose "Nenhum kernel antigo encontrado"
        fi
    fi
}

# Limpeza do Docker
clean_docker() {
    if command -v docker >/dev/null 2>&1; then
        log_info "=== Limpando Docker ==="
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Docker seria limpo"
        else
            # Remover containers parados
            local stopped_containers=$(docker ps -aq --filter "status=exited" 2>/dev/null || echo "")
            if [ -n "$stopped_containers" ]; then
                docker rm $stopped_containers 2>/dev/null || log_warning "Erro ao remover containers parados"
                log_success "Containers parados removidos"
            fi
            
            # Remover imagens não utilizadas
            docker image prune -f 2>/dev/null || log_warning "Erro ao limpar imagens Docker"
            
            # Remover volumes não utilizados
            docker volume prune -f 2>/dev/null || log_warning "Erro ao limpar volumes Docker"
            
            # Remover redes não utilizadas
            docker network prune -f 2>/dev/null || log_warning "Erro ao limpar redes Docker"
            
            # Limpar histórico de build do Docker
            log_info "Limpando histórico de build do Docker..."
            local build_history_size=$(docker builder du 2>/dev/null | grep "Total" | awk '{print $2}' || echo "0")
            if [ "$build_history_size" != "0" ]; then
                log_info "Tamanho do build cache: $build_history_size"
                docker builder prune -af 2>/dev/null || log_warning "Erro ao limpar build cache do Docker"
                log_success "Histórico de build do Docker limpo"
            else
                log_verbose "Nenhum build cache encontrado"
            fi
            
            # Limpar sistema completo
            docker system prune -af 2>/dev/null || log_warning "Erro na limpeza completa do Docker"
            
            log_success "Docker limpo"
        fi
    else
        log_verbose "Docker não encontrado"
    fi
}

# Limpeza do Snap
clean_snap() {
    if command -v snap >/dev/null 2>&1; then
        log_info "=== Limpando Snap Packages ==="
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Snap packages antigos seriam removidos"
        else
            # Remover versões antigas de snap packages
            snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
                if [ -n "$snapname" ] && [ -n "$revision" ]; then
                    snap remove "$snapname" --revision="$revision" 2>/dev/null || log_verbose "Erro ao remover $snapname revision $revision"
                fi
            done
            log_success "Snap packages antigos removidos"
        fi
    else
        log_verbose "Snap não encontrado"
    fi
}

# Limpeza do aaPanel
clean_aapanel() {
    if [ -d "/www/server/panel" ]; then
        log_info "=== Limpando aaPanel ==="
        
        # 1. Limpar logs do painel
        log_info "Limpando logs do aaPanel..."
        local panel_logs=(
            "/www/server/panel/logs/error.log"
            "/www/server/panel/logs/request.log"
            "/www/server/panel/logs/access.log"
            "/www/server/panel/logs/panel.log"
        )
        
        for log_file in "${panel_logs[@]}"; do
            if [ -f "$log_file" ]; then
                local size=$(get_size "$log_file")
                log_info "Limpando log do painel: $(basename "$log_file") ($size)"
                
                if [ "$DRY_RUN" = true ]; then
                    log_warning "DRY RUN: Log $log_file ($size) seria limpo"
                else
                    > "$log_file" 2>/dev/null || log_warning "Não foi possível limpar $log_file"
                    log_success "Log limpo: $(basename "$log_file")"
                fi
            fi
        done
        
        # 2. Limpar logs de sites individuais
        if [ -d "/www/wwwlogs" ]; then
            local site_logs_size=$(get_size "/www/wwwlogs")
            log_info "Logs de sites: $site_logs_size"
            
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: Logs de sites em /www/wwwlogs seriam limpos"
            else
                # Limpar logs de acesso e erro dos sites
                find "/www/wwwlogs" -name "*.log" -type f -exec truncate -s 0 {} \; 2>/dev/null || log_warning "Erro ao limpar logs de sites"
                log_success "Logs de sites limpos"
            fi
        fi
        
        # 3. Limpar logs do PostgreSQL aaPanel
        log_info "Limpando logs do PostgreSQL aaPanel..."
        local pgsql_log_dirs=(
            "/www/server/pgsql/data"
            "/www/server/pgsql/logs"
            "/var/lib/pgsql/data"
            "/var/log/pgsql"
            "/usr/local/pgsql/data"
            "/usr/local/pgsql/logs"
        )
        
        for pgsql_log_dir in "${pgsql_log_dirs[@]}"; do
            if [ -d "$pgsql_log_dir" ]; then
                local pgsql_logs=$(find "$pgsql_log_dir" -name "*.log" -type f 2>/dev/null || true)
                if [ -n "$pgsql_logs" ]; then
                    local pgsql_count=$(echo "$pgsql_logs" | wc -l)
                    local pgsql_size=$(echo "$pgsql_logs" | xargs du -ch 2>/dev/null | tail -1 | cut -f1 || echo "0")
                    
                    log_info "Logs PostgreSQL encontrados: $pgsql_count arquivos ($pgsql_size) em $pgsql_log_dir"
                    
                    if [ "$DRY_RUN" = true ]; then
                        log_warning "DRY RUN: Logs PostgreSQL ($pgsql_size) seriam limpos"
                        echo "$pgsql_logs" | head -3 | sed 's/^/  /'
                        [ "$pgsql_count" -gt 3 ] && echo "  ... e $((pgsql_count - 3)) mais"
                    else
                        echo "$pgsql_logs" | xargs truncate -s 0 2>/dev/null || log_warning "Erro ao limpar logs PostgreSQL"
                        log_success "Logs PostgreSQL limpos: $pgsql_count arquivos ($pgsql_size)"
                    fi
                fi
            fi
        done
        
        # 3. Limpar Binary Logs do MySQL/MariaDB
        local mysql_dirs=(
            "/www/server/mysql"
            "/www/server/mariadb"
            "/var/lib/mysql"
            "/usr/local/mysql"
        )
        
        for mysql_dir in "${mysql_dirs[@]}"; do
            if [ -d "$mysql_dir" ]; then
                log_info "Verificando MySQL/MariaDB em: $mysql_dir"
                
                # Limpar binary logs
                local binary_logs=$(find "$mysql_dir" -name "mysql-bin.*" -type f 2>/dev/null || true)
                if [ -n "$binary_logs" ]; then
                    local binary_count=$(echo "$binary_logs" | wc -l)
                    local binary_size=$(echo "$binary_logs" | xargs du -ch 2>/dev/null | tail -1 | cut -f1 || echo "0")
                    
                    log_info "Binary logs encontrados: $binary_count arquivos ($binary_size)"
                    
                    if [ "$DRY_RUN" = true ]; then
                        log_warning "DRY RUN: Binary logs ($binary_size) seriam removidos"
                        echo "$binary_logs" | head -3 | sed 's/^/  /'
                        [ "$binary_count" -gt 3 ] && echo "  ... e $((binary_count - 3)) mais"
                    else
                        echo "$binary_logs" | xargs rm -f 2>/dev/null || log_warning "Erro ao remover binary logs"
                        log_success "Binary logs removidos: $binary_count arquivos ($binary_size)"
                    fi
                fi
                
                # Limpar relay logs
                local relay_logs=$(find "$mysql_dir" -name "relay-bin.*" -type f 2>/dev/null || true)
                if [ -n "$relay_logs" ]; then
                    if [ "$DRY_RUN" = false ]; then
                        echo "$relay_logs" | xargs rm -f 2>/dev/null || log_warning "Erro ao remover relay logs"
                        log_success "Relay logs removidos"
                    fi
                fi
                
                # Limpar logs de erro do MySQL
                local mysql_error_logs=(
                    "$mysql_dir/data/mysql-error.log"
                    "$mysql_dir/logs/error.log"
                    "$mysql_dir/var/mysql.err"
                )
                
                for error_log in "${mysql_error_logs[@]}"; do
                    if [ -f "$error_log" ]; then
                        local size=$(get_size "$error_log")
                        log_info "Limpando log de erro MySQL: $(basename "$error_log") ($size)"
                        
                        if [ "$DRY_RUN" = false ]; then
                            > "$error_log" 2>/dev/null || log_warning "Não foi possível limpar $error_log"
                        fi
                    fi
                done
                
                break
            fi
        done
        
        # 4. Remover backups antigos
        local backup_dirs=(
            "/www/backup"
            "/www/server/panel/backup"
            "/backup"
        )
        
        for backup_dir in "${backup_dirs[@]}"; do
            if [ -d "$backup_dir" ]; then
                log_info "Verificando backups em: $backup_dir"
                
                # Encontrar backups com mais de 7 dias
                local old_backups=$(find "$backup_dir" -type f -mtime +7 2>/dev/null || true)
                if [ -n "$old_backups" ]; then
                    local backup_count=$(echo "$old_backups" | wc -l)
                    local backup_size=$(echo "$old_backups" | xargs du -ch 2>/dev/null | tail -1 | cut -f1 || echo "0")
                    
                    log_info "Backups antigos encontrados: $backup_count arquivos ($backup_size)"
                    
                    if [ "$DRY_RUN" = true ]; then
                        log_warning "DRY RUN: Backups antigos ($backup_size) seriam removidos"
                        echo "$old_backups" | head -3 | sed 's/^/  /'
                        [ "$backup_count" -gt 3 ] && echo "  ... e $((backup_count - 3)) mais"
                    else
                        if [ "$INTERACTIVE" = true ]; then
                            echo -n "Remover $backup_count backups antigos ($backup_size)? (y/N): "
                            read -r response
                            if [[ "$response" =~ ^[Yy]$ ]]; then
                                echo "$old_backups" | xargs rm -f 2>/dev/null || log_warning "Erro ao remover backups antigos"
                                log_success "Backups antigos removidos: $backup_count arquivos ($backup_size)"
                            else
                                log_info "Pulando remoção de backups antigos"
                            fi
                        else
                            echo "$old_backups" | xargs rm -f 2>/dev/null || log_warning "Erro ao remover backups antigos"
                            log_success "Backups antigos removidos: $backup_count arquivos ($backup_size)"
                        fi
                    fi
                else
                    log_verbose "Nenhum backup antigo encontrado em $backup_dir"
                fi
            fi
        done
        
        # 5. Limpar lixeira do aaPanel
        local trash_dirs=(
            "/www/server/panel/recycle_bin"
            "/www/recycle_bin"
            "/.local/share/Trash/files"
        )
        
        for trash_dir in "${trash_dirs[@]}"; do
            if [ -d "$trash_dir" ]; then
                local trash_size=$(get_size "$trash_dir")
                log_info "Lixeira encontrada: $trash_dir ($trash_size)"
                
                if [ "$DRY_RUN" = true ]; then
                    log_warning "DRY RUN: Lixeira $trash_dir ($trash_size) seria esvaziada"
                else
                    rm -rf "$trash_dir"/* 2>/dev/null || log_warning "Erro ao esvaziar lixeira $trash_dir"
                    log_success "Lixeira esvaziada: $trash_dir"
                fi
            fi
        done
        
        # 6. Identificar maiores consumidores de espaço
        log_info "Analisando maiores consumidores de espaço em /www..."
        if [ -d "/www" ]; then
            echo "Top 10 diretórios que mais consomem espaço em /www:"
            du -h /www --max-depth=2 2>/dev/null | sort -hr | head -n 10 | while read -r line; do
                echo "  $line"
            done
        fi
        
        # 7. Limpar logs do Nginx
        log_info "Limpando logs do Nginx..."
        local nginx_log_dirs=(
            "/www/server/nginx/logs"
            "/var/log/nginx"
            "/usr/local/nginx/logs"
        )
        
        for nginx_log_dir in "${nginx_log_dirs[@]}"; do
            if [ -d "$nginx_log_dir" ]; then
                local nginx_logs=$(find "$nginx_log_dir" -name "*.log" -type f 2>/dev/null || true)
                if [ -n "$nginx_logs" ]; then
                    local nginx_count=$(echo "$nginx_logs" | wc -l)
                    local nginx_size=$(echo "$nginx_logs" | xargs du -ch 2>/dev/null | tail -1 | cut -f1 || echo "0")
                    
                    log_info "Logs Nginx encontrados: $nginx_count arquivos ($nginx_size)"
                    
                    if [ "$DRY_RUN" = true ]; then
                        log_warning "DRY RUN: Logs Nginx ($nginx_size) seriam limpos"
                        echo "$nginx_logs" | head -3 | sed 's/^/  /'
                        [ "$nginx_count" -gt 3 ] && echo "  ... e $((nginx_count - 3)) mais"
                    else
                        echo "$nginx_logs" | xargs truncate -s 0 2>/dev/null || log_warning "Erro ao limpar logs Nginx"
                        log_success "Logs Nginx limpos: $nginx_count arquivos ($nginx_size)"
                    fi
                fi
            fi
        done
        
        # 8. Limpar cache do Nginx/Apache
        local web_cache_dirs=(
            "/www/server/nginx/proxy_temp"
            "/www/server/nginx/fastcgi_temp"
            "/www/server/nginx/uwsgi_temp"
            "/www/server/nginx/scgi_temp"
            "/www/server/nginx/src"
            "/www/server/apache2/cache"
            "/var/cache/nginx"
            "/var/cache/apache2"
        )
        
        for cache_dir in "${web_cache_dirs[@]}"; do
            if [ -d "$cache_dir" ]; then
                local cache_size=$(get_size "$cache_dir")
                log_info "Cache web encontrado: $cache_dir ($cache_size)"
                
                if [ "$DRY_RUN" = true ]; then
                    log_warning "DRY RUN: Cache web $cache_dir ($cache_size) seria limpo"
                else
                    rm -rf "$cache_dir"/* 2>/dev/null || log_warning "Erro ao limpar cache $cache_dir"
                    log_success "Cache web limpo: $(basename "$cache_dir")"
                fi
            fi
        done
        
        # 9. Limpar sessões PHP
        log_info "Limpando sessões PHP..."
        local session_dirs=(
            "/tmp"
            "/var/tmp"
            "/www/server/php/tmp"
            "/var/lib/php/sessions"
            "/var/lib/php5/sessions"
            "/var/lib/php7/sessions"
            "/var/lib/php8/sessions"
        )
        
        for session_dir in "${session_dirs[@]}"; do
            if [ -d "$session_dir" ]; then
                local php_sessions=$(find "$session_dir" -name "sess_*" -type f 2>/dev/null || true)
                if [ -n "$php_sessions" ]; then
                    local session_count=$(echo "$php_sessions" | wc -l)
                    local session_size=$(echo "$php_sessions" | xargs du -ch 2>/dev/null | tail -1 | cut -f1 || echo "0")
                    
                    log_info "Sessões PHP encontradas: $session_count arquivos ($session_size) em $session_dir"
                    
                    if [ "$DRY_RUN" = true ]; then
                        log_warning "DRY RUN: Sessões PHP ($session_size) seriam removidas"
                        echo "$php_sessions" | head -3 | sed 's/^/  /'
                        [ "$session_count" -gt 3 ] && echo "  ... e $((session_count - 3)) mais"
                    else
                        echo "$php_sessions" | xargs rm -f 2>/dev/null || log_warning "Erro ao remover sessões PHP"
                        log_success "Sessões PHP removidas: $session_count arquivos ($session_size)"
                    fi
                fi
            fi
        done
        
        # 10. Limpar logs de PHP
        local php_log_dirs=(
            "/www/server/php/*/var/log"
            "/var/log/php"
            "/usr/local/php*/var/log"
        )
        
        for php_log_dir in "${php_log_dirs[@]}"; do
            # Expandir wildcard
            for expanded_dir in $php_log_dir; do
                if [ -d "$expanded_dir" ]; then
                    local php_logs=$(find "$expanded_dir" -name "*.log" -type f 2>/dev/null || true)
                    if [ -n "$php_logs" ]; then
                        log_info "Limpando logs PHP em: $expanded_dir"
                        
                        if [ "$DRY_RUN" = false ]; then
                            echo "$php_logs" | xargs truncate -s 0 2>/dev/null || log_warning "Erro ao limpar logs PHP"
                            log_success "Logs PHP limpos"
                        fi
                    fi
                fi
            done
        done
        
        # 11. Limpar arquivos de instalação do painel
        log_info "Limpando arquivos de instalação do painel..."
        local panel_install_dirs=(
            "/www/server/panel/install"
        )
        
        for install_dir in "${panel_install_dirs[@]}"; do
            if [ -d "$install_dir" ]; then
                local install_files=$(find "$install_dir" -name "*.rpm" -o -name "*.zip" -o -name "*.tar.gz" 2>/dev/null || true)
                if [ -n "$install_files" ]; then
                    local install_count=$(echo "$install_files" | wc -l)
                    local install_size=$(echo "$install_files" | xargs du -ch 2>/dev/null | tail -1 | cut -f1 || echo "0")
                    
                    log_info "Arquivos de instalação encontrados: $install_count arquivos ($install_size)"
                    
                    if [ "$DRY_RUN" = true ]; then
                        log_warning "DRY RUN: Arquivos de instalação ($install_size) seriam removidos"
                        echo "$install_files" | head -3 | sed 's/^/  /'
                        [ "$install_count" -gt 3 ] && echo "  ... e $((install_count - 3)) mais"
                    else
                        echo "$install_files" | xargs rm -f 2>/dev/null || log_warning "Erro ao remover arquivos de instalação"
                        log_success "Arquivos de instalação removidos: $install_count arquivos ($install_size)"
                    fi
                fi
            fi
        done
        
        # 12. Limpar diretórios de teste de bancos de dados
        log_info "Limpando diretórios de teste de bancos de dados..."
        local test_db_dirs=(
            "/www/server/mysql/mysql-test"
            "/www/server/pgsql/test"
            "/var/lib/mysql/mysql-test"
            "/var/lib/pgsql/test"
            "/usr/local/mysql/mysql-test"
            "/usr/local/pgsql/test"
        )
        
        for test_dir in "${test_db_dirs[@]}"; do
            if [ -d "$test_dir" ]; then
                local test_size=$(get_size "$test_dir")
                log_info "Diretório de teste encontrado: $test_dir ($test_size)"
                
                if [ "$DRY_RUN" = true ]; then
                    log_warning "DRY RUN: Diretório de teste $test_dir ($test_size) seria removido"
                else
                    rm -rf "$test_dir" 2>/dev/null || log_warning "Erro ao remover diretório de teste $test_dir"
                    log_success "Diretório de teste removido: $test_dir ($test_size)"
                fi
            fi
        done
        
        # 13. Limpar diretório src do Redis
        log_info "Limpando diretório src do Redis..."
        local redis_src_dirs=(
            "/www/server/redis/src"
            "/var/lib/redis/src"
            "/usr/local/redis/src"
        )
        
        for redis_src_dir in "${redis_src_dirs[@]}"; do
            if [ -d "$redis_src_dir" ]; then
                local redis_size=$(get_size "$redis_src_dir")
                log_info "Diretório src do Redis encontrado: $redis_src_dir ($redis_size)"
                
                if [ "$DRY_RUN" = true ]; then
                    log_warning "DRY RUN: Diretório src do Redis $redis_src_dir ($redis_size) seria removido"
                else
                    rm -rf "$redis_src_dir" 2>/dev/null || log_warning "Erro ao remover diretório src do Redis $redis_src_dir"
                    log_success "Diretório src do Redis removido: $redis_src_dir ($redis_size)"
                fi
            fi
        done
        
        log_success "Limpeza do aaPanel concluída"
        
    else
        log_verbose "aaPanel não encontrado (/www/server/panel não existe)"
    fi
}

# Limpeza de cache de desenvolvimento (pip, npm, yarn, cargo, go, gradle, maven, composer, nuget)
clean_dev_caches() {
    log_info "=== Limpando Caches de Desenvolvimento ==="
    
    # --- Python pip cache ---
    if command -v pip3 >/dev/null 2>&1 || command -v pip >/dev/null 2>&1; then
        log_info "Limpando cache do pip..."
        local pip_cmd="pip3"
        command -v pip3 >/dev/null 2>&1 || pip_cmd="pip"
        
        if [ "$DRY_RUN" = true ]; then
            local pip_cache_dir=$($pip_cmd cache dir 2>/dev/null || echo "")
            if [ -n "$pip_cache_dir" ] && [ -d "$pip_cache_dir" ]; then
                local pip_size=$(get_size "$pip_cache_dir")
                log_warning "DRY RUN: Cache do pip ($pip_size) seria limpo"
            fi
        else
            $pip_cmd cache purge 2>/dev/null || log_verbose "Nenhum cache do pip para limpar"
            log_success "Cache do pip limpo"
        fi
    fi
    
    # --- Python __pycache__ e .pyc ---
    log_info "Limpando __pycache__ e arquivos .pyc..."
    for home_dir in /home/*; do
        if [ -d "$home_dir" ]; then
            local pyc_count=$(find "$home_dir" -type d -name "__pycache__" 2>/dev/null | wc -l)
            if [ "$pyc_count" -gt 0 ]; then
                if [ "$DRY_RUN" = true ]; then
                    log_warning "DRY RUN: $pyc_count diretórios __pycache__ seriam removidos em $home_dir"
                else
                    find "$home_dir" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
                    find "$home_dir" -name "*.pyc" -type f -delete 2>/dev/null
                    log_success "Removidos $pyc_count diretórios __pycache__ em $home_dir"
                fi
            fi
        fi
    done
    
    # --- Python virtualenvs antigos ---
    log_info "Limpando caches de virtualenvs..."
    local venv_cache_dirs=(
        "/home/*/.local/share/virtualenvs"
        "/home/*/.cache/pip"
        "/home/*/.cache/pipenv"
        "/home/*/.cache/pypoetry"
    )
    for venv_dir_pattern in "${venv_cache_dirs[@]}"; do
        for venv_dir in $venv_dir_pattern; do
            if [ -d "$venv_dir" ]; then
                local venv_size=$(get_size "$venv_dir")
                log_info "Cache Python encontrado: $venv_dir ($venv_size)"
                if [ "$DRY_RUN" = true ]; then
                    log_warning "DRY RUN: $venv_dir ($venv_size) seria limpo"
                else
                    rm -rf "$venv_dir"/* 2>/dev/null || log_warning "Erro ao limpar $venv_dir"
                    log_success "Cache Python limpo: $venv_dir"
                fi
            fi
        done
    done
    
    # --- npm cache ---
    if command -v npm >/dev/null 2>&1; then
        log_info "Limpando cache do npm..."
        if [ "$DRY_RUN" = true ]; then
            local npm_cache_size=$(npm cache ls 2>/dev/null | wc -l || echo "0")
            log_warning "DRY RUN: Cache do npm seria limpo"
        else
            npm cache clean --force 2>/dev/null || log_verbose "Nenhum cache do npm para limpar"
            log_success "Cache do npm limpo"
        fi
    fi
    
    # --- yarn cache ---
    if command -v yarn >/dev/null 2>&1; then
        log_info "Limpando cache do yarn..."
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Cache do yarn seria limpo"
        else
            yarn cache clean 2>/dev/null || log_verbose "Nenhum cache do yarn para limpar"
            log_success "Cache do yarn limpo"
        fi
    fi
    
    # --- pnpm cache ---
    if command -v pnpm >/dev/null 2>&1; then
        log_info "Limpando cache do pnpm..."
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Cache do pnpm seria limpo"
        else
            pnpm store prune 2>/dev/null || log_verbose "Nenhum cache do pnpm para limpar"
            log_success "Cache do pnpm limpo"
        fi
    fi
    
    # --- Cargo (Rust) cache ---
    if [ -d "$HOME/.cargo" ] || ls /home/*/.cargo 2>/dev/null | head -1 >/dev/null 2>&1; then
        log_info "Limpando cache do Cargo (Rust)..."
        local cargo_cache_dirs=(
            "/home/*/.cargo/registry/cache"
            "/home/*/.cargo/registry/src"
            "/home/*/.cargo/git/checkouts"
        )
        for cargo_pattern in "${cargo_cache_dirs[@]}"; do
            for cargo_dir in $cargo_pattern; do
                if [ -d "$cargo_dir" ]; then
                    local cargo_size=$(get_size "$cargo_dir")
                    if [ "$DRY_RUN" = true ]; then
                        log_warning "DRY RUN: $cargo_dir ($cargo_size) seria limpo"
                    else
                        rm -rf "$cargo_dir"/* 2>/dev/null || log_warning "Erro ao limpar $cargo_dir"
                        log_success "Cache Cargo limpo: $(basename "$cargo_dir") ($cargo_size)"
                    fi
                fi
            done
        done
    fi
    
    # --- Go cache ---
    if command -v go >/dev/null 2>&1; then
        log_info "Limpando cache do Go..."
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Cache do Go seria limpo"
        else
            go clean -cache 2>/dev/null || log_verbose "Erro ao limpar cache do Go"
            go clean -modcache 2>/dev/null || log_verbose "Erro ao limpar mod cache do Go"
            log_success "Cache do Go limpo"
        fi
    fi
    
    # --- Gradle cache ---
    local gradle_dirs=(/home/*/.gradle/caches)
    for gradle_dir in "${gradle_dirs[@]}"; do
        if [ -d "$gradle_dir" ]; then
            local gradle_size=$(get_size "$gradle_dir")
            log_info "Cache do Gradle encontrado: $gradle_dir ($gradle_size)"
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: $gradle_dir ($gradle_size) seria limpo"
            else
                rm -rf "$gradle_dir"/* 2>/dev/null || log_warning "Erro ao limpar cache do Gradle"
                log_success "Cache do Gradle limpo ($gradle_size)"
            fi
        fi
    done
    
    # --- Maven cache ---
    local maven_dirs=(/home/*/.m2/repository)
    for maven_dir in "${maven_dirs[@]}"; do
        if [ -d "$maven_dir" ]; then
            local maven_size=$(get_size "$maven_dir")
            log_info "Cache do Maven encontrado: $maven_dir ($maven_size)"
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: $maven_dir ($maven_size) seria limpo"
            else
                rm -rf "$maven_dir"/* 2>/dev/null || log_warning "Erro ao limpar cache do Maven"
                log_success "Cache do Maven limpo ($maven_size)"
            fi
        fi
    done
    
    # --- Composer (PHP) cache ---
    if command -v composer >/dev/null 2>&1; then
        log_info "Limpando cache do Composer..."
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Cache do Composer seria limpo"
        else
            composer clear-cache 2>/dev/null || log_verbose "Nenhum cache do Composer para limpar"
            log_success "Cache do Composer limpo"
        fi
    fi
    
    # --- NuGet (.NET) cache ---
    if command -v dotnet >/dev/null 2>&1; then
        log_info "Limpando cache do NuGet (.NET)..."
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Cache do NuGet seria limpo"
        else
            dotnet nuget locals all --clear 2>/dev/null || log_verbose "Nenhum cache do NuGet para limpar"
            log_success "Cache do NuGet limpo"
        fi
    fi
    
    # --- Gem (Ruby) cache ---
    if command -v gem >/dev/null 2>&1; then
        log_info "Limpando cache do Gem (Ruby)..."
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Cache do Gem seria limpo"
        else
            gem cleanup 2>/dev/null || log_verbose "Nenhum cache do Gem para limpar"
            log_success "Cache do Gem limpo"
        fi
    fi
}

# Limpeza de Flatpak
clean_flatpak() {
    if command -v flatpak >/dev/null 2>&1; then
        log_info "=== Limpando Flatpak ==="
        
        if [ "$DRY_RUN" = true ]; then
            local unused_refs=$(flatpak uninstall --unused 2>/dev/null | wc -l || echo "0")
            log_warning "DRY RUN: $unused_refs runtimes Flatpak não utilizados seriam removidos"
        else
            flatpak uninstall --unused -y 2>/dev/null || log_verbose "Nenhum runtime Flatpak não utilizado"
            # Limpar cache de repo do Flatpak
            flatpak repair 2>/dev/null || log_verbose "Erro no reparo do Flatpak"
            log_success "Flatpak limpo"
        fi
    else
        log_verbose "Flatpak não encontrado"
    fi
}

# Limpeza de core dumps e crash reports
clean_coredumps() {
    log_info "=== Limpando Core Dumps e Crash Reports ==="
    
    # Coredumps do systemd
    if command -v coredumpctl >/dev/null 2>&1; then
        log_info "Limpando coredumps do systemd..."
        local coredump_dir="/var/lib/systemd/coredump"
        if [ -d "$coredump_dir" ]; then
            local coredump_size=$(get_size "$coredump_dir")
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: Coredumps ($coredump_size) seriam removidos"
            else
                find "$coredump_dir" -type f -delete 2>/dev/null || log_warning "Erro ao limpar coredumps"
                log_success "Coredumps do systemd removidos ($coredump_size)"
            fi
        fi
    fi
    
    # Core dumps em /var/crash (Ubuntu/Debian)
    if [ -d "/var/crash" ]; then
        local crash_count=$(find /var/crash -type f 2>/dev/null | wc -l)
        if [ "$crash_count" -gt 0 ]; then
            local crash_size=$(get_size "/var/crash")
            log_info "Crash reports encontrados: $crash_count arquivos ($crash_size)"
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: Crash reports ($crash_size) seriam removidos"
            else
                rm -rf /var/crash/* 2>/dev/null || log_warning "Erro ao limpar crash reports"
                log_success "Crash reports removidos ($crash_size)"
            fi
        fi
    fi
    
    # Apport crash files
    if [ -d "/var/lib/apport/coredump" ]; then
        local apport_size=$(get_size "/var/lib/apport/coredump")
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Apport coredumps ($apport_size) seriam removidos"
        else
            rm -rf /var/lib/apport/coredump/* 2>/dev/null
            log_success "Apport coredumps removidos ($apport_size)"
        fi
    fi
    
    # Arquivos core soltos
    local core_files=$(find / -maxdepth 3 -name "core" -o -name "core.*" -type f 2>/dev/null | head -20)
    if [ -n "$core_files" ]; then
        local core_count=$(echo "$core_files" | wc -l)
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: $core_count core dumps soltos seriam removidos"
            echo "$core_files" | head -5 | sed 's/^/  /'
        else
            echo "$core_files" | xargs rm -f 2>/dev/null || log_warning "Erro ao remover core dumps"
            log_success "Core dumps soltos removidos: $core_count arquivos"
        fi
    fi
}

# Limpeza de pacotes órfãos e configurações residuais
clean_orphan_packages() {
    log_info "=== Limpando Pacotes Órfãos e Configurações Residuais ==="
    
    if command -v apt-get >/dev/null 2>&1; then
        # Pacotes com configurações residuais (removidos mas config ainda presente)
        local residual_pkgs=$(dpkg -l | awk '/^rc/{print $2}' 2>/dev/null)
        if [ -n "$residual_pkgs" ]; then
            local residual_count=$(echo "$residual_pkgs" | wc -l)
            log_info "Pacotes com configurações residuais: $residual_count"
            
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: $residual_count pacotes residuais seriam purgados"
                echo "$residual_pkgs" | head -5 | sed 's/^/  /'
                [ "$residual_count" -gt 5 ] && echo "  ... e $((residual_count - 5)) mais"
            else
                echo "$residual_pkgs" | xargs apt-get purge -y 2>/dev/null || log_warning "Erro ao purgar pacotes residuais"
                log_success "Pacotes residuais purgados: $residual_count"
            fi
        else
            log_verbose "Nenhum pacote residual encontrado"
        fi
        
        # deborphan - pacotes órfãos (se disponível)
        if command -v deborphan >/dev/null 2>&1; then
            local orphan_pkgs=$(deborphan 2>/dev/null)
            if [ -n "$orphan_pkgs" ]; then
                local orphan_count=$(echo "$orphan_pkgs" | wc -l)
                log_info "Pacotes órfãos encontrados: $orphan_count"
                
                if [ "$DRY_RUN" = true ]; then
                    log_warning "DRY RUN: $orphan_count pacotes órfãos seriam removidos"
                else
                    echo "$orphan_pkgs" | xargs apt-get purge -y 2>/dev/null || log_warning "Erro ao remover pacotes órfãos"
                    log_success "Pacotes órfãos removidos: $orphan_count"
                fi
            fi
        fi
    fi
}

# Limpeza de locales não utilizados
clean_unused_locales() {
    log_info "=== Limpando Locales Não Utilizados ==="
    
    # Limpar cache de locales
    if [ -d "/usr/share/locale" ]; then
        local current_locale=$(locale | grep LANG= | cut -d= -f2 | cut -d. -f1 | head -1)
        local locale_size=$(get_size "/usr/share/locale")
        log_info "Locales instalados: $locale_size (locale atual: $current_locale)"
        
        if command -v localepurge >/dev/null 2>&1; then
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: Locales não utilizados seriam limpos com localepurge"
            else
                localepurge 2>/dev/null || log_verbose "Erro ao executar localepurge"
                log_success "Locales não utilizados limpos"
            fi
        else
            log_verbose "localepurge não disponível (instale com: apt-get install localepurge)"
        fi
    fi
    
    # Limpar cache de fontes
    if [ -d "/var/cache/fontconfig" ]; then
        local font_cache_size=$(get_size "/var/cache/fontconfig")
        log_info "Cache de fontes: $font_cache_size"
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Cache de fontes ($font_cache_size) seria limpo"
        else
            rm -rf /var/cache/fontconfig/* 2>/dev/null
            fc-cache -f 2>/dev/null || log_verbose "Erro ao reconstruir cache de fontes"
            log_success "Cache de fontes limpo e reconstruído"
        fi
    fi
    
    # Limpar man pages de idiomas não usados
    if [ -d "/usr/share/man" ]; then
        local man_dirs=$(find /usr/share/man -mindepth 1 -maxdepth 1 -type d -not -name "man*" 2>/dev/null)
        if [ -n "$man_dirs" ]; then
            local man_locale_size=$(echo "$man_dirs" | xargs du -csh 2>/dev/null | tail -1 | cut -f1 || echo "0")
            log_info "Man pages de outros idiomas: $man_locale_size"
            log_verbose "Diretórios de man pages de idiomas encontrados (não removidos automaticamente)"
        fi
    fi
}

# Limpeza de swap e memória
clean_swap_memory() {
    log_info "=== Limpando Swap e Memória ==="
    
    # Limpar PageCache, dentries e inodes
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Cache de memória do kernel seria liberado"
    else
        sync
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || log_verbose "Não foi possível liberar cache de memória"
        log_success "Cache de memória do kernel liberado"
    fi
    
    # Limpar swap (se possível)
    local swap_total=$(free -m | awk '/Swap:/{print $2}')
    local swap_used=$(free -m | awk '/Swap:/{print $3}')
    
    if [ "$swap_total" -gt 0 ] && [ "$swap_used" -gt 0 ]; then
        log_info "Swap em uso: ${swap_used}MB de ${swap_total}MB"
        
        local mem_free=$(free -m | awk '/Mem:/{print $7}')
        if [ "$mem_free" -gt "$swap_used" ]; then
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: Swap seria limpo (${swap_used}MB → RAM disponível: ${mem_free}MB)"
            else
                if [ "$INTERACTIVE" = true ]; then
                    echo -n "Limpar swap? (${swap_used}MB em uso, ${mem_free}MB RAM livre) (y/N): "
                    read -r response
                    if [[ "$response" =~ ^[Yy]$ ]]; then
                        swapoff -a 2>/dev/null && swapon -a 2>/dev/null
                        log_success "Swap limpo com sucesso"
                    else
                        log_info "Pulando limpeza de swap"
                    fi
                else
                    swapoff -a 2>/dev/null && swapon -a 2>/dev/null
                    log_success "Swap limpo com sucesso"
                fi
            fi
        else
            log_warning "RAM livre insuficiente para limpar swap (necessário: ${swap_used}MB, disponível: ${mem_free}MB)"
        fi
    else
        log_verbose "Swap não está em uso"
    fi
}

# Limpeza de logs de mail e filas de email
clean_mail_queue() {
    log_info "=== Limpando Filas de Email e Logs de Mail ==="
    
    # Postfix
    if command -v postfix >/dev/null 2>&1; then
        log_info "Limpando fila de email do Postfix..."
        if [ "$DRY_RUN" = true ]; then
            local queue_count=$(mailq 2>/dev/null | tail -1 | grep -oP '\d+' | head -1 || echo "0")
            log_warning "DRY RUN: $queue_count emails na fila seriam removidos"
        else
            postsuper -d ALL 2>/dev/null || log_verbose "Nenhuma fila de email para limpar"
            log_success "Fila de email do Postfix limpa"
        fi
    fi
    
    # Exim
    if command -v exim >/dev/null 2>&1 || command -v exim4 >/dev/null 2>&1; then
        log_info "Limpando fila de email do Exim..."
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Fila de email do Exim seria limpa"
        else
            if command -v exiqgrep >/dev/null 2>&1; then
                exiqgrep -i | xargs exim -Mrm 2>/dev/null || log_verbose "Nenhuma fila do Exim para limpar"
            fi
            log_success "Fila de email do Exim limpa"
        fi
    fi
    
    # Logs de mail
    local mail_logs=(
        "/var/log/mail.log"
        "/var/log/mail.err"
        "/var/log/mail.warn"
        "/var/log/maillog"
    )
    
    for mail_log in "${mail_logs[@]}"; do
        if [ -f "$mail_log" ]; then
            local mail_size=$(get_size "$mail_log")
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: $mail_log ($mail_size) seria limpo"
            else
                > "$mail_log" 2>/dev/null || log_warning "Não foi possível limpar $mail_log"
                log_success "Log de mail limpo: $(basename "$mail_log") ($mail_size)"
            fi
        fi
    done
}

# Limpeza de arquivos grandes órfãos e duplicados
clean_large_orphan_files() {
    log_info "=== Identificando Arquivos Grandes ==="
    
    # Encontrar arquivos .iso, .img, .vmdk, .vdi em /home e /tmp
    local large_patterns=("*.iso" "*.img" "*.vmdk" "*.vdi" "*.ova" "*.qcow2")
    local search_dirs=("/home" "/tmp" "/var/tmp" "/root")
    
    for pattern in "${large_patterns[@]}"; do
        for search_dir in "${search_dirs[@]}"; do
            if [ -d "$search_dir" ]; then
                local large_files=$(find "$search_dir" -name "$pattern" -type f -size +100M 2>/dev/null || true)
                if [ -n "$large_files" ]; then
                    local large_count=$(echo "$large_files" | wc -l)
                    local large_size=$(echo "$large_files" | xargs du -ch 2>/dev/null | tail -1 | cut -f1 || echo "0")
                    
                    log_warning "Arquivos grandes encontrados ($pattern): $large_count arquivos ($large_size) em $search_dir"
                    echo "$large_files" | head -5 | while read -r file; do
                        local fsize=$(get_size "$file")
                        echo "  $file ($fsize)"
                    done
                    [ "$large_count" -gt 5 ] && echo "  ... e $((large_count - 5)) mais"
                fi
            fi
        done
    done
    
    # Arquivos de log muito grandes (> 500MB)
    log_info "Verificando logs excessivamente grandes (> 500MB)..."
    local huge_logs=$(find /var/log -type f -size +500M 2>/dev/null || true)
    if [ -n "$huge_logs" ]; then
        echo "$huge_logs" | while read -r log_file; do
            local log_size=$(get_size "$log_file")
            log_warning "Log grande encontrado: $log_file ($log_size)"
            
            if [ "$DRY_RUN" = false ]; then
                if [ "$INTERACTIVE" = true ]; then
                    echo -n "Limpar conteúdo de $log_file? (y/N): "
                    read -r response
                    if [[ "$response" =~ ^[Yy]$ ]]; then
                        > "$log_file" 2>/dev/null
                        log_success "Log grande limpo: $log_file"
                    fi
                else
                    > "$log_file" 2>/dev/null
                    log_success "Log grande limpo: $log_file"
                fi
            fi
        done
    fi
}

# Limpeza de arquivos antigos de backup e temporários do sistema
clean_old_system_files() {
    log_info "=== Limpando Arquivos Antigos do Sistema ==="
    
    # Arquivos .dpkg-old, .dpkg-new, .dpkg-dist, .ucf-old
    log_info "Limpando arquivos residuais do dpkg..."
    local dpkg_patterns=("*.dpkg-old" "*.dpkg-new" "*.dpkg-dist" "*.ucf-old" "*.ucf-dist")
    
    for pattern in "${dpkg_patterns[@]}"; do
        local dpkg_files=$(find /etc -name "$pattern" -type f 2>/dev/null || true)
        if [ -n "$dpkg_files" ]; then
            local dpkg_count=$(echo "$dpkg_files" | wc -l)
            log_info "Arquivos $pattern encontrados: $dpkg_count"
            
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: $dpkg_count arquivos $pattern seriam removidos"
                echo "$dpkg_files" | head -3 | sed 's/^/  /'
            else
                echo "$dpkg_files" | xargs rm -f 2>/dev/null
                log_success "Arquivos $pattern removidos: $dpkg_count"
            fi
        fi
    done
    
    # Limpar /var/backups antigos (> 30 dias)
    if [ -d "/var/backups" ]; then
        local old_backups=$(find /var/backups -type f -mtime +30 2>/dev/null || true)
        if [ -n "$old_backups" ]; then
            local backup_count=$(echo "$old_backups" | wc -l)
            local backup_size=$(echo "$old_backups" | xargs du -ch 2>/dev/null | tail -1 | cut -f1 || echo "0")
            log_info "Backups antigos do sistema (>30 dias): $backup_count arquivos ($backup_size)"
            
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: Backups antigos ($backup_size) seriam removidos"
            else
                echo "$old_backups" | xargs rm -f 2>/dev/null
                log_success "Backups antigos do sistema removidos: $backup_count arquivos"
            fi
        fi
    fi
    
    # Limpar logs rotacionados antigos compactados (> 7 dias)
    log_info "Limpando logs rotacionados antigos..."
    local rotated_logs=$(find /var/log -name "*.gz" -o -name "*.xz" -o -name "*.bz2" -o -name "*.zst" | xargs ls -t 2>/dev/null | tail -n +20 || true)
    if [ -n "$rotated_logs" ]; then
        local rotated_count=$(echo "$rotated_logs" | wc -l)
        local rotated_size=$(echo "$rotated_logs" | xargs du -ch 2>/dev/null | tail -1 | cut -f1 || echo "0")
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: $rotated_count logs rotacionados antigos ($rotated_size) seriam removidos"
        else
            echo "$rotated_logs" | xargs rm -f 2>/dev/null
            log_success "Logs rotacionados antigos removidos: $rotated_count arquivos ($rotated_size)"
        fi
    fi
    
    # Arquivos .old e .bak em /etc
    remove_files "*.old" "Arquivos .old em /etc" "/etc"
    remove_files "*.bak" "Arquivos .bak em /etc" "/etc"
}

# Limpeza de caches do sistema (thumbnails, ícones, etc.)
clean_system_caches() {
    log_info "=== Limpando Caches do Sistema ==="
    
    # Cache do ldconfig
    if [ -f "/etc/ld.so.cache" ]; then
        if [ "$DRY_RUN" = false ]; then
            ldconfig 2>/dev/null || log_verbose "Erro ao reconstruir cache do ldconfig"
            log_success "Cache do ldconfig reconstruído"
        fi
    fi
    
    # Cache do apt lists
    if [ -d "/var/lib/apt/lists" ]; then
        local apt_lists_size=$(get_size "/var/lib/apt/lists")
        log_info "Listas do APT: $apt_lists_size"
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Listas do APT ($apt_lists_size) seriam limpas"
        else
            rm -rf /var/lib/apt/lists/* 2>/dev/null
            apt-get update -qq 2>/dev/null || log_warning "Erro ao atualizar listas do APT"
            log_success "Listas do APT limpas e atualizadas"
        fi
    fi
    
    # Cache do PackageKit (se existir)
    if [ -d "/var/cache/PackageKit" ]; then
        local pk_size=$(get_size "/var/cache/PackageKit")
        log_info "Cache do PackageKit: $pk_size"
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Cache do PackageKit ($pk_size) seria limpo"
        else
            rm -rf /var/cache/PackageKit/* 2>/dev/null
            log_success "Cache do PackageKit limpo ($pk_size)"
        fi
    fi
    
    # Cache do DKMS (módulos de kernel)
    if [ -d "/var/lib/dkms" ]; then
        local dkms_size=$(get_size "/var/lib/dkms")
        log_info "Módulos DKMS: $dkms_size"
        log_verbose "Módulos DKMS não são removidos automaticamente (podem ser necessários)"
    fi
    
    # Limpar cache de ícones
    for home_dir in /home/*; do
        if [ -d "$home_dir/.cache/icon-cache" ]; then
            local icon_size=$(get_size "$home_dir/.cache/icon-cache")
            if [ "$DRY_RUN" = true ]; then
                log_warning "DRY RUN: Cache de ícones ($icon_size) seria limpo"
            else
                rm -rf "$home_dir/.cache/icon-cache"/* 2>/dev/null
                log_success "Cache de ícones limpo ($icon_size)"
            fi
        fi
    done
}

# Limpeza de journal do systemd
clean_journal() {
    if command -v journalctl >/dev/null 2>&1; then
        log_info "=== Limpando Journal do Systemd ==="
        
        local size_before=$(journalctl --disk-usage | awk '{print $3, $4}' || echo "0")
        log_info "Tamanho atual do journal: $size_before"
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: Journal seria limpo"
        else
            # Manter apenas os últimos 1 dia
            journalctl --vacuum-time=1d 2>/dev/null || log_warning "Erro ao limpar journal"
            
            # Limitar a 100MB
            journalctl --vacuum-size=100M 2>/dev/null || log_warning "Erro ao limitar tamanho do journal"
            
            local size_after=$(journalctl --disk-usage | awk '{print $3, $4}' || echo "0")
            log_success "Journal limpo: $size_before → $size_after"
        fi
    fi
}

# Relatório final
show_report() {
    echo
    echo "========================================"
    echo "           RELATÓRIO DE LIMPEZA"
    echo "========================================"
    echo
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "MODO SIMULAÇÃO - Nenhum arquivo foi removido"
        echo "Execute novamente sem --dry-run para limpar realmente"
    else
        log_success "Limpeza concluída!"
        echo "Operações realizadas: $TOTAL_FREED"
    fi
    
    echo
    log_info "Espaço em disco antes/depois:"
    df -h / | tail -1 | awk '{print "  /: " $3 " usado, " $4 " livre (" $5 " usado)"}'
    
    echo
    log_info "Sugestões adicionais:"
    echo "  - Desinstale programas não utilizados"
    echo "  - Mova arquivos grandes para armazenamento externo"
    echo "  - Use ferramentas como bleachbit para limpeza profunda"
    echo "  - Considere compactar arquivos antigos"
    echo
}

# Função principal de limpeza
run_cleanup() {
    log_info "Iniciando limpeza de disco..."
    echo
    
    clean_system_logs
    echo
    
    clean_apt_cache
    echo
    
    clean_temp_files
    echo
    
    clean_application_cache
    echo
    
    clean_old_kernels
    echo
    
    clean_docker
    echo
    
    clean_snap
    echo
    
    clean_aapanel
    echo
    
    clean_journal
    echo
    
    clean_dev_caches
    echo
    
    clean_flatpak
    echo
    
    clean_coredumps
    echo
    
    clean_orphan_packages
    echo
    
    clean_unused_locales
    echo
    
    clean_swap_memory
    echo
    
    clean_mail_queue
    echo
    
    clean_large_orphan_files
    echo
    
    clean_old_system_files
    echo
    
    clean_system_caches
    echo
    
    # Limpeza com BleachBit (se disponível)
    clean_bleachbit
    echo
    
    show_report
}

# Instalar e executar BleachBit
install_and_run_bleachbit() {
    if command -v bleachbit >/dev/null 2>&1; then
        log_info "=== Executando Limpeza com BleachBit ==="
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: BleachBit seria executado com as seguintes opções:"
            echo "  bleachbit --clean system.cache system.rotated_logs system.tmp"
            echo "  bleachbit --clean apt.autoclean apt.autoremove apt.clean"
        else
            log_info "Limpando cache do sistema e logs rotacionados..."
            bleachbit --clean system.cache system.rotated_logs system.tmp 2>/dev/null || log_warning "Erro ao limpar cache e logs com BleachBit"
            
            log_info "Limpando resíduos do gerenciador de pacotes..."
            bleachbit --clean apt.autoclean apt.autoremove apt.clean 2>/dev/null || log_warning "Erro ao limpar resíduos do APT com BleachBit"
            
            log_success "Limpeza com BleachBit concluída"
        fi
    else
        log_info "BleachBit não encontrado. Instalando..."
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: BleachBit seria instalado"
            return
        fi
        
        # Detectar distribuição
        local distro=""
        if [ -f /etc/os-release ]; then
            distro=$(grep "^ID=" /etc/os-release | cut -d'"' -f2)
        elif command -v lsb_release >/dev/null 2>&1; then
            distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        fi
        
        log_info "Detectada distribuição: $distro"
        
        # Instalar BleachBit baseado na distribuição
        case "$distro" in
            ubuntu|debian)
                log_info "Instalando BleachBit via APT..."
                apt-get update -qq >/dev/null 2>&1
                apt-get install -y bleachbit >/dev/null 2>&1
                ;;
            fedora|centos|rhel)
                log_info "Instalando BleachBit via DNF/YUM..."
                if command -v dnf >/dev/null 2>&1; then
                    dnf install -y bleachbit >/dev/null 2>&1
                elif command -v yum >/dev/null 2>&1; then
                    yum install -y bleachbit >/dev/null 2>&1
                fi
                ;;
            arch)
                log_info "Instalando BleachBit via Pacman..."
                pacman -S --noconfirm bleachbit >/dev/null 2>&1
                ;;
            *)
                log_warning "Distribuição não suportada para instalação automática: $distro"
                log_info "Por favor, instale o BleachBit manualmente:"
                echo "  Ubuntu/Debian: sudo apt-get install bleachbit"
                echo "  Fedora/CentOS: sudo dnf install bleachbit"
                echo "  Arch Linux: sudo pacman -S bleachbit"
                return
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            log_success "BleachBit instalado com sucesso"
            
            # Executar limpeza após instalação
            log_info "Executando limpeza com BleachBit recém-instalado..."
            bleachbit --clean system.cache system.rotated_logs system.tmp 2>/dev/null || log_warning "Erro ao limpar cache e logs com BleachBit"
            bleachbit --clean apt.autoclean apt.autoremove apt.clean 2>/dev/null || log_warning "Erro ao limpar resíduos do APT com BleachBit"
            log_success "Limpeza com BleachBit concluída"
        else
            log_error "Falha ao instalar BleachBit"
        fi
    fi
}

# Limpeza com BleachBit
clean_bleachbit() {
    if command -v bleachbit >/dev/null 2>&1; then
        log_info "=== Limpando com BleachBit ==="
        
        if [ "$DRY_RUN" = true ]; then
            log_warning "DRY RUN: BleachBit seria executado"
            return
        fi
        
        # Limpar cache do sistema e logs rotacionados
        log_info "Limpando cache do sistema e logs rotacionados..."
        bleachbit --clean system.cache system.rotated_logs system.tmp 2>/dev/null || log_warning "Erro ao limpar cache e logs com BleachBit"
        
        # Limpar resíduos do gerenciador de pacotes
        log_info "Limpando resíduos do gerenciador de pacotes..."
        bleachbit --clean apt.autoclean apt.autoremove apt.clean 2>/dev/null || log_warning "Erro ao limpar resíduos do APT com BleachBit"
        
        log_success "Limpeza com BleachBit concluída"
    else
        log_verbose "BleachBit não disponível"
    fi
}

# Parse de argumentos
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
            --force|-f)
                INTERACTIVE=false
                ;;
            --bleachbit|-b)
                INSTALL_BLEACHBIT=true
                ;;
            *)
                log_error "Opção desconhecida: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

# Função principal
main() {
    echo "========================================"
    echo "      clear-up.sh - Limpeza de Disco"
    echo "========================================"
    echo
    
    check_root
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "MODO DE SIMULAÇÃO ATIVADO"
    fi
    
    if [ "$INTERACTIVE" = false ]; then
        log_warning "MODO NÃO-INTERATIVO ATIVADO"
    fi
    
    if [ "$VERBOSE" = true ]; then
        log_info "MODO DETALHADO ATIVADO"
    fi
    
    echo
    
    # Confirmar início
    if [ "$INTERACTIVE" = true ] && [ "$DRY_RUN" = false ]; then
        echo -n "Iniciar limpeza de disco? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Operação cancelada pelo usuário"
            exit 0
        fi
    fi
    
    if [ "$INSTALL_BLEACHBIT" = true ]; then
        install_and_run_bleachbit
    else
        run_cleanup
    fi
}

# Execução
parse_args "$@"
main
