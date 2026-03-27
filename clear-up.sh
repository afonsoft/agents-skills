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
    echo "  --dry-run, -d      Simula a limpeza sem remover arquivos"
    echo "  --verbose, -v      Modo detalhado"
    echo "  --force, -f        Modo não-interativo (pula confirmacoes)"
    echo "  --help, -h         Exibe esta mensagem de ajuda"
    echo
    echo -e "${YELLOW}O que sera limpo:${NC}"
    echo "  - Logs do sistema (*.log, log*)"
    echo "  - Cache de pacotes (apt)"
    echo "  - Arquivos temporários"
    echo "  - Cache de aplicativos"
    echo "  - Kernel antigos"
    echo "  - Lixeira do sistema"
    echo "  - Docker (se instalado)"
    echo "  - Snap packages antigos"
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
        
        log_success "Limpeza do aaPanel concluída"
        
    else
        log_verbose "aaPanel não encontrado (/www/server/panel não existe)"
    fi
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
            # Manter apenas os últimos 7 dias
            journalctl --vacuum-time=7d 2>/dev/null || log_warning "Erro ao limpar journal"
            
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
    
    show_report
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
    
    run_cleanup
}

# Execução
parse_args "$@"
main
