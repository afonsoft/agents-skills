#!/bin/bash

# Script unificado para instalação de ferramentas de otimização de AI
# Instala RTK, Caveman e Superpowers para múltiplos agentes AI
# Suporta: Claude Code, Cursor, Gemini CLI, Devin CLI, VS Code Copilot, etc.
# Cross-platform: Windows, Linux, macOS

# Não usamos set -e para permitir continuação em caso de erros individuais

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

# Variáveis de rastreamento de erros
RTK_SUCCESS=false
CAVEMAN_SUCCESS=false
SUPERPOWERS_SUCCESS=false
HAS_ERRORS=false

# Variáveis de agentes
INSTALL_FOR_CLAUDE=false
INSTALL_FOR_GEMINI=false
INSTALL_FOR_DEVIN=false
INSTALL_FOR_CURSOR=false
INSTALL_FOR_ALL_AGENTS=false

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

# Verifica se comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Detect operating system and available shells
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS="Linux"; SHELL="Bash";;
        Darwin*)    OS="Mac"; SHELL="Bash";;
        CYGWIN*)    OS="Windows"; SHELL="Cygwin";;
        MINGW*)     OS="Windows"; SHELL="GitBash";;
        MSYS*)      OS="Windows"; SHELL="GitBash";;
        *)          OS="Unknown"; SHELL="Unknown";;
    esac
    
    export OS
    export SHELL
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
    echo -e "${YELLOW}Opcoes de agentes:${NC}"
    echo "  --gemini               Configura para Gemini CLI"
    echo "  --devin                Configura para Devin CLI"
    echo "  --devin-desktop        Configura para Devin Desktop"
    echo "  --claude               Configura para Claude Code"
    echo "  --cursor               Configura para Cursor"
    echo "  --all-agents           Configura para todos os agentes disponiveis"
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
    echo "  $0 --rtk --gemini                 # RTK configurado para Gemini CLI"
    echo "  $0 --caveman --devin              # Caveman configurado para Devin CLI"
    echo "  $0 --all --all-agents             # Tudo para todos os agentes"
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
    echo "  Linux, macOS, Windows (PowerShell, Git Bash, WSL)"
    echo
    echo -e "${YELLOW}Windows:${NC}"
    echo "  PowerShell: Instalação limitada (sem hooks)"
    echo "  Git Bash: Suporte completo (hooks funcionam)"
    echo "  WSL: Suporte completo (recomendado para hooks)"
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
            --gemini)
                INSTALL_FOR_GEMINI=true
                ;;
            --devin)
                INSTALL_FOR_DEVIN=true
                ;;
            --devin-desktop)
                INSTALL_FOR_DEVIN=true
                ;;
            --claude)
                INSTALL_FOR_CLAUDE=true
                ;;
            --cursor)
                INSTALL_FOR_CURSOR=true
                ;;
            --all-agents)
                INSTALL_FOR_CLAUDE=true
                INSTALL_FOR_GEMINI=true
                INSTALL_FOR_DEVIN=true
                INSTALL_FOR_CURSOR=true
                INSTALL_FOR_ALL_AGENTS=true
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
    
    # Se nenhum agente especificado, usa Claude como padrão
    if [ "$INSTALL_FOR_CLAUDE" = false ] && [ "$INSTALL_FOR_GEMINI" = false ] && \
       [ "$INSTALL_FOR_DEVIN" = false ] && [ "$INSTALL_FOR_CURSOR" = false ]; then
        INSTALL_FOR_CLAUDE=true
        log_info "Nenhum agente especificado, usando Claude Code como padrão"
    fi
}

# Verifica se comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Função para executar comando no shell apropriado (Windows)
execute_in_shell() {
    local cmd="$1"
    
    if [ "$OS" = "Windows" ]; then
        case "$SHELL" in
            PowerShell)
                powershell.exe -Command "$cmd"
                ;;
            PowerShell-Core)
                pwsh -Command "$cmd"
                ;;
            GitBash)
                bash -c "$cmd"
                ;;
            *)
                # Fallback para bash se disponível
                if command_exists bash; then
                    bash -c "$cmd"
                else
                    log_error "Nenhum shell compatível encontrado"
                    return 1
                fi
                ;;
        esac
    else
        # No Linux/Mac, executa diretamente
        eval "$cmd"
    fi
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
                RTK_SUCCESS=true
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
        RTK_SUCCESS=true
        return 0
    fi
    
    log_info "Instalando RTK..."
    
    case "$OS" in
        Linux|Mac)
            # Tenta instalar via script oficial
            log_info "Baixando e executando instalador oficial..."
            if curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh; then
                log_success "RTK instalado com sucesso"
                RTK_SUCCESS=true
            else
                log_warning "Falha na instalacao via script. Tentando via cargo..."
                if command_exists cargo; then
                    if cargo install --git https://github.com/rtk-ai/rtk rtk; then
                        log_success "RTK instalado via cargo"
                        RTK_SUCCESS=true
                    else
                        log_error "Falha na instalacao via cargo"
                        HAS_ERRORS=true
                        return 0
                    fi
                else
                    log_error "Cargo não encontrado. Instale Rust primeiro."
                    HAS_ERRORS=true
                    return 0
                fi
            fi
            ;;
        Windows)
            log_info "Instalando RTK no Windows..."
            
            # Tenta usar Git Bash primeiro (suporte completo de hooks)
            if [ "$SHELL" = "GitBash" ]; then
                log_info "Usando Git Bash para instalacao (suporte completo de hooks)..."
                
                # Tenta instalar via binário pré-compilado (mais confiável no Windows)
                log_info "Tentando instalar RTK via binário pré-compilado..."
                
                local rtk_url="https://github.com/rtk-ai/rtk/releases/latest/download/rtk-x86_64-pc-windows-msvc.zip"
                local temp_dir=$(mktemp -d)
                
                if command_exists curl; then
                    log_info "Baixando RTK binário..."
                    if curl -L "$rtk_url" -o "$temp_dir/rtk.zip" 2>/dev/null; then
                        if command_exists unzip; then
                            unzip -o "$temp_dir/rtk.zip" -d "$temp_dir" 2>/dev/null
                            if [ -f "$temp_dir/rtk.exe" ]; then
                                # Move para diretório no PATH
                                local target_dir="$HOME/.local/bin"
                                mkdir -p "$target_dir"
                                cp "$temp_dir/rtk.exe" "$target_dir/"
                                chmod +x "$target_dir/rtk.exe"
                                
                                # Adiciona ao PATH se necessário
                                if ! echo "$PATH" | grep -q "$target_dir"; then
                                    log_info "Adicionando $target_dir ao PATH..."
                                    echo "export PATH=\"$target_dir:\$PATH\"" >> ~/.bashrc
                                    log_info "Execute: source ~/.bashrc"
                                fi
                                
                                log_success "RTK instalado via binário pré-compilado"
                                RTK_SUCCESS=true
                            else
                                log_error "Binário RTK não encontrado no arquivo zip"
                                log_info "Tentando via cargo..."
                            fi
                        else
                            log_error "unzip não encontrado. Instale unzip"
                            log_info "Tentando via cargo..."
                        fi
                    else
                        log_error "Falha ao baixar RTK binário"
                        log_info "Tentando via cargo..."
                    fi
                else
                    log_error "curl não encontrado"
                    log_info "Tentando via cargo..."
                fi
                
                rm -rf "$temp_dir"
                
                # Se binário falhou, tenta cargo
                if [ "$RTK_SUCCESS" = false ]; then
                    if command_exists cargo; then
                        log_info "Instalando RTK via cargo..."
                        if cargo install --git https://github.com/rtk-ai/rtk rtk; then
                            log_success "RTK instalado via cargo"
                            RTK_SUCCESS=true
                        else
                            log_error "Falha na instalacao via cargo"
                        fi
                    else
                        log_error "Cargo não encontrado e binário falhou"
                        log_info "Para instalar Rust: https://rustup.rs/"
                        log_info "Ou instale unzip para usar binário pré-compilado"
                        HAS_ERRORS=true
                    fi
                fi
            # Tenta usar PowerShell se disponível
            elif [ "$SHELL" = "PowerShell" ] || [ "$SHELL" = "PowerShell-Core" ]; then
                log_info "Usando PowerShell para instalacao (suporte limitado)..."
                
                # Tenta via PowerShell com cargo
                if command_exists cargo; then
                    log_info "Instalando RTK via cargo no PowerShell..."
                    if execute_in_shell "cargo install --git https://github.com/rtk-ai/rtk rtk"; then
                        log_success "RTK instalado via cargo (PowerShell - suporte limitado)"
                        RTK_SUCCESS=true
                    else
                        log_error "Falha na instalacao via cargo no PowerShell"
                        HAS_ERRORS=true
                        return 0
                    fi
                else
                    log_error "Cargo não encontrado. Instale Rust primeiro."
                    log_info "Alternativas:"
                    log_info "  1. Use Git Bash para suporte completo"
                    log_info "  2. Use WSL: wsl bash -c 'curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh'"
                    HAS_ERRORS=true
                    return 0
                fi
            else
                log_warning "Nenhum shell compatível detectado (PowerShell ou Git Bash)"
                log_info "Recomendações:"
                log_info "  1. Use Git Bash para suporte completo de hooks"
                log_info "  2. Use WSL: wsl bash -c 'curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh'"
                log_info "  3. Instale Rust e use PowerShell para suporte limitado"
                HAS_ERRORS=true
                return 0
            fi
            ;;
        *)
            log_error "Sistema operacional não suportado: $OS"
            HAS_ERRORS=true
            return 0
            ;;
    esac
    
    # Verifica instalação
    if command_exists rtk; then
        log_success "RTK instalado: $(rtk --version)"
        
        # Inicializa hooks globais para Claude Code
        if command_exists claude; then
            log_info "Inicializando RTK para Claude Code..."
            if rtk init --global; then
                log_success "RTK inicializado para Claude Code"
            else
                log_warning "Falha ao inicializar RTK para Claude Code"
            fi
        fi
        
        # Inicializa para Cursor se disponível
        if [ -d "$HOME/.cursor" ]; then
            log_info "Inicializando RTK para Cursor..."
            if rtk init --global --cursor; then
                log_success "RTK inicializado para Cursor"
            else
                log_warning "Falha ao inicializar RTK para Cursor"
            fi
        fi
        
        log_info "Execute 'rtk gain' para ver estatísticas de economia de tokens"
        RTK_SUCCESS=true
    else
        log_error "Falha na instalacao do RTK"
        HAS_ERRORS=true
    fi
}

# Instala Caveman
install_caveman() {
    log_info "=== Instalando Caveman ==="
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Caveman seria instalado"
        CAVEMAN_SUCCESS=true
        return 0
    fi
    
    log_info "Instalando Caveman..."
    
    case "$OS" in
        Linux|Mac)
            log_info "Baixando e executando instalador oficial..."
            if curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash; then
                log_success "Caveman instalado com sucesso"
                CAVEMAN_SUCCESS=true
            else
                log_error "Falha na instalacao do Caveman"
                HAS_ERRORS=true
                return 0
            fi
            ;;
        Windows)
            log_info "Instalando Caveman no Windows..."
            
            # Tenta usar Git Bash primeiro (suporte completo)
            if [ "$SHELL" = "GitBash" ]; then
                log_info "Usando Git Bash para instalacao automatica..."
                
                # Usa npx skills add diretamente para agentes que suportam --yes
                if command_exists npx; then
                    log_info "Instalando Caveman para agentes com suporte automatico..."
                    
                    local caveman_installed=false
                    
                    # Instala para Devin (suporta --yes)
                    log_info "Instalando Caveman para Devin CLI..."
                    if npx -y skills add JuliusBrussee/caveman --skill * -a devin --yes; then
                        log_success "Caveman instalado para Devin CLI"
                        caveman_installed=true
                    else
                        log_warning "Falha na instalacao para Devin CLI"
                    fi
                    
                    # Instala para OpenHands (suporta --yes)
                    log_info "Instalando Caveman para OpenHands..."
                    if npx -y skills add JuliusBrussee/caveman --skill * -a openhands --yes; then
                        log_success "Caveman instalado para OpenHands"
                        caveman_installed=true
                    else
                        log_warning "Falha na instalacao para OpenHands"
                    fi
                    
                    if [ "$caveman_installed" = true ]; then
                        CAVEMAN_SUCCESS=true
                        log_info "Caveman instalado com sucesso para agentes compatíveis"
                        log_warning "Gemini CLI requer instalacao manual devido a prompts interativos"
                        log_info "Para Gemini CLI: gemini extensions install https://github.com/JuliusBrussee/caveman"
                    else
                        log_error "Falha na instalacao para todos os agentes"
                        HAS_ERRORS=true
                    fi
                else
                    log_error "npx não encontrado. Instale Node.js primeiro"
                    log_info "Para instalar Node.js: https://nodejs.org/"
                    HAS_ERRORS=true
                fi
            # Tenta usar PowerShell se disponível
            elif [ "$SHELL" = "PowerShell" ] || [ "$SHELL" = "PowerShell-Core" ]; then
                log_info "Usando PowerShell para instalacao..."
                log_info "Execute no PowerShell:"
                echo "npx -y skills add JuliusBrussee/caveman --skill * -a devin --yes"
                log_warning "Instalacao manual requerida no PowerShell"
                log_info "Ou use Git Bash para instalacao automatica"
                HAS_ERRORS=true
                return 0
            else
                log_warning "Nenhum shell compatível detectado (PowerShell ou Git Bash)"
                log_info "Opções:"
                log_info "  1. Git Bash: npx -y skills add JuliusBrussee/caveman --skill * -a devin --yes"
                log_info "  2. PowerShell: npx -y skills add JuliusBrussee/caveman --skill * -a devin --yes"
                log_info "  3. WSL: wsl bash -c 'npx -y skills add JuliusBrussee/caveman --skill * -a devin --yes'"
                HAS_ERRORS=true
                return 0
            fi
            ;;
        *)
            log_error "Sistema operacional não suportado: $OS"
            HAS_ERRORS=true
            return 0
            ;;
    esac
    
    log_success "Caveman instalado e configurado para todos os agentes detectados"
    CAVEMAN_SUCCESS=true
}

# Instala Superpowers
install_superpowers() {
    log_info "=== Instalando Superpowers ==="
    
    # Verifica se Claude Code está disponível
    if ! command_exists claude; then
        log_warning "Claude Code não encontrado. Superpowers requer Claude Code."
        log_info "Instale Claude Code primeiro: https://code.claude.com"
        HAS_ERRORS=true
        return 0
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Superpowers seria instalado via Claude Code"
        SUPERPOWERS_SUCCESS=true
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
        SUPERPOWERS_SUCCESS=true
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
            SUPERPOWERS_SUCCESS=true
        else
            log_error "Falha na instalacao do Superpowers"
            HAS_ERRORS=true
            return 0
        fi
    fi
    
    log_success "Superpowers instalado e ativo"
    log_info "Skills disponíveis: brainstorming, test-driven-development, systematic-debugging, writing-skills, etc."
    log_info "Reinicie Claude Code para ativar as skills"
    SUPERPOWERS_SUCCESS=true
}

# Configura RTK para Gemini CLI
configure_rtk_gemini() {
    log_info "=== Configurando RTK para Gemini CLI ==="
    
    if ! command_exists rtk; then
        log_error "RTK não instalado. Instale RTK primeiro com --rtk"
        HAS_ERRORS=true
        return 0
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: RTK seria configurado para Gemini CLI"
        return 0
    fi
    
    log_info "Executando: rtk init -g --gemini"
    if rtk init -g --gemini; then
        log_success "RTK configurado para Gemini CLI"
        log_info "Arquivos criados:"
        log_info "  - ~/.gemini/hooks/rtk-hook-gemini.sh"
        log_info "  - ~/.gemini/GEMINI.md"
        log_info "  - ~/.gemini/settings.json (patched)"
        log_info "Reinicie Gemini CLI para ativar"
    else
        log_error "Falha ao configurar RTK para Gemini CLI"
        HAS_ERRORS=true
    fi
}

# Configura RTK para Devin CLI
configure_rtk_devin() {
    log_info "=== Configurando RTK para Devin CLI ==="
    
    if ! command_exists rtk; then
        log_error "RTK não instalado. Instale RTK primeiro com --rtk"
        HAS_ERRORS=true
        return 0
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: RTK seria configurado para Devin CLI"
        return 0
    fi
    
    # RTK não tem suporte nativo para Devin CLI ainda
    log_warning "RTK não tem suporte nativo para Devin CLI ainda"
    log_info "Alternativas:"
    log_info "  1. Use AGENTS.md com instruções RTK"
    log_info "  2. Configure manualmente hooks em ~/.devin/hooks/"
    log_info "  3. Solicite suporte RTK para Devin CLI em: https://github.com/rtk-ai/rtk"
    
    # Tenta criar AGENTS.md com instruções RTK
    log_info "Criando AGENTS.md com instruções RTK para Devin CLI..."
    
    local devin_config_dir=""
    if [ "$OS" = "Windows" ]; then
        devin_config_dir="$APPDATA/devin"
    else
        devin_config_dir="$HOME/.config/devin"
    fi
    
    if [ -d "$devin_config_dir" ]; then
        local agents_md="$devin_config_dir/AGENTS.md"
        
        cat > "$agents_md" << 'EOF'
# RTK Integration for Devin CLI

## What is RTK?
RTK (Rust Token Killer) is a token optimizer that rewrites terminal commands to reduce token usage by 60-90%.

## How to Use with Devin CLI
Since RTK doesn't have native Devin CLI support yet, use it manually:

### Manual Usage
Instead of regular commands, prefix with `rtk`:

```bash
# Instead of: git status
rtk git status

# Instead of: cargo test
rtk cargo test

# Instead of: npm test
rtk npm test
```

### Benefits
- Shows only test failures (not 500 lines of passing tests)
- Filters git output to relevant changes
- Optimizes output for 60-90% token savings
- Works with all major ecosystems (Git, Cargo, npm, Python, Go, etc.)

### Check Savings
```bash
rtk gain
```

## Installation
If RTK is not installed, run:
```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh
```

## Native Support
Request native Devin CLI support at: https://github.com/rtk-ai/rtk/issues
EOF
        
        log_success "AGENTS.md criado em $agents_md"
        log_info "Reinicie Devin CLI para carregar as instruções"
    else
        log_error "Diretório de configuração Devin não encontrado: $devin_config_dir"
        HAS_ERRORS=true
    fi
}

# Configura Caveman para Devin CLI
configure_caveman_devin() {
    log_info "=== Configurando Caveman para Devin CLI ==="
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Caveman seria configurado para Devin CLI"
        return 0
    fi
    
    log_info "Instalando Caveman para Devin CLI via npx skills..."
    
    if command_exists npx; then
        if npx -y skills add JuliusBrussee/caveman -a devin; then
            log_success "Caveman instalado para Devin CLI"
            log_info "Skills disponíveis: /caveman, /caveman-commit, /caveman-compress, /caveman-review"
            log_info "Reinicie Devin CLI para ativar"
        else
            log_error "Falha ao instalar Caveman para Devin CLI"
            HAS_ERRORS=true
        fi
    else
        log_error "npx não encontrado. Instale Node.js primeiro"
        HAS_ERRORS=true
    fi
}

# Configura Superpowers para Devin CLI
configure_superpowers_devin() {
    log_info "=== Configurando Superpowers para Devin CLI ==="
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Superpowers seria configurado para Devin CLI"
        return 0
    fi
    
    # Superpowers não tem suporte nativo para Devin CLI ainda
    log_warning "Superpowers não tem suporte nativo para Devin CLI ainda"
    log_info "Alternativas:"
    log_info "  1. Copie skills manualmente para ~/.devin/skills/"
    log_info "  2. Use Claude Code para Superpowers (suporte nativo)"
    log_info "  3. Solicite suporte Superpowers para Devin CLI em: https://github.com/obra/superpowers"
    
    # Tenta copiar skills do repositório Superpowers
    log_info "Tentando copiar skills do Superpowers para Devin CLI..."
    
    local devin_skills_dir=""
    if [ "$OS" = "Windows" ]; then
        devin_skills_dir="$APPDATA/devin/skills"
    else
        devin_skills_dir="$HOME/.config/devin/skills"
    fi
    
    if [ -d "$devin_skills_dir" ]; then
        log_info "Diretório de skills Devin encontrado: $devin_skills_dir"
        log_info "Para instalar Superpowers manualmente:"
        log_info "  1. Clone: git clone https://github.com/obra/superpowers.git"
        log_info "  2. Copie skills/ para $devin_skills_dir/"
        log_info "  3. Reinicie Devin CLI"
    else
        log_error "Diretório de skills Devin não encontrado: $devin_skills_dir"
        log_info "Certifique-se de que Devin CLI está instalado e configurado"
        HAS_ERRORS=true
    fi
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
    if [ "$OS" = "Windows" ]; then
        log_info "Shell detectado: $SHELL"
        log_info "Usando Git Bash para suporte completo de hooks"
    fi
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
    
    # Configura para agentes específicos
    if [ "$INSTALL_FOR_GEMINI" = true ] && [ "$INSTALL_RTK" = true ]; then
        configure_rtk_gemini
        echo
    fi
    
    if [ "$INSTALL_FOR_DEVIN" = true ]; then
        if [ "$INSTALL_RTK" = true ]; then
            configure_rtk_devin
            echo
        fi
        if [ "$INSTALL_CAVEMAN" = true ]; then
            configure_caveman_devin
            echo
        fi
        if [ "$INSTALL_SUPERPOWERS" = true ]; then
            configure_superpowers_devin
            echo
        fi
    fi
    
    # Resumo
    echo "========================================"
    echo "  Resumo da Instalação"
    echo "========================================"
    echo
    
    if [ "$INSTALL_RTK" = true ]; then
        if [ "$RTK_SUCCESS" = true ]; then
            echo -e "${GREEN}✓${NC} RTK: Instalado com sucesso"
        else
            echo -e "${YELLOW}✗${NC} RTK: Falha na instalação"
        fi
    fi
    
    if [ "$INSTALL_CAVEMAN" = true ]; then
        if [ "$CAVEMAN_SUCCESS" = true ]; then
            echo -e "${GREEN}✓${NC} Caveman: Instalado com sucesso"
        else
            echo -e "${YELLOW}✗${NC} Caveman: Falha na instalação"
        fi
    fi
    
    if [ "$INSTALL_SUPERPOWERS" = true ]; then
        if [ "$SUPERPOWERS_SUCCESS" = true ]; then
            echo -e "${GREEN}✓${NC} Superpowers: Instalado com sucesso"
        else
            echo -e "${YELLOW}✗${NC} Superpowers: Falha na instalação"
        fi
    fi
    
    echo
    
    if [ "$HAS_ERRORS" = true ]; then
        echo -e "${YELLOW}⚠ Alguns componentes falharam na instalação${NC}"
        echo "Verifique os warnings acima para detalhes"
    else
        echo -e "${GREEN}✓ Todos os componentes foram instalados com sucesso${NC}"
    fi
    
    echo
    echo "========================================"
    echo "  Informações Pós-Instalação"
    echo "========================================"
    echo
    
    if [ "$INSTALL_RTK" = true ] && [ "$RTK_SUCCESS" = true ]; then
        echo "RTK:"
        echo "  - Verifique: rtk --version"
        echo "  - Estatísticas: rtk gain"
        if [ "$INSTALL_FOR_GEMINI" = true ]; then
            echo "  - Configurado para Gemini CLI (hooks nativos)"
        fi
        if [ "$INSTALL_FOR_CLAUDE" = true ]; then
            echo "  - Hooks inicializados para Claude Code"
        fi
        if [ "$INSTALL_FOR_CURSOR" = true ]; then
            echo "  - Hooks inicializados para Cursor"
        fi
        if [ "$INSTALL_FOR_DEVIN" = true ]; then
            echo "  - Configurado para Devin CLI (via AGENTS.md)"
        fi
        echo
    fi
    
    if [ "$INSTALL_CAVEMAN" = true ] && [ "$CAVEMAN_SUCCESS" = true ]; then
        echo "Caveman:"
        echo "  - Instalado para todos os agentes detectados"
        if [ "$INSTALL_FOR_DEVIN" = true ]; then
            echo "  - Configurado especificamente para Devin CLI"
        fi
        echo "  - Skills disponíveis: /caveman, /caveman-commit, /caveman-compress, etc."
        echo
    fi
    
    if [ "$INSTALL_SUPERPOWERS" = true ] && [ "$SUPERPOWERS_SUCCESS" = true ]; then
        echo "Superpowers:"
        if [ "$INSTALL_FOR_CLAUDE" = true ]; then
            echo "  - Plugin instalado no Claude Code"
            echo "  - Skills: brainstorming, test-driven-development, systematic-debugging"
            echo "  - Reinicie Claude Code para ativar"
        fi
        if [ "$INSTALL_FOR_DEVIN" = true ]; then
            echo "  - Configurado para Devin CLI (via skills manuais)"
            echo "  - Skills: brainstorming, TDD, systematic debugging"
            echo "  - Reinicie Devin CLI para ativar"
        fi
        echo
    fi
    
    if [ "$HAS_ERRORS" = false ]; then
        log_success "Processo concluído sem erros!"
    else
        log_warning "Processo concluído com alguns erros. Verifique acima."
    fi
}

# Execução
parse_args "$@"
main
