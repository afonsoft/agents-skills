# Remoção de `rules/`

## Ação
- Pasta `rules/` removida por completo: **107** arquivos `*.instructions.md` (`git rm -r rules`).

## Referências a `rules` a tratar (em scripts/docs)
- `install.sh` → reescrito (nova versão não instala rules).
- `rm-backup.sh` → revisado (não referencia rules de forma essencial).
- `AGENTS.md` → tabelas/estrutura atualizadas para remover `rules/`.
- `CLAUDE.md` → remover menção a `rules/*.instructions.md`.
- `README.md` → remover seção/estrutura de rules e estatística "107+ rules".
- `.agents/` (`README.md`, `RULES.md`, `skills-spec.md`, `paths-reference.md`) → remover referências de instalação/cópia de rules.
- `llms.txt` → remover entradas de rules.

## Nota
`.agents/RULES.md` (guardrails do harness, hard/soft rules do repositório) **não** é a pasta `rules/`; é mantido como guia interno do harness, mas limpo de referências à pasta `rules/` removida.
