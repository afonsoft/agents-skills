# Hooks — Agent Skills

## Escopo

Hooks de sessao que injetam contexto do catalogo de skills no inicio de cada sessao do agente. Tambem inclui hooks de rewrite RTK para otimizacao automatica de tokens.

Cada subdiretorio contem os artefatos especificos de uma IDE/agente:

- **[`claude/`](claude/)** — Shell hook (`SessionStart`), hooks.json, RTK rewrite/suggest hooks
- **[`cursor/`](cursor/)** — Shell hook (`sessionStart`), hooks.json (formato Cursor)
- **[`opencode/`](opencode/)** — Shell hook (`sessionStart`), hooks.json (formato Cursor/OpenCode)
- **[`vscode/`](vscode/)** — Shell hook (`sessionStart`), hooks.json (formato Copilot)
- **[`devin/`](devin/)** — Shell hook de session-start
- **[`gemini/`](gemini/)** — Shell hook de session-start
- **[`antigravity/`](antigravity/)** — Shell hook de session-start (Google Antigravity IDE)
- **[`agy/`](agy/)** — Shell hook de session-start (Google Antigravity CLI)
- **[`opencode/`](opencode/)** — Plugin directory only for OpenCode (uses plugin system natively; no shell session hooks)

## Como funciona

```
Agente inicia sessao
  -> Hook SessionStart intercepta
  -> Le SKILL.md dos skills instalados (~/.agents/skills/)
  -> Injeta catalogo como contexto adicional
  -> Agente recebe lista de skills ao iniciar
```

## Instalacao

```bash
./install.sh --all    # Instala hooks para todas as IDEs
./install.sh --claude # Instala hooks apenas para Claude Code
```

O `install.sh` copia os hooks do subdiretorio correspondente para o diretorio de configuracao de cada IDE.

## Agentes suportados

| Agente | Mecanismo | Session Hook | RTK Rewrite |
|--------|-----------|-------------|-------------|
| Claude Code | Shell hook (`SessionStart`) | Sim | Sim (rewrite + suggest) |
| Cursor | Shell hook (`sessionStart`) | Sim | Sim (rewrite) |
| OpenCode | Shell hook (`sessionStart`) | Sim | Nao (rules file) |
| VS Code / Copilot | Shell hook (`sessionStart`) | Sim | Nao |
| Devin / Devin Desktop / Devin CLI | Shell hook | Sim | Nao |
| Gemini CLI | Shell hook | Sim | Nao |
| Google Antigravity IDE | Shell hook | Sim | Nao |
| Google Antigravity CLI (agy) | Shell hook | Sim | Nao |
| OpenCode | Plugin / `skill` tool nativo | Nao (skill discovery automatica) | Nao |
