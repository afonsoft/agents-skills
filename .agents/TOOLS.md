# TOOLS.md — agents-skills

## Ferramentas Disponíveis

### Shell Scripts

| Script | Função | Risco |
|--------|--------|-------|
| `install.sh` | Instala skills + hooks + AGENTS.md para IDEs | Médio (modifica home) |
| `clear-up-linux.sh` | Limpeza do sistema Linux | Alto (remove arquivos) |
| `rm-backup.sh` | Remove backups antigos | Médio |
| `git-cleanup-repos.sh` | Otimiza repositórios Git | Médio |

### Flags Disponíveis

```bash
# install.sh
--all          # Instala para todos os IDEs
--base         # Apenas ~/.agents/skills
--devin        # Devin / Devin CLI
--claude       # Claude Code
--cursor       # Cursor
--windsurf     # Windsurf
--vscode       # VS Code / GitHub Copilot
--gemini       # Gemini CLI
--dry-run      # Simula execução sem modificar

# clear-up-linux.sh / git-cleanup-repos.sh
--dry-run      # Simula execução sem modificar
```

### Lint

| Ferramenta | Comando | Escopo |
|------------|---------|--------|
| ShellCheck | `shellcheck *.sh` | Scripts shell |

### MCP (Model Context Protocol)

Configuração em `mcp-config.json` quando disponível. Skills podem declarar dependências MCP:

```yaml
tools:
  - mcp:github
  - mcp:filesystem
```

## Categorias de Risco

| Categoria | Política |
|-----------|---------|
| **Read-only** (search, list, read) | Livre |
| **Write** (create, edit skills) | Requer PR |
| **Execute** (install.sh, cleanup) | Sandbox + logging |
| **External** (MCP, APIs) | Rate-limited |
