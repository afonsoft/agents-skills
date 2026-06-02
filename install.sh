#!/bin/bash

# Installer for agents-skills.
# Installs SKILLS + session-start HOOKS + AGENTS.md for the selected IDE/CLI.
# No rules and no knowledge are installed (the repo ships only skills + hooks).
#
# Usage:
#   ./install.sh --all, -a        Install for all supported IDEs/CLIs
#   ./install.sh --base, -b       Install only the base (~/.agents/skills)
#   ./install.sh --devin, -d      Install for Devin / Devin CLI
#   ./install.sh --claude         Install for Claude Code
#   ./install.sh --cursor, -c     Install for Cursor
#   ./install.sh --windsurf, -w   Install for Windsurf
#   ./install.sh --vscode, -v     Install for VS Code (GitHub Copilot)
#   ./install.sh --gemini, -g     Install for Gemini CLI
#   ./install.sh --dry-run        Show what would be done, change nothing
#   ./install.sh --help, -h       Show this help
#
# Multiple targets can be combined: ./install.sh --devin --claude

set -euo pipefail

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Target flags (base is always installed; --base just skips other targets)
INSTALL_VSCODE=false
INSTALL_WINDSURF=false
INSTALL_CURSOR=false
INSTALL_DEVIN=false
INSTALL_CLAUDE=false
INSTALL_GEMINI=false
DRY_RUN=false

# Resolve repo root (directory of this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    echo
    echo -e "${CYAN}agents-skills - installer${NC}"
    echo
    echo -e "${YELLOW}Usage:${NC} ./install.sh [options]"
    echo
    echo -e "${YELLOW}Targets:${NC}"
    echo "  --base,     -b   Only base (~/.agents/skills)"
    echo "  --devin,    -d   Devin / Devin CLI"
    echo "  --claude         Claude Code"
    echo "  --cursor,   -c   Cursor"
    echo "  --windsurf, -w   Windsurf"
    echo "  --vscode,   -v   VS Code (GitHub Copilot)"
    echo "  --gemini,   -g   Gemini CLI"
    echo "  --all,      -a   All of the above"
    echo
    echo -e "${YELLOW}Other:${NC}"
    echo "  --dry-run        Print actions without changing anything"
    echo "  --help, -h       Show this help"
    echo
    echo -e "${YELLOW}What gets installed (skills + hooks + AGENTS.md):${NC}"
    echo "  Base       ~/.agents/skills"
    echo "  Devin      ~/.agents/skills, ~/.devin/skills, ~/.cognition/skills, ~/.config/devin/skills"
    echo "             + ~/.devin/hooks + ~/.devin/AGENTS.md"
    echo "  Claude     ~/.claude/skills + ~/.claude/hooks + ~/.claude/CLAUDE.md + ~/.claude/AGENTS.md"
    echo "  Cursor     ~/.cursor/skills + ~/.cursor/hooks + ~/.cursor/AGENTS.md"
    echo "  Windsurf   ~/.windsurf/skills + ~/.windsurf/hooks + ~/.windsurf/AGENTS.md"
    echo "  VS Code    ~/.github/skills + ~/.github/hooks + ~/.github/AGENTS.md"
    echo "  Gemini     ~/.gemini/skills + ~/.gemini/hooks + ~/.gemini/AGENTS.md"
    echo
}

parse_args() {
    if [ $# -eq 0 ]; then show_help; exit 0; fi
    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)     show_help; exit 0 ;;
            --dry-run)     DRY_RUN=true ;;
            --all|-a)
                INSTALL_VSCODE=true; INSTALL_WINDSURF=true; INSTALL_CURSOR=true
                INSTALL_DEVIN=true; INSTALL_CLAUDE=true; INSTALL_GEMINI=true ;;
            --base|-b)     : ;;   # base is always installed; accepted for clarity
            --vscode|-v)   INSTALL_VSCODE=true ;;
            --windsurf|-w) INSTALL_WINDSURF=true ;;
            --cursor|-c)   INSTALL_CURSOR=true ;;
            --devin|-d)    INSTALL_DEVIN=true ;;
            --claude)      INSTALL_CLAUDE=true ;;
            --gemini|-g)   INSTALL_GEMINI=true ;;
            *) log_error "Unknown option: $1"; echo "Use --help."; exit 1 ;;
        esac
        shift
    done
}

# --- helpers (respect --dry-run) ---

run() {
    if [ "$DRY_RUN" = true ]; then echo "  + $*"; else "$@"; fi
}

backup_dir_if_exists() {
    local dir_path="$1"
    if [ -d "$dir_path" ] && [ -n "$(ls -A "$dir_path" 2>/dev/null)" ]; then
        local backup_path
        backup_path="${dir_path}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backup: $dir_path -> $backup_path"
        run mv "$dir_path" "$backup_path"
    fi
    run mkdir -p "$dir_path"
}

backup_file_if_exists() {
    local file_path="$1"
    if [ -f "$file_path" ]; then
        local backup_path
        backup_path="${file_path}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backup: $file_path -> $backup_path"
        run cp "$file_path" "$backup_path"
    fi
}

# install_skills_to <dest_dir>
install_skills_to() {
    local dest="$1"
    backup_dir_if_exists "$dest"
    run cp -a "$REPO_ROOT/skills/." "$dest/"
}

# install_hooks_to <ide> <dest_dir>
install_hooks_to() {
    local ide="$1" dest="$2"
    if [ -d "$REPO_ROOT/hooks/$ide" ]; then
        run mkdir -p "$dest"
        run cp -a "$REPO_ROOT/hooks/$ide/." "$dest/"
        # session-start-base.sh is sourced by the per-IDE hook
        run cp -a "$REPO_ROOT/hooks/session-start-base.sh" "$dest/"
    fi
}

# install_agents_md_to <dest_file>
install_agents_md_to() {
    local dest="$1"
    backup_file_if_exists "$dest"
    run cp "$REPO_ROOT/AGENTS.md" "$dest"
}

check_directory() {
    if [ ! -d "$REPO_ROOT/skills" ]; then
        log_error "skills/ folder not found next to install.sh."
        exit 1
    fi
}

# --- installers ---

install_base() {
    log_info "Base -> ~/.agents/skills"
    install_skills_to "$HOME/.agents/skills"
    log_success "Base installed"
}

install_devin() {
    log_info "=== Devin ==="
    # ~/.agents/skills already installed by install_base()
    install_skills_to "$HOME/.devin/skills"
    install_skills_to "$HOME/.cognition/skills"
    install_skills_to "$HOME/.config/devin/skills"
    install_hooks_to "devin" "$HOME/.devin/hooks"
    install_agents_md_to "$HOME/.devin/AGENTS.md"
    log_success "Devin installed"
}

install_claude() {
    log_info "=== Claude Code ==="
    install_skills_to "$HOME/.claude/skills"
    install_hooks_to "claude" "$HOME/.claude/hooks"
    backup_file_if_exists "$HOME/.claude/CLAUDE.md"
    run cp "$REPO_ROOT/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    install_agents_md_to "$HOME/.claude/AGENTS.md"
    log_success "Claude installed"
}

install_cursor() {
    log_info "=== Cursor ==="
    install_skills_to "$HOME/.cursor/skills"
    install_hooks_to "cursor" "$HOME/.cursor/hooks"
    install_agents_md_to "$HOME/.cursor/AGENTS.md"
    log_success "Cursor installed"
}

install_windsurf() {
    log_info "=== Windsurf ==="
    install_skills_to "$HOME/.windsurf/skills"
    install_hooks_to "windsurf" "$HOME/.windsurf/hooks"
    install_agents_md_to "$HOME/.windsurf/AGENTS.md"
    log_success "Windsurf installed"
}

install_vscode() {
    log_info "=== VS Code (GitHub Copilot) ==="
    install_skills_to "$HOME/.github/skills"
    install_hooks_to "vscode" "$HOME/.github/hooks"
    install_agents_md_to "$HOME/.github/AGENTS.md"
    log_success "VS Code installed"
}

install_gemini() {
    log_info "=== Gemini CLI ==="
    install_skills_to "$HOME/.gemini/skills"
    install_hooks_to "gemini" "$HOME/.gemini/hooks"
    install_agents_md_to "$HOME/.gemini/AGENTS.md"
    log_success "Gemini installed"
}

main() {
    parse_args "$@"
    check_directory
    [ "$DRY_RUN" = true ] && log_warning "DRY-RUN: no changes will be made"

    # base always runs unless a specific target already covers it
    install_base

    [ "$INSTALL_DEVIN" = true ]    && install_devin
    [ "$INSTALL_CLAUDE" = true ]   && install_claude
    [ "$INSTALL_CURSOR" = true ]   && install_cursor
    [ "$INSTALL_WINDSURF" = true ] && install_windsurf
    [ "$INSTALL_VSCODE" = true ]   && install_vscode
    [ "$INSTALL_GEMINI" = true ]   && install_gemini

    echo
    log_success "Done."
}

main "$@"
