# CONTEXT.md — agents-skills

## Estratégias de Carregamento de Contexto

### Hierarquia de Prioridade

| Tipo | Quando | Exemplos |
|------|--------|----------|
| **Always-on** | Sempre carregado | AGENTS.md, .agents/RULES.md |
| **On-demand** | Quando solicitado | skills/{nome}/SKILL.md |
| **Progressive disclosure** | Codebases grandes | Mapa de dirs → headers → conteúdo |

### Token Budget

- Reservar 20% para output do agente
- AGENTS.md + .agents/RULES.md: ~2k tokens (always-on)
- Skills: ~1-3k tokens cada (on-demand)

### Estratégia de Chunking

- Arquivos > 500 linhas: dividir em seções lógicas
- Skills são autocontidas (sem dependências externas)
- Catálogo de skills injetado no session-start; cada SKILL.md carregado on-demand

### Context Compaction

```
Budget reduction → snip → microcompact → collapse → auto-compact
```

1. **Snip**: remover exemplos redundantes
2. **Microcompact**: comprimir listas em tabelas
3. **Collapse**: manter apenas headers + links
4. **Auto-compact**: delegar ao agente a seleção de contexto
