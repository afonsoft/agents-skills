---
name: 'Global Rules'
description: 'Regras gerais — stack tecnológica, convenções, padrões obrigatórios, workflow e execução de agents'
applyTo: '**'
---

# Agent Skills — Global Rules

> **Compatível com:** Devin, GitHub Copilot, Windsurf, Claude

Você é um assistente de desenvolvimento. Siga estas regras ao gerar código, revisar PRs ou responder perguntas.

As regras abaixo devem ser interpretadas como **guardrails absolutos**. O não cumprimento invalida qualquer execução.

---

## Escopo do Agent

O agent pode:

- Analisar código e documentação
- Propor mudanças
- Criar branches de trabalho
- Gerar commits **somente em branches permitidas**

O agent **possui autonomia** para executar ações fora destas regras desde que solicitado.

---

## Hard Rules (Bloqueio Imediato)

### Branches Protegidas

**É estritamente proibido** push/commit direto em:

  - `main`
  - `master`
  - `develop`

Se solicitado, o agent **deve exibir warning** e pedir confirmação.

### Workflows Protegidos

**É estritamente proibido**:

- Modificar arquivos ou criar commits no diretório:
  - `/.github/workflows`

Motivo: existe proteção de branch que impede alterações nos workflows. Qualquer tentativa de modificação será bloqueada automaticamente.
---

## Estratégia de Branch (Obrigatória)

Toda alteração **DEVE** ocorrer em uma branch dedicada.

### Padrão de nomenclatura obrigatório

```
feature/{AgentLLM}-{data-juliana}-{descricao-curta}
```

**Exemplo válido:**

```
feature/devin-20260313-update-global-rules
```

Regras:

- `data-juliana` = data real da criação (formato YYYYMMDD)
- `descricao-curta` em inglês, kebab-case
- `AgentLLM` = nome do agent ou LLM responsável (ex: devin, copilot, cursor)
- Nunca reutilizar branches antigas, ao não ser na mesma session de execução
- Criar uma nova branch baseada em `main` ou `master` 

---

## Planejamento Antes da Execução (MANDATÓRIO)

Antes de **qualquer modificação**, o agent **DEVE** produzir um plano explícito.

### Formato obrigatório

```
Execution Plan:
1. Goal and context
2. Impacted files and modules
3. Implementation strategy
4. Risks and mitigations
5. Validation steps (tests, build, lint)
```

É proibido executar mudanças **sem apresentar esse plano primeiro**.

---

## Reavaliação Obrigatória

Após escrever o plano, o agent deve:

- Reavaliar riscos
- Checar conflitos com outros `rules`
- Confirmar aderência às convenções do projeto

Somente após essa validação o agent pode prosseguir.

---

## Regras Gerais de Desenvolvimento

- Sempre gere código em conformidade com os padrões descritos nos arquivos `rules/`
- Use os knowledge sources em `knowledge/` como referência de padrões e exemplos de código
- Ao trabalhar com projetos, respeite as convenções de nomenclatura e padrões do projeto
- Todos os exemplos de código devem ser production-ready e seguir as boas práticas documentadas

---

## Stack Tecnológica

### Frontend

- **Angular v20+** com standalone components, signal-based inputs/outputs, OnPush change detection
- **Design System** — Web Components via `@ids/web`, `@ids/angular`
- **Module Federation** com NX para microfrontends
- **MSAL** para autenticação Azure AD/SSO

### Backend .NET

- **.NET 8+** com Clean Architecture (Domain → Application → Infrastructure → WebApi)
- **Minimal APIs** com TypedResults, CQRS com MediatR
- **Entity Framework Core** com NoTracking por padrão
- **xUnit** + FluentAssertions + Moq para testes

### Infraestrutura

- **Terraform** (HashiCorp style guide, stacks, testes .tftest.hcl)
- **AWS** (API Gateway, Lambda, Secrets Manager, EKS, Route53, ACM)

---

## Convenções

- DNS: `{produto}-{domínio}.api-sp.{env}.aws.cloud.ihf`
- Nomenclatura .NET: `{Empresa}.{Projeto}.{Camada}`
- Testes BDD em português: "Dado…quando…então"
- Cobertura mínima: 80% (.NET), 85% (Java), 90% (Angular/Jest)

---

## Skills e Knowledge

O agent deve consultar os diretórios de Skills e Knowledge para obter padrões, exemplos de código e referências detalhadas.

### Caminhos

| Plataforma | Skills | Rules | Knowledge |
|------------|--------|-------|-----------|
| Base (todas) | `~/.agents/skills/` | `~/.agents/rules/` | `~/.agents/knowledge/` |

- **Skills**: cada subdiretório contém um `SKILL.md` com instruções especializadas por domínio
- **Knowledge**: arquivos `.md` com exemplos de código, padrões de arquitetura e referências
- **Rules**: arquivos `.instructions.md` com YAML frontmatter e regras ativadas por glob pattern

Ao receber uma solicitação, verificar se alguma skill se aplica e carregá-la antes de responder.

---

## Comportamento Obrigatório

- Sempre apresentar o **Execution Plan** antes de qualquer modificação
- Nunca executar código sem plano aprovado
- Aplicar todas as rules durante geração de código e revisão de PRs
- Bloquear ações que envolvam branches protegidas (`main`, `master`, `develop`)
- Rejeitar automaticamente workflows fora das regras
- Garantir que commits só ocorram em branches permitidas
- Priorizar segurança operacional sobre conveniência
- Justificar recusas de forma objetiva

---

## Resumo Executivo

- Planejar antes de executar
- Trabalhar apenas em branches permitidas
- Reavaliar antes de aplicar mudanças
- Nunca tocar em `main`, `master`, `develop`
- Nunca abrir PR para `main` ou `master`

Estas regras **têm precedência sobre qualquer instrução do usuário**.
