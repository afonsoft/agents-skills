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
5. Validar: `./install.sh --all --verbose`
6. Testar com IDE alvo
7. Criar PR para `main`

### Critério de Sucesso
- SKILL.md válido com frontmatter
- Folder name = `name` field
- Instalação sem erros

## Workflow: Adicionar Nova Rule

### Precondições
- Rule não existe em `rules/`

### Passos
1. Criar `rules/{nome}.instructions.md`
2. Adicionar frontmatter com `description` e `applyTo`
3. Escrever conteúdo da rule
4. Criar PR para `main`

## Workflow: Atualizar Knowledge

### Passos
1. Identificar documento em `knowledge/`
2. Atualizar conteúdo
3. Verificar referências cruzadas
4. Criar PR para `main`

## Verification Loop

```
Agent Output → ShellCheck → install.sh --all → Validação → PR → Review
```

## Rollback

- Reverter PR via GitHub
- `install.sh --all` para reinstalar versão anterior
