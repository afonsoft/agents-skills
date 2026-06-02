# RULES.md — agents-skills

## Hard Rules (bloqueio imediato)

1. **SKILL.md obrigatório**: toda skill DEVE ter SKILL.md com YAML frontmatter válido
2. **Naming convention**: `name` no frontmatter = nome da pasta (lowercase kebab-case, ≤64 chars)
3. **Secrets proibidos**: nunca commitar `.env`, tokens, API keys ou credenciais
4. **Forward-only dependencies**: skills não podem depender circularmente umas das outras
5. **Asset size limit**: nenhum asset > 5MB por skill
6. **Branch protegida**: `main` — merge apenas via PR
7. **AGENTS.md ≤ 500 linhas**: index, não enciclopédia

## Soft Rules (warning + confirmação)

1. Modificar `install.sh` → testar com `--all` e `--dry-run`
2. Deletar skills existentes → requer justificativa
3. Modificar scripts de cleanup → testar com `--dry-run`
4. Adicionar nova plataforma → atualizar paths-reference.md

## Permissões por Ambiente

| Operação | Dev | CI |
|----------|-----|-----|
| Criar skills | Livre | N/A |
| Modificar install.sh | Livre | Read-only |
| Executar cleanup | Dry-run primeiro | Proibido |
| Push para main | Proibido (usar PR) | Proibido |

## Tool Permissions

- **Read-only por padrão**: grep, search, list, read
- **Write via review**: create_file, replace_string (requer PR review)
- **Execute em sandbox**: install.sh, clear-up-linux.sh (com logging)
- **Proibido**: rm -rf sem --dry-run, push direto em main
