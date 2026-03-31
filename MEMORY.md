# MEMORY.md

Este arquivo serve como memória persistente para agentes de IA, contendo informações importantes que devem ser lembradas entre conversas e sessões.

## Estrutura do Projeto

### agents-skills
Repositório comunitário de agentes, skills, regras e conhecimento para desenvolvimento com IA.

- **agents/**: Definições de agentes especializados com integração MCP
- **skills/**: Skills autocontidas com recursos agrupados
- **rules/**: Padrões de codificação e melhores práticas
- **workflows/**: Workflows agentic para automação
- **knowledge/**: Documentos, padrões e guias de migração
- **install.sh**: Script de instalação para múltiplas IDEs/CLIs

### Destaques

#### ABP.IO Framework Support
- Skills completas para criação de projetos ABP.IO
- Guia de migração ASP.NET Boilerplate → ABP.IO
- Padrões de arquitetura DDD para projetos ABP

#### .NET Development
- Programação assíncrona C# com padrões modernos
- Testes unitários (MSTest, NUnit, xUnit)
- Entity Framework Core com melhores práticas
- Arquitetura limpa e princípios SOLID

#### Ferramentas de Desenvolvimento
- Code review automatizado e padrões de qualidade
- Segurança abrangente e prevenção de vulnerabilidades
- Estratégias de otimização de performance
- Automação de gerenciamento de projetos

## Instalação

O script `install.sh` suporta instalação seletiva para diferentes IDEs:

```bash
# Instalar para todas as IDEs
./install.sh --all

# Instalar para IDEs específicas
./install.sh --windsurf --gemini --openclaw

# Instalar apenas para Windsurf
./install.sh --windsurf
```

## Destinos de Instalação

### Windsurf (Cascade)
- Skills: `~/.windsurf/skills/`
- Rules: `~/.windsurf/rules/`
- Knowledge/Memories: `~/.windsurf/knowledge/`
- Rules consolidadas: `~/.windsurfrules`

### Gemini CLI
- Skills: `~/.gemini/skills/`
- Rules: `~/.gemini/GEMINI.md`
- Knowledge: `~/.gemini/knowledge/`
- Memory: `~/.gemini/memory/MEMORY.md`

### OpenClaw
- Skills: `~/.openclaw/skills/`
- Memory: `~/.openclaw/workspace/memory/MEMORY.md`
- Daily logs: `~/.openclaw/workspace/memory/YYYY-MM-DD.md`

## Convenções de Nomenclatura

### Skills
- Nome: kebab-case (ex: `create-abp-project`)
- Estrutura: Diretório com `SKILL.md` e recursos opcionais
- Frontmatter: Obrigatório com `name` e `description`

### Rules
- Nome: kebab-case com sufixo `.instructions.md`
- Frontmatter: Obrigatório com `description` e `applyTo`
- Consolidação: Arquivo único com todas as rules

### Knowledge
- Nome: kebab-case
- Formato: Markdown com seções claras
- Conteúdo: Guiias completos e exemplos práticos

## Melhores Práticas

### Desenvolvimento
- Usar TypeScript/C# moderno quando aplicável
- Seguir princípios SOLID e DDD
- Implementar testes abrangentes
- Documentar padrões e convenções

### Code Review
- Priorizar segurança e correção
- Verificar performance e arquitetura
- Sugerir melhorias de legibilidade
- Testar edge cases

### Contribuição
- Fork do repositório
- Branch da `staged` branch
- Testar com a IDE alvo
- Pull request com descrição clara

## Padrões Arquiteturais

### Domain-Driven Design
- Bounded contexts claros
- Aggregates para consistência
- Domain events para comunicação
- Rich domain models

### Microservices
- API Gateway para roteamento
- Circuit breaker para resiliência
- Event-driven architecture
- Database per service

### Performance
- Lazy loading e code splitting
- Virtual scrolling para listas grandes
- Caching estratégico
- Monitoramento contínuo

## Segurança

### Autenticação e Autorização
- MFA para usuários
- RBAC para permissões
- JWT tokens com expiração
- Rate limiting para APIs

### Proteção de Dados
- Encryption at rest e in transit
- Input validation e sanitização
- SQL injection prevention
- XSS protection

### Compliance
- GDPR para dados EU
- LGPD para dados BR
- SOC 2 para auditoria
- PCI DSS para pagamentos

## Ferramentas e Ecosistemas

### Frontend
- React com TypeScript
- Angular com signals
- Vue 3 com composition API
- Next.js para SSR

### Backend
- .NET 8+ com C# moderno
- Node.js com TypeScript
- Python com FastAPI
- Go para microservices

### DevOps
- Docker para containers
- Kubernetes para orquestração
- Terraform para IaC
- GitHub Actions para CI/CD

## Recursos Adicionais

### Documentação
- [AGENTS.md](AGENTS.md) - Guia de desenvolvimento completo
- [CONTRIBUTING.md](CONTRIBUTING.md) - Como contribuir
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Padrões da comunidade

### Comunidade
- GitHub Discussions para dúvidas
- Issues para bugs e features
- Wiki para documentação estendida
- Releases para versões estáveis

---

**Última atualização**: 2026-03-26  
**Versão**: 1.0.0  
**Maintainers**: Comunidade agents-skills
