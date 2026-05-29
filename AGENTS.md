# AGENTS.md

## Missão

**agents-skills** — Coleção comunitária de skills, rules e knowledge para agentes de IA, seguindo princípios de harness engineering da OpenAI e especificação Agent Skills (agentskills.io).

## Stack Tecnológica

| Camada | Tecnologia | Versão |
|--------|-----------|--------|
| Scripts | Shell (Bash) | 5.x |
| Documentação | Markdown + YAML | — |
| MCP | Model Context Protocol | — |
| Lint | ShellCheck | — |
| Licença | MIT | — |

## Estrutura do Projeto

```
agents-skills/
├── skills/           # Agent Skills (SKILL.md format) — 85+
├── rules/            # Path-specific coding standards (.instructions.md) — 107+
├── agents/           # GitHub Copilot agent definitions
├── workflows/        # Agentic workflows for automation
├── knowledge/        # Knowledge base (structured docs) — 23+
├── .agents/          # Infraestrutura de agentes
│   ├── CONTEXT.md    # Estratégias de carregamento de contexto
│   ├── RULES.md      # Guardrails (hard/soft rules)
│   ├── MEMORY.md     # Estado cross-session
│   ├── TOOLS.md      # Ferramentas e MCP
│   ├── WORKFLOWS.md  # Automação
│   └── README.md     # Documentação do harness
├── install.sh        # Installation script (--all, --devin, --claude, etc.)
├── clear-up-linux.sh # System cleanup utility
├── git-cleanup-repos.sh # Git repo optimization
└── llms.txt          # LLM discoverability
```

## Caminhos por Plataforma

| Plataforma | Config Principal | Skills | Rules |
|-----------|-----------------|--------|-------|
| Base (todas) | `AGENTS.md` | `.agents/skills/`, `skills/` | `.agents/RULES.md`, `rules/` |
| Claude Code | `CLAUDE.md` | auto-loaded | `.agents/RULES.md` |
| Devin | `AGENTS.md` | `skills/` | `rules/` |
| Windsurf | `AGENTS.md` | `skills/` | `rules/*.instructions.md` |

## Comandos

```bash
# Instalar para todos os IDEs/CLIs
./install.sh --all

# Instalar para ferramenta específica
./install.sh --devin
./install.sh --claude

# Lint dos scripts
shellcheck install.sh rm-backup.sh git-cleanup-repos.sh clear-up-linux.sh

# Validar instalação
test -d ~/.agents/skills && test -f ~/.devin/AGENTS.md && echo "PASS" || echo "FAIL"
```

## Padrões de Código

### DO (Faça)
- Skills devem ter `SKILL.md` com YAML frontmatter (`name`, `description`)
- Rules devem usar extensão `.instructions.md` com `applyTo` glob
- Nomes de pasta: lowercase kebab-case, máx 64 chars
- Scripts shell devem passar no ShellCheck
- Documentação em inglês (repositório internacional)
- Seguir especificação agentskills.io

### DON'T (Não Faça)
- Não criar skills sem `SKILL.md`
- Não duplicar conteúdo entre AGENTS.md e arquivos referenciados
- Não assumir plataforma específica em skills genéricas
- Não commitar secrets
- Não criar assets > 5MB por skill

## Hard Rules

1. **SKILL.md obrigatório**: toda skill deve ter SKILL.md válido
2. **Naming convention**: folder name = `name` field no frontmatter
3. **Secrets**: nunca commitar `.env`, tokens ou credenciais
4. **Forward-only deps**: sem dependências circulares entre skills
5. **AGENTS.md como index**: máx 500 linhas, referenciar não duplicar

## Soft Rules

1. Adicionar nova skill → seguir padrão existente
2. Modificar `install.sh` → testar com `--all`
3. Alterar knowledge → manter consistência cross-referência
4. Scripts de cleanup → sempre oferecer `--dry-run`

## Agent Loop

> Padrão: **ReAct** (Observe → Think → Act → Verify)

```
1. Receber tarefa
2. Carregar AGENTS.md + RULES.md
3. Identificar skills/rules/knowledge relevantes
4. Implementar alteração
5. Executar lint: shellcheck
6. Validar instalação: ./install.sh --devin
7. Criar PR
```

## Response Style

- Idioma: Inglês para código e docs do repositório
- Conciso e direto
- Commits: `feat:`, `fix:`, `docs:`, `refactor:`

## Core Principles

**Humans direct. Agents execute.**

- AGENTS.md como index (~100 linhas), não enciclopédia
- Knowledge em docs estruturados com validação mecânica
- Arquitetura rígida com dependências forward-only
- Garbage collection contínuo para débito técnico

## Referências

- `.agents/CONTEXT.md` — Estratégias de context engineering
- `.agents/RULES.md` — Guardrails detalhados
- `.agents/TOOLS.md` — Ferramentas e MCP
- `.agents/WORKFLOWS.md` — Automação
- `.agents/MEMORY.md` — Estado cross-session
- `knowledge/` — Knowledge base estruturada
- [Agent Skills Specification](https://agentskills.io)
- [Model Context Protocol](https://modelcontextprotocol.io)
