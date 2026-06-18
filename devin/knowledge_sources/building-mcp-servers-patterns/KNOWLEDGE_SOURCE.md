# Building MCP Servers - Model Context Protocol Server Patterns

## Visao Geral

Padroes para construcao de servidores MCP (Model Context Protocol) em TypeScript, Python e C#. O MCP permite que agentes de IA acessem ferramentas, recursos e prompts de forma padronizada via Streamable HTTP transport.

## Arquitetura MCP

```text
┌──────────────┐     Streamable HTTP      ┌──────────────┐
│  MCP Client  │◄──────────────────────────►  MCP Server  │
│  (AI Agent)  │     JSON-RPC 2.0         │              │
│              │                           │  ┌─────────┐ │
│              │  initialize/list/call     │  │  Tools  │ │
│              │◄────────────────────────► │  ├─────────┤ │
│              │                           │  │Resources│ │
│              │                           │  ├─────────┤ │
│              │                           │  │ Prompts │ │
│              │                           │  └─────────┘ │
└──────────────┘                           └──────────────┘
```

## TypeScript MCP Server

### Setup Basico

```typescript
// src/server.ts
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';
import express from 'express';
import { z } from 'zod';

const server = new McpServer({
  name: 'lt6-platform-server',
  version: '1.0.0',
  capabilities: {
    tools: {},
    resources: {},
    prompts: {},
  },
});

// Registrar uma Tool
server.tool(
  'deploy-service',
  'Realiza deploy de um servico LT6 para o ambiente especificado',
  {
    service: z.string().describe('Nome do servico (ex: lt6-api-autenticacao-bff)'),
    environment: z.enum(['dev', 'hom', 'prod']).describe('Ambiente alvo'),
    version: z.string().optional().describe('Versao a ser deployada'),
    dryRun: z.boolean().default(false).describe('Simular deploy sem executar'),
  },
  async ({ service, environment, version, dryRun }) => {
    if (dryRun) {
      return {
        content: [{
          type: 'text',
          text: `[DRY RUN] Deploy de ${service}@${version ?? 'latest'} para ${environment}`,
        }],
      };
    }

    const result = await executeDeployment(service, environment, version);
    return {
      content: [{
        type: 'text',
        text: `Deploy concluido: ${service}@${result.version} em ${environment}`,
      }],
    };
  }
);
```

### Resources (Recursos)

```typescript
// Recurso estatico
server.resource(
  'service-catalog',
  'lt6://services/catalog',
  async (uri) => ({
    contents: [{
      uri: uri.href,
      mimeType: 'application/json',
      text: JSON.stringify({
        services: [
          { name: 'lt6-api-autenticacao-bff', tech: '.NET 8', status: 'ativo' },
          { name: 'lt6-api-autenticacao-isam', tech: '.NET 8', status: 'ativo' },
          { name: 'lt6-infra-quickconfig-service', tech: 'Java 17', status: 'ativo' },
        ],
      }),
    }],
  })
);

// Recurso com template (dinamico)
server.resource(
  'service-health',
  new ResourceTemplate('lt6://services/{serviceName}/health', { list: undefined }),
  async (uri, { serviceName }) => {
    const health = await checkServiceHealth(serviceName as string);
    return {
      contents: [{
        uri: uri.href,
        mimeType: 'application/json',
        text: JSON.stringify(health),
      }],
    };
  }
);
```

### Prompts

```typescript
// Prompt para gerar codigo
server.prompt(
  'generate-service',
  'Gera codigo boilerplate para um novo servico LT6',
  {
    serviceName: z.string().describe('Nome do servico'),
    technology: z.enum(['dotnet', 'java', 'angular']).describe('Stack tecnologica'),
  },
  ({ serviceName, technology }) => ({
    messages: [{
      role: 'user',
      content: {
        type: 'text',
        text: `Gere o codigo boilerplate para o servico "${serviceName}" usando ${technology}.
Siga os padroes da plataforma LT6:
- Clean Architecture com camadas Domain, Application, Infrastructure, WebApi
- Observabilidade com Datadog APM
- Testes BDD em portugues com cobertura minima de ${technology === 'java' ? '85%' : '80%'}`,
      },
    }],
  })
);
```

### Transport HTTP

```typescript
// src/transport.ts
const app = express();

app.post('/mcp', async (req, res) => {
  const transport = new StreamableHTTPServerTransport({
    sessionIdGenerator: undefined, // Stateless
  });

  res.on('close', () => {
    transport.close();
  });

  await server.connect(transport);
  await transport.handleRequest(req, res, req.body);
});

app.get('/mcp', async (req, res) => {
  res.writeHead(405).end(JSON.stringify({
    jsonrpc: '2.0',
    error: { code: -32000, message: 'Method not allowed. Use POST.' },
    id: null,
  }));
});

app.listen(3001, () => {
  console.log('MCP Server rodando em http://localhost:3001/mcp');
});
```

## Python MCP Server

```python
# server.py
from mcp.server.fastmcp import FastMCP
from typing import Any

mcp = FastMCP(
    name="lt6-platform-server",
    version="1.0.0",
)

@mcp.tool()
async def deploy_service(
    service: str,
    environment: str,
    version: str | None = None,
    dry_run: bool = False,
) -> str:
    """Realiza deploy de um servico LT6 para o ambiente especificado.

    Args:
        service: Nome do servico (ex: lt6-api-autenticacao-bff)
        environment: Ambiente alvo (dev, hom, prod)
        version: Versao a ser deployada
        dry_run: Simular deploy sem executar
    """
    if environment not in ("dev", "hom", "prod"):
        raise ValueError(f"Ambiente invalido: {environment}")

    if dry_run:
        return f"[DRY RUN] Deploy de {service}@{version or 'latest'} para {environment}"

    result = await execute_deployment(service, environment, version)
    return f"Deploy concluido: {service}@{result['version']} em {environment}"


@mcp.resource("lt6://services/catalog")
async def service_catalog() -> str:
    """Catalogo de servicos da plataforma LT6."""
    import json
    return json.dumps({
        "services": [
            {"name": "lt6-api-autenticacao-bff", "tech": ".NET 8", "status": "ativo"},
            {"name": "lt6-infra-quickconfig-service", "tech": "Java 17", "status": "ativo"},
        ]
    })


@mcp.prompt()
def generate_service_prompt(service_name: str, technology: str) -> str:
    """Gera prompt para criacao de servico LT6."""
    return f"""Gere o codigo boilerplate para o servico "{service_name}" usando {technology}.
Siga os padroes da plataforma LT6 com Clean Architecture."""


if __name__ == "__main__":
    mcp.run(transport="streamable-http", host="0.0.0.0", port=3001)
```

## C# MCP Server

```csharp
// Program.cs
using ModelContextProtocol.Server;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.ComponentModel;

var builder = Host.CreateApplicationBuilder(args);

builder.Services
    .AddMcpServer()
    .WithStreamableHttpTransport()
    .WithToolsFromAssembly();

var app = builder.Build();
await app.RunAsync();

// Tools/DeployServiceTool.cs
[McpServerToolType]
public static class DeployServiceTool
{
    [McpServerTool("deploy-service")]
    [Description("Realiza deploy de um servico LT6 para o ambiente especificado")]
    public static async Task<string> DeployService(
        [Description("Nome do servico")] string service,
        [Description("Ambiente alvo (dev|hom|prod)")] string environment,
        [Description("Simular deploy")] bool dryRun = false)
    {
        if (dryRun)
        {
            return $"[DRY RUN] Deploy de {service} para {environment}";
        }

        var result = await ExecuteDeploymentAsync(service, environment);
        return $"Deploy concluido: {service} em {environment}";
    }
}
```

## OAuth2 Authentication

```typescript
// src/auth.ts
import { OAuthServerProvider } from '@modelcontextprotocol/sdk/server/auth/providers/oauth.js';

const authProvider: OAuthServerProvider = {
  clientRegistration: async (clientMetadata) => ({
    client_id: generateClientId(),
    ...clientMetadata,
  }),
  authorize: async (client, params, res) => {
    // Validar client e redirecionar para pagina de login
    const authUrl = buildAuthUrl(client, params);
    res.redirect(authUrl);
  },
  challengeForToken: async (client, authorizationCode) => ({
    access_token: await generateAccessToken(client, authorizationCode),
    token_type: 'Bearer',
    expires_in: 3600,
  }),
  verifyAccessToken: async (token) => {
    const decoded = await verifyJwt(token);
    return {
      token,
      clientId: decoded.client_id,
      scopes: decoded.scopes,
    };
  },
};
```

## Testes para MCP Server

```typescript
// tests/server.test.ts
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';

describe('LT6 MCP Server', () => {
  let client: Client;

  beforeEach(async () => {
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
    await server.connect(serverTransport);
    client = new Client({ name: 'test-client', version: '1.0.0' });
    await client.connect(clientTransport);
  });

  it('dado_servico_valido_quando_deploy_entao_deve_retornar_sucesso', async () => {
    const result = await client.callTool({
      name: 'deploy-service',
      arguments: {
        service: 'lt6-api-autenticacao-bff',
        environment: 'dev',
        dryRun: true,
      },
    });

    expect(result.content[0].text).toContain('DRY RUN');
  });

  it('dado_catalogo_quando_listar_recursos_entao_deve_retornar_servicos', async () => {
    const resources = await client.listResources();
    expect(resources.resources).toHaveLength(1);
    expect(resources.resources[0].uri).toBe('lt6://services/catalog');
  });
});
```

---

## Boas Praticas

1. **Streamable HTTP**: Usar Streamable HTTP transport (SSE esta deprecado)
2. **Validacao de entrada**: Validar todos os parametros de tools com Zod/Pydantic
3. **Descricoes claras**: Cada tool, resource e prompt deve ter descricao detalhada
4. **Idempotencia**: Tools que alteram estado devem ser idempotentes quando possivel
5. **Dry-run**: Implementar modo dry-run para tools destrutivas
6. **Error handling**: Retornar erros estruturados com mensagens claras
7. **Stateless**: Preferir servidores stateless para escalabilidade
8. **Testes in-memory**: Usar InMemoryTransport para testes unitarios rapidos
9. **OAuth2**: Implementar autenticacao OAuth2 para producao
10. **Logging**: Log de todas as chamadas de tools com correlation IDs
