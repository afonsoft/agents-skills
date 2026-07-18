---
description: >
  Build an MCP (Model Context Protocol) server in TypeScript, Python, or C# to
  expose tools, resources, and prompts to AI agents via Streamable HTTP transport.
  Use when integrating external APIs or services into an agent through a
  standardized JSON-RPC 2.0 interface.
mode: agent
tools:
  - read
  - grep
  - find_file_by_name
  - write
  - exec
  - web_get_contents
  - git_create_pr
  - git_view_pr
---

# Building MCP Servers

## Role
Backend engineer / integration architect.

## Goal
Create a production-ready MCP server in **TypeScript**, **Python**, or **C#** that
exposes well-designed tools, resources, and prompts to AI clients through the
**Streamable HTTP** transport.

## Input
- `SERVER_NAME`: unique MCP server name (e.g. `my-platform-server`).
- `LANGUAGE`: `typescript`, `python`, or `csharp`.
- `API_DOMAIN`: domain the server will expose (e.g. `lt6`, `billing`, `inventory`).
- `TARGET_DIR`: project root where the server will be generated.

---

## Phase 1 — Architecture and Planning

MCP servers expose three primitives:

| Primitive | Purpose | Example |
|---|---|---|
| **Tools** | Actions the agent can invoke | `deploy-service`, `create-ticket` |
| **Resources** | Data sources the agent can read | `service-catalog`, `service-health` |
| **Prompts** | Reusable prompt templates | `generate-service-boilerplate` |

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

### Decision Checklist

- [ ] Choose the language based on team expertise and target runtime.
- [ ] Decide between **stateless** (recommended for scale) and **stateful** sessions.
- [ ] List the external operations the agent will need (candidate tools).
- [ ] List the read-only data the agent will query (candidate resources).
- [ ] List repeatable instructions the agent will reuse (candidate prompts).
- [ ] Plan input validation, error handling, idempotency, and dry-run support.

---

## Phase 2 — Project Setup

### TypeScript

```bash
npm init -y
npm install @modelcontextprotocol/sdk express zod
npm install -D typescript @types/express @types/node ts-node
npx tsc --init
```

### Python

```bash
python -m venv .venv
source .venv/bin/activate
pip install mcp fastmcp
```

### C#

```bash
dotnet new web -n {SERVER_NAME}
cd {SERVER_NAME}
dotnet add package ModelContextProtocol.AspNetCore
```

---

## Phase 3 — Implement the Server

### 3.1 TypeScript

```typescript
// src/server.ts
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';
import express from 'express';
import { z } from 'zod';

const server = new McpServer({
  name: '{SERVER_NAME}',
  version: '1.0.0',
  capabilities: {
    tools: {},
    resources: {},
    prompts: {},
  },
});

// Tool example: deploy a service
server.registerTool(
  'deploy-service',
  {
    title: 'Deploy Service',
    description: 'Deploys a service to the specified environment',
    inputSchema: {
      service: z.string().describe('Service name (e.g. my-api-authentication)'),
      environment: z.enum(['dev', 'hom', 'prod']).describe('Target environment'),
      version: z.string().optional().describe('Version to deploy'),
      dryRun: z.boolean().default(false).describe('Simulate without executing'),
    },
  },
  async ({ service, environment, version, dryRun }) => {
    if (dryRun) {
      return {
        content: [{
          type: 'text',
          text: `[DRY RUN] Deploy ${service}@${version ?? 'latest'} to ${environment}`,
        }],
      };
    }

    const result = await executeDeployment(service, environment, version);
    return {
      content: [{
        type: 'text',
        text: `Deploy completed: ${service}@${result.version} in ${environment}`,
      }],
    };
  }
);

// Static resource example
server.registerResource(
  'service-catalog',
  {
    uri: '{API_DOMAIN}://services/catalog',
    name: 'Service Catalog',
    description: 'Catalog of available services',
    mimeType: 'application/json',
  },
  async (uri) => ({
    contents: [{
      uri: uri.href,
      mimeType: 'application/json',
      text: JSON.stringify({ services: [] }),
    }],
  })
);

// Prompt example
server.registerPrompt(
  'generate-service',
  {
    description: 'Generate boilerplate code for a new service',
    argsSchema: {
      serviceName: z.string().describe('Service name'),
      technology: z.enum(['dotnet', 'java', 'angular']).describe('Technology stack'),
    },
  },
  ({ serviceName, technology }) => ({
    messages: [{
      role: 'user',
      content: {
        type: 'text',
        text: `Generate boilerplate for "${serviceName}" using ${technology}. Follow Clean Architecture and include tests.`,
      },
    }],
  })
);
```

### 3.2 Python

```python
# server.py
from mcp.server.fastmcp import FastMCP
from typing import Any

mcp = FastMCP(
    name="{SERVER_NAME}",
    version="1.0.0",
)

@mcp.tool()
async def deploy_service(
    service: str,
    environment: str,
    version: str | None = None,
    dry_run: bool = False,
) -> str:
    """Deploy a service to the specified environment."""
    if environment not in ("dev", "hom", "prod"):
        raise ValueError(f"Invalid environment: {environment}")

    if dry_run:
        return f"[DRY RUN] Deploy {service}@{version or 'latest'} to {environment}"

    result = await execute_deployment(service, environment, version)
    return f"Deploy completed: {service}@{result['version']} in {environment}"

@mcp.resource("{API_DOMAIN}://services/catalog")
async def service_catalog() -> str:
    """Service catalog."""
    import json
    return json.dumps({"services": []})

@mcp.prompt()
def generate_service_prompt(service_name: str, technology: str) -> str:
    """Generate prompt for service creation."""
    return f"Generate boilerplate for \"{service_name}\" using {technology}. Follow Clean Architecture."

if __name__ == "__main__":
    mcp.run(transport="streamable-http", host="0.0.0.0", port=3001)
```

### 3.3 C#

```csharp
// Program.cs
using ModelContextProtocol.Server;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.ComponentModel;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddMcpServer()
    .WithHttpTransport()
    .WithToolsFromAssembly()
    .WithPromptsFromAssembly()
    .WithResourcesFromAssembly();

var app = builder.Build();
app.MapMcp();
await app.RunAsync();

// Tools/DeployServiceTool.cs
[McpServerToolType]
public static class DeployServiceTool
{
    [McpServerTool("deploy-service")]
    [Description("Deploys a service to the specified environment")]
    public static async Task<string> DeployService(
        [Description("Service name")] string service,
        [Description("Target environment (dev|hom|prod)")] string environment,
        [Description("Simulate deploy")] bool dryRun = false)
    {
        if (dryRun)
        {
            return $"[DRY RUN] Deploy {service} to {environment}";
        }

        var result = await ExecuteDeploymentAsync(service, environment);
        return $"Deploy completed: {service} in {environment}";
    }
}
```

---

## Phase 4 — Transport and Authentication

### Streamable HTTP Transport (TypeScript)

```typescript
// src/transport.ts
const app = express();
app.use(express.json());

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
  console.log('MCP Server running on http://localhost:3001/mcp');
});
```

### OAuth2 Authentication (TypeScript)

```typescript
// src/auth.ts
import { OAuthServerProvider } from '@modelcontextprotocol/sdk/server/auth/providers/oauth.js';

const authProvider: OAuthServerProvider = {
  clientRegistration: async (clientMetadata) => ({
    client_id: generateClientId(),
    ...clientMetadata,
  }),
  authorize: async (client, params, res) => {
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

---

## Phase 5 — Testing

### In-Memory Transport Tests (TypeScript)

```typescript
// tests/server.test.ts
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';

describe('{SERVER_NAME} MCP Server', () => {
  let client: Client;

  beforeEach(async () => {
    const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
    await server.connect(serverTransport);
    client = new Client({ name: 'test-client', version: '1.0.0' });
    await client.connect(clientTransport);
  });

  it('given_valid_service_when_deploy_then_returns_success', async () => {
    const result = await client.callTool({
      name: 'deploy-service',
      arguments: {
        service: 'my-api-authentication',
        environment: 'dev',
        dryRun: true,
      },
    });

    expect(result.content[0].text).toContain('DRY RUN');
  });

  it('given_catalog_when_list_resources_then_returns_services', async () => {
    const resources = await client.listResources();
    expect(resources.resources).toHaveLength(1);
    expect(resources.resources[0].uri).toBe('{API_DOMAIN}://services/catalog');
  });
});
```

### Testing Matrix

| Test Type | What to Cover |
|---|---|
| Unit | Tool/resource/prompt handlers in isolation |
| Integration | In-memory transport with `Client` |
| HTTP | End-to-end `/mcp` endpoint calls |
| Validation | Invalid arguments, missing parameters |
| Dry-run | Destructive tools must support dry-run |
| Auth | OAuth2 token generation and verification |

---

## Phase 6 — Best Practices

1. **Streamable HTTP**: use Streamable HTTP for remote servers (SSE is deprecated).
2. **Input validation**: validate all tool parameters with Zod (TypeScript), Pydantic (Python), or data annotations (C#).
3. **Clear descriptions**: every tool, resource, and prompt must have a detailed description.
4. **Idempotency**: make state-changing tools idempotent whenever possible.
5. **Dry-run**: implement dry-run for destructive tools.
6. **Error handling**: return structured errors with clear messages and actionable next steps.
7. **Stateless**: prefer stateless servers for scalability.
8. **In-memory tests**: use `InMemoryTransport` for fast unit tests.
9. **OAuth2**: implement authentication for production deployments.
10. **Logging**: log all tool calls with correlation IDs.

---

## Phase 7 — Delivery

1. Generate the server project in `TARGET_DIR`.
2. Add a `README.md` with install, run, and test instructions.
3. Add a `Dockerfile` if the server will be deployed as a container.
4. Create branch `feature/{YYYYMMDD}-mcp-server-{SERVER_NAME}`.
5. Commit with Conventional Commit: `feat(mcp): add {SERVER_NAME} MCP server`.
6. **Do not open the Pull Request automatically** unless instructed.

---

## Restrictions

- Do not expose secrets or credentials in tool outputs.
- Do not implement unauthenticated production endpoints.
- Do not skip input validation on any tool.
- Do not create stateful sessions unless the use case explicitly requires it.
