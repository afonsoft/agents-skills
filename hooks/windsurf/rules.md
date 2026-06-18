# RTK — Regras para Windsurf

Ao executar comandos shell, prefira usar `rtk` como prefixo para otimizacao de tokens:

- `rtk git status` em vez de `git status`
- `rtk git diff` em vez de `git diff`
- `rtk cargo test` em vez de `cargo test`
- `rtk ls` em vez de `ls -la`
- `rtk read file` em vez de `cat file`
- `rtk grep pattern .` em vez de `grep pattern .`

RTK reduz tokens em 60-90% via filtragem inteligente. Use `rtk proxy <cmd>` quando precisar do output bruto completo.
