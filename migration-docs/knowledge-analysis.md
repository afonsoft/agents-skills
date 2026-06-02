# Knowledge Analysis

Avaliação de `knowledge/` (23 arquivos). Conclusão: o conteúdo é majoritariamente **genérico/conhecido por LLM** e em grande parte derivado das `rules/` (removidas). Valor operacional específico após a limpeza ficou muito baixo → **pasta removida por completo** (sancionado pela Etapa 3: "Se o valor de knowledge ficar muito baixo após limpeza, é aceitável remover a pasta inteira"). Orientação de autoria de skills passa a viver na skill migrada `writing-skills`.

| Arquivo | Ação | Motivo | Ação executada |
|---|---|---|---|
| knowledge/SECURITY.md (1748L) | DROP | Playbook genérico de segurança, conhecido por LLM | removido |
| knowledge/DESIGN.md | DROP | Princípios de design genéricos | removido |
| knowledge/FRONTEND.md | DROP | Padrões de frontend genéricos | removido |
| knowledge/PLANS.md | DROP | Templates de planejamento genéricos | removido |
| knowledge/PRODUCT_SENSE.md | DROP | Princípios de produto genéricos | removido |
| knowledge/QUALITY_SCORE.md | DROP | Métricas de qualidade genéricas | removido |
| knowledge/RELIABILITY.md | DROP | Requisitos de confiabilidade genéricos | removido |
| knowledge/design-docs/index.md | DROP | Índice da pasta removida | removido |
| knowledge/design-docs/core-beliefs.md | DROP | Princípios agent-centered genéricos | removido |
| knowledge/design-docs/agent-skills-patterns.md | DROP | Coberto pela skill `writing-skills` migrada | removido |
| knowledge/design-docs/ai-development-patterns.md | DROP | Padrões de IA/ML genéricos | removido |
| knowledge/design-docs/coding-standards-compendium.md | DROP | Consolidação das `rules/` removidas | removido |
| knowledge/design-docs/database-design-patterns.md (1069L) | DROP | Padrões de banco genéricos | removido |
| knowledge/design-docs/devops-playbook.md (978L) | DROP | Playbook DevOps genérico | removido |
| knowledge/design-docs/frontend-architecture.md (1659L) | DROP | Arquitetura frontend genérica | removido |
| knowledge/design-docs/implementation-patterns.md | DROP | Padrões derivados das rules removidas | removido |
| knowledge/design-docs/microservices-patterns.md (907L) | DROP | Padrões de microsserviços genéricos | removido |
| knowledge/design-docs/testing-strategies.md (1454L) | DROP | Estratégias de teste genéricas | removido |
| knowledge/exec-plans/tech-debt-tracker.md | DROP | Tracker específico do repo, desatualizado pós-limpeza | removido |
| knowledge/references/index.md | DROP | Índice da pasta removida | removido |
| knowledge/references/abp-io-framework-guide.md | DROP | Guia genérico de framework (ABP.IO) | removido |
| knowledge/references/aspnetboilerplate-to-abp-migration-guide.md (968L) | DROP | Guia longo de framework; skill `migrate-aspnetboilerplate-to-abp` é autossuficiente | removido |
| knowledge/references/cloud-platforms-guide.md | DROP | Guia genérico de cloud | removido |

**KEEP:** nenhum. **REWRITE:** nenhum (todo o conteúdo caiu em DROP).
