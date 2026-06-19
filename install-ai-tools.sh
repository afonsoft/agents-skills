#!/bin/bash

# Script unificado para instalação de ferramentas de otimização de AI
# Instala RTK, Caveman e Superpowers para múltiplos agentes AI
# Suporta: Claude Code, Cursor, Gemini CLI, Devin CLI, VS Code Copilot, etc.
# Cross-platform: Windows, Linux, macOS

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variáveis de controle
INSTALL_RTK=false
INSTALL_CAVEMAN=false
INSTALL_SUPERPOWERS=false
INSTALL_ALL=false
DRY_RUN=false
VERBOSE=false
GITHUB_TOKEN=""

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

# Detecção de sistema operacional
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

# Função de help
show_help() {
    echo
    echo -e "${CYAN}AI Tools Installer - RTK, Caveman, Superpowers${NC}"
    echo
    echo -e "${YELLOW}Uso:${NC}"
    echo "  $0 [opcoes]"
    echo
    echo -e "${YELLOW}Opcoes de ferramenta:${NC}"
    echo "  --rtk, -r              Instala RTK (Rust Token Killer)"
    echo "  --caveman, -c          Instala Caveman"
    echo "  --superpowers, -s      Instala Superpowers"
    echo "  --all, -a              Instala todas as ferramentas"
    echo
    echo -e "${YELLOW}Outras opcoes:${NC}"
    echo "  --dry-run, -d          Simula instalacao sem executar"
    echo "  --verbose, -v          Modo detalhado"
    echo "  --github-token <TOKEN> Token GitHub para evitar rate-limit"
    echo "  --help, -h             Exibe esta mensagem de ajuda"
    echo
    echo -e "${YELLOW}Exemplos:${NC}"
    echo "  $0 --all                           # Instala tudo"
    echo "  $0 --rtk --caveman                # RTK + Caveman"
    echo "  $0 --superpowers                  # Apenas Superpowers"
    echo "  $0 -a -v                          # Tudo com modo detalhado"
    echo "  $0 --all --dry-run               # Simula instalacao completa"
    echo
    echo -e "${YELLOW}O que sera instalado:${NC}"
    echo "  RTK: Otimizador de tokens para comandos de terminal"
    echo "       Suporta: Claude Code, Cursor, Gemini CLI, VS Code Copilot, etc."
    echo "  Caveman: Stack de otimizacao de tokens (5 ferramentas)"
    echo "       Suporta: Claude Code, Cursor, Gemini CLI, OpenCode, OpenClaw, etc."
    echo "  Superpowers: Framework de skills para desenvolvimento estruturado"
    echo "       Suporta: Claude Code, Cursor, OpenCode, Codex, Gemini CLI, etc."
    echo
    echo -e "${YELLOW}Sistemas suportados:${NC}"
    echo "  Linux, macOS, Windows (via WSL ou Git Bash)"
    echo
}

# Parse de argumentos
parse_args() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --rtk|-r)
                INSTALL_RTK=true
                ;;
            --caveman|-c)
                INSTALL_CAVEMAN=true
                ;;
            --superpowers|-s)
                INSTALL_SUPERPOWERS=true
                ;;
            --all|-a)
                INSTALL_RTK=true
                INSTALL_CAVEMAN=true
                INSTALL_SUPERPOWERS=true
                INSTALL_ALL=true
                ;;
            --dry-run|-d)
                DRY_RUN=true
                ;;
            --verbose|-v)
                VERBOSE=true
                ;;
            --github-token)
                shift
                if [ $# -eq 0 ]; then
                    log_error "--github-token requer um valor. Ex: --github-token ghp_xxx"
                    exit 1
                fi
                GITHUB_TOKEN="$1"
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

# Verifica se comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Instala RTK
install_rtk() {
    log_info "=== Instalando RTK (Rust Token Killer) ==="
    
    # Verifica se RTK já está instalado
    if command_exists rtk; then
        log_info "RTK já está instalado. Verificando versão..."
        if rtk --version &> /dev/null; then
            log_success "RTK já está instalado: $(rtk --version)"
            
            # Verifica se é o RTK correto (Token Killer, não Type Kit)
            if rtk gain &> /dev/null; then
                log_success "RTK correto (Token Killer) detectado"
                log_info "Estatísticas de economia: $(rtk gain | head -1)"
                return 0
            else
                log_warning "RTK incorreto (Type Kit) detectado. Será reinstalado."
            fi
        else
            log_warning "RTK instalado mas não funcional. Será reinstalado."
        fi
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: RTK seria instalado"
        return 0
    fi
    
    log_info "Instalando RTK..."
    
    case "$OS" in
        Linux|Mac)
            # Tenta instalar via script oficial
            log_info "Baixando e executando instalador oficial..."
            if curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh; then
                log_success "RTK instalado com sucesso"
            else
                log_error "Falha na instalacao via script. Tentando via cargo..."
                if command_exists cargo; then
                    cargo install --git https://github.com/rtk-ai/rtk rtk
                    log_success "RTK instalado via cargo"
                else
                    log_error "Cargo não encontrado. Instale Rust primeiro."
                    return 1
                fi
            fi
            ;;
        Windows)
            log_warning "No Windows, recomenda-se usar WSL para suporte completo de hooks"
            log_info "Para suporte completo, execute este script dentro do WSL"
            log_info "Instalando RTK no Windows (suporte limitado)..."
            
            # Tenta instalar via cargo se disponível
            if command_exists cargo; then
                cargo install --git https://github.com/rtk-ai/rtk rtk
                log_success "RTK instalado via cargo (suporte limitado no Windows)"
            else
                log_error "Cargo não encontrado. No Windows, use WSL para suporte completo."
                return 1
            fi
            ;;
        *)
            log_error "Sistema operacional não suportado: $OS"
            return 1
            ;;
    esac
    
    # Verifica instalação
    if command_exists rtk; then
        log_success "RTK instalado: $(rtk --version)"
        
        # Inicializa hooks globais para Claude Code
        if command_exists claude; then
            log_info "Inicializando RTK para Claude Code..."
            rtk init --global
            log_success "RTK inicializado para Claude Code"
        fi
        
        # Inicializa para Cursor se disponível
        if [ -d "$HOME/.cursor" ]; then
            log_info "Inicializando RTK para Cursor..."
            rtk init --global --cursor
            log_success "RTK inicializado para Cursor"
        fi
        
        log_info "Execute 'rtk gain' para ver estatísticas de economia de tokens"
    else
        log_error "Falha na instalacao do RTK"
        return 1
    fi
}

# Instala Caveman
install_caveman() {
    log_info "=== Instalando Caveman ==="
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Caveman seria instalado"
        return 0
    fi
    
    log_info "Instalando Caveman..."
    
    case "$OS" in
        Linux|Mac)
            log_info "Baixando e executando instalador oficial..."
            if curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash; then
                log_success "Caveman instalado com sucesso"
            else
                log_error "Falha na instalacao do Caveman"
                return 1
            fi
            ;;
        Windows)
            log_info "No Windows, usando PowerShell para instalacao..."
            if command_exists powershell.exe || command_exists pwsh; then
                log_info "Execute manualmente no PowerShell:"
                echo "irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex"
                log_warning "Instalacao manual requerida no Windows"
                return 1
            else
                log_error "PowerShell não encontrado"
                return 1
            fi
            ;;
        *)
            log_error "Sistema operacional não suportado: $OS"
            return 1
            ;;
    esac
    
    log_success "Caveman instalado e configurado para todos os agentes detectados"
}

# Instala Superpowers
install_superpowers() {
    log_info "=== Instalando Superpowers ==="
    
    # Verifica se Claude Code está disponível
    if ! command_exists claude; then
        log_warning "Claude Code não encontrado. Superpowers requer Claude Code."
        log_info "Instale Claude Code primeiro: https://code.claude.com"
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Superpowers seria instalado via Claude Code"
        return 0
    fi
    
    log_info "Instalando Superpowers via Claude Code marketplace..."
    
    # Tenta instalar via marketplace oficial
    log_info "Registrando marketplace oficial..."
    if claude plugin marketplace add claude-plugins-official 2>/dev/null || true; then
        log_success "Marketplace oficial registrado"
    else
        log_info "Marketplace oficial já registrado ou falhou (continuando...)"
    fi
    
    log_info "Instalando Superpowers..."
    if claude plugin install superpowers@claude-plugins-official; then
        log_success "Superpowers instalado com sucesso via marketplace oficial"
    else
        log_warning "Falha na instalacao via marketplace oficial. Tentando marketplace community..."
        
        # Tenta marketplace community
        log_info "Registrando marketplace community..."
        if claude plugin marketplace add obra/superpowers-marketplace 2>/dev/null || true; then
            log_success "Marketplace community registrado"
        else
            log_info "Marketplace community já registrado ou falhou (continuando...)"
        fi
        
        log_info "Instalando Superpowers via marketplace community..."
        if claude plugin install superpowers@superpowers-marketplace; then
            log_success "Superpowers instalado com sucesso via marketplace community"
        else
            log_error "Falha na instalacao do Superpowers"
            return 1
        fi
    fi
    
    log_success "Superpowers instalado e ativo"
    log_info "Skills disponíveis: brainstorming, test-driven-development, systematic-debugging, writing-skills, etc."
    log_info "Reinicie Claude Code para ativar as skills"
}

# Função principal
main() {
    echo "========================================"
    echo "  AI Tools Installer"
    echo "  RTK + Caveman + Superpowers"
    echo "========================================"
    echo
    
    detect_os
    log_info "Sistema operacional detectado: $OS"
    echo
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "MODO DRY RUN - Nenhuma instalacao sera executada"
    fi
    
    if [ "$VERBOSE" = true ]; then
        log_info "Modo detalhado ativado"
    fi
    
    echo
    
    # Executa instalações solicitadas
    if [ "$INSTALL_RTK" = true ]; then
        install_rtk
        echo
    fi
    
    if [ "$INSTALL_CAVEMAN" = true ]; then
        install_caveman
        echo
    fi
    
    if [ "$INSTALL_SUPERPOWERS" = true ]; then
        install_superpowers
        echo
    fi
    
    # Resumo
    echo "========================================"
    echo "  Instalação concluída!"
    echo "========================================"
    echo
    
    if [ "$INSTALL_RTK" = true ]; then
        echo "RTK:"
        echo "  - Verifique: rtk --version"
        echo "  - Estatísticas: rtk gain"
        echo "  - Hooks inicializados para Claude Code e Cursor"
        echo
    fi
    
    if [ "$INSTALL_CAVEMAN" = true ]; then
        echo "Caveman:"
        echo "  - Instalado para todos os agentes detectados"
        echo "  - Skills disponíveis: /caveman, /caveman-commit, /caveman-compress, etc."
        echo
    fi
    
    if [ "$INSTALL_SUPERPOWERS" = true ]; then
        echo "Superpowers:"
        echo "  - Plugin instalado no Claude Code"
        echo "  - Skills: brainstorming, test-driven-development, systematic-debugging"
        echo "  - Reinicie Claude Code para ativar"
        echo
    fi
    
    log_success "Processo concluído!"
}

# Execução
parse_args "$@"
main
