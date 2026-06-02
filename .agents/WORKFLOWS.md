# WORKFLOWS.md — agents-skills

## Workflow: Adicionar Nova Skill

### Precondições
- Skill não existe em `skills/`
- Nome em lowercase kebab-case, ≤64 chars

### Passos
1. Criar diretório: `skills/{nome-da-skill}/`
2. Criar `SKILL.md` com YAML frontmatter (`name`, `description`)
3. Adicionar conteúdo (seções, exemplos, referências)
4. Opcional: adicionar `references/`, `templates/`, `scripts/`, `assets/`
5. Validar: `shellcheck install.sh` e `./install.sh --devin --dry-run`
6. Testar com IDE alvo
7. Criar PR

### Critério de Sucesso
- SKILL.md válido com frontmatter
- Folder name = `name` field
- Instalação sem erros

## Workflow: Adicionar Novo Workflow Agêntico

### Passos
1. Criar `workflows/{nome}.md` com frontmatter (`name`, `description`, `on`, `permissions`, `safe-outputs`)
2. Validar: `gh aw compile --validate --no-emit workflows/{nome}.md`
3. Criar PR

## Verification Loop

```
Agent Output → ShellCheck → install.sh --devin --dry-run → Validação → PR → Review
```

## Rollback

- Reverter PR via GitHub
- `install.sh --all` para reinstalar versão anterior (usa backups `*.backup.*`)
