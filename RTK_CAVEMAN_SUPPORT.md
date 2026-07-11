# RTK e Caveman - Status de Suporte por Plataforma

## RTK (Rust Token Killer)

### Suporte Oficial RTK
Baseado na documentação oficial do RTK (https://www.rtk-ai.app/docs/getting-started/supported-agents/):

| Plataforma | Integração | Rewriting Transparente | Status no agents-skills |
|------------|------------|----------------------|------------------------|
| Claude Code | Shell hook (PreToolUse) | ✅ Sim | ✅ Hooks instalados |
| Cursor | Shell hook (preToolUse) | ✅ Sim | ✅ Hooks instalados |
| VS Code Copilot | Shell hook (PreToolUse) | ✅ Sim | ✅ Hooks instalados |
| GitHub Copilot CLI | Shell hook (preToolUse) | ✅ Sim | ✅ Hooks instalados |
| Gemini CLI | Rust binary (BeforeTool) | ✅ Sim | ❌ Sem hooks específicos |
| OpenCode | TypeScript plugin | ✅ Sim | ✅ Plugin configurado por rtk init -g --opencode |
| OpenClaw | TypeScript plugin | ✅ Sim | ❌ Sem suporte |
| Pi | TypeScript extension | ✅ Sim | ❌ Sem suporte |
| Hermes | Python plugin | ✅ Sim | ❌ Sem suporte |
| Cline / Roo Code | Rules file (prompt-level) | ❌ N/A | ❌ Sem suporte |
| Windsurf (Devin Desktop) | Rules file (prompt-level) | ❌ N/A | ❌ Sem suporte |
| Codex CLI | AGENTS.md instructions | ❌ N/A | ❌ Sem suporte |
| Kilo Code | Rules file (prompt-level) | ❌ N/A | ❌ Sem suporte |
| Google Antigravity | Rules file (prompt-level) | ❌ N/A | ❌ Sem suporte |
| Devin (Cloud/Desktop/CLI) | ❌ Não suportado | ❌ N/A | ❌ Sem suporte oficial |

### Instalação RTK no agents-skills

**O que é instalado:**
- RTK binary é instalado globalmente via `install_rtk()` (todas as instalações)
- Hooks específicos são instalados apenas para:
  - Claude Code: `hooks/claude/rtk-rewrite.sh`, `hooks/claude/rtk-suggest.sh`
  - Cursor: `hooks/cursor/rtk-rewrite.sh`

**O que NÃO é instalado:**
- Hooks RTK para Gemini CLI (usaria Rust binary BeforeTool)
- Hooks RTK para Google Antigravity (usa rules file, não hooks)
- Hooks RTK para Devin (não suportado oficialmente)
- Configuração RTK para Windsurf/Devin Desktop (usa rules file)

### Como configurar RTK manualmente

**Para Gemini CLI:**
```bash
rtk init -g --gemini
```

**Para Google Antigravity:**
```bash
rtk init --agent antigravity    # Cria .agents/rules/antigravity-rtk-rules.md
```

**Para Windsurf/Devin Desktop:**
```bash
rtk init -g --agent windsurf
```

**Para Devin:**
Não há suporte oficial RTK. O install.sh instala o binário RTK globalmente, mas você precisará configurar manualmente se desejar usar com Devin.

## Caveman

### Suporte Caveman
Caveman é uma skill de comunicação comprimida que funciona em **qualquer agente** que suporte o formato Agent Skills (SKILL.md).

**Como funciona:**
- Caveman é uma skill que o agente invoca quando o usuário pede explicitamente
- Não depende de hooks específicos da plataforma
- Funciona puramente através do SKILL.md e do sistema de skills do agente

**Plataformas suportadas:**
- ✅ Claude Code
- ✅ Cursor
- ✅ Windsurf (Devin Desktop)
- ✅ VS Code Copilot
- ✅ Gemini CLI
- ✅ Google Antigravity (IDE e CLI)
- ✅ Devin (Cloud, Desktop, CLI)
- ✅ Qualquer agente que suporte Agent Skills

**Instalação no agents-skills:**
- Caveman skills são instaladas como skills normais em todas as plataformas
- Não requer configuração especial além da instalação padrão de skills

### Skills Caveman Disponíveis

1. **caveman** - Modo de comunicação ultra-comprimido (opt-in)
2. **caveman-commit** - Gerador de commit messages comprimidos
3. **caveman-compress** - Compressor de arquivos de memória
4. **caveman-review** - Revisão de código em formato caveman

## Problemas Identificados e Correções Necessárias

### 1. RTK SKILL.md desatualizado
**Problema:** A documentação RTK no SKILL.md não menciona Google Antigravity e tem instruções incorretas para Devin.

**Correção aplicada:** Atualizado `skills/rtk-token-killer/SKILL.md` para:
- Adicionar instruções para Google Antigravity
- Clarificar que Devin não tem suporte oficial RTK
- Remover instruções incorretas de configuração manual para Devin

### 2. Falta de hooks RTK para Gemini CLI
**Problema:** Não há hooks RTK específicos para Gemini CLI, apesar de RTK ter suporte oficial.

**Status:** Não corrigido - RTK usa Rust binary (BeforeTool) para Gemini CLI, não shell hooks. O install.sh não precisa instalar hooks específicos.

### 3. Falta de configuração RTK para Google Antigravity
**Problema:** RTK usa rules file para Google Antigravity, não hooks. O install.sh não configura isso automaticamente.

**Status:** Não corrigido - O usuário deve executar `rtk init --agent antigravity` manualmente após a instalação.

### 4. Falta de configuração RTK para Windsurf/Devin Desktop
**Problema:** RTK usa rules file para Windsurf, não hooks. O install.sh não configura isso automaticamente.

**Status:** Não corrigido - O usuário deve executar `rtk init -g --agent windsurf` manualmente após a instalação.

## Recomendações

### Para usuários que desejam RTK completo:

1. **Após instalar com `./install.sh --all`:**
   ```bash
   # Configurar RTK para plataformas adicionais
   rtk init -g --gemini              # Gemini CLI
   rtk init --agent antigravity      # Google Antigravity
   rtk init -g --agent windsurf      # Windsurf/Devin Desktop
   rtk init -g --opencode            # OpenCode
   ```

2. **Para Devin:**
   - RTK não tem suporte oficial
   - Considere usar apenas o binário RTK manualmente: `rtk git status` em vez de `git status`

### Para usuários que desejam Caveman:

1. **Instalar skills normalmente:**
   ```bash
   ./install.sh --all
   ```

2. **Usar caveman:**
   - Digite "caveman mode" ou "/caveman" para ativar
   - Digite "stop caveman" para desativar
   - Funciona automaticamente em todas as plataformas suportadas

## Conclusão

- **RTK:** Suporte parcial no agents-skills. Hooks/plugins instalados para Claude Code, Cursor e OpenCode. Outras plataformas requerem configuração manual.
- **Caveman:** Suporte completo. Funciona como skill normal em todas as plataformas sem configuração adicional.
- **Google Antigravity:** RTK suportado via rules file (configuração manual necessária). Caveman funciona automaticamente.
- **Devin:** RTK não suportado oficialmente. Caveman funciona automaticamente.
- **OpenCode:** RTK suportado via plugin (`rtk init -g --opencode`). Caveman funciona como skill/plugin.
