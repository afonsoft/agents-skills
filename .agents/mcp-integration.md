# Model Context Protocol (MCP) Integration

This document outlines MCP (Model Context Protocol) integration patterns for the agents-skills repository.

## What is MCP?

MCP is the "USB-C for AI" - a universal protocol that enables AI agents to use tools and services agnostically of the executing agent. Donated by OpenAI and Anthropic to the Linux Foundation under the Agentic AI Foundation.

## MCP Benefits

- **Agent Agnostic**: Same tools work across Claude, Cursor, Copilot, Gemini, etc.
- **Standardized Interface**: Consistent tool discovery and invocation
- **Server Architecture**: Tools run as independent servers
- **Security Model**: Controlled access with permissions

## MCP Server Types

### HTTP Servers
```json
{
  "mcpServers": {
    "github": {
      "command": "node",
      "args": ["github-mcp-server.js"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Local Tools
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-filesystem", "/path/to/files"]
    }
  }
}
```

## Integration Patterns

### Skills with MCP Tools
Skills can declare MCP tool dependencies in frontmatter:

```yaml
---
name: github-workflow
description: GitHub repository management with MCP integration
tools:
  - mcp:github
  - mcp:filesystem
triggers:
  - user
---
```

### MCP-Enabled Workflows
```
workflow-name/
├── workflow.md       # Main workflow definition
├── mcp-config.json   # MCP server configuration
└── servers/          # MCP server implementations
    ├── github-server.js
    └── database-server.js
```

## Configuration Files

### mcp-config.json
```json
{
  "mcpServers": {
    "agents-skills": {
      "command": "node",
      "args": ["./servers/skills-server.js"],
      "cwd": "${workspaceFolder}"
    },
    "github": {
      "command": "node", 
      "args": ["./servers/github-server.js"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

## Server Implementation Example

### skills-server.js
```javascript
const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');

const server = new Server(
  {
    name: 'agents-skills-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Register tools
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'execute_skill',
      description: 'Execute a specific agent skill',
      inputSchema: {
        type: 'object',
        properties: {
          skillName: { type: 'string' },
          parameters: { type: 'object' }
        }
      }
    }
  ]
}));

server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;
  
  if (name === 'execute_skill') {
    // Execute skill logic
    return {
      content: [{
        type: 'text',
        text: `Executed skill: ${args.skillName}`
      }]
    };
  }
});

// Start server
const transport = new StdioServerTransport();
server.connect(transport);
```

## Best Practices

### Security
- Use environment variables for sensitive data
- Validate all input parameters
- Implement proper error handling
- Limit file system access

### Performance
- Cache frequently accessed data
- Use streaming for large responses
- Implement timeout handling
- Monitor resource usage

### Compatibility
- Follow MCP specification exactly
- Test with multiple agent platforms
- Provide clear error messages
- Document tool interfaces

## Installation

### MCP Client Setup
1. Install MCP client for your IDE/CLI
2. Configure `mcp-config.json` in workspace root
3. Restart agent to load MCP servers

### Server Deployment
```bash
# Install MCP SDK
npm install @modelcontextprotocol/sdk

# Run server
node servers/skills-server.js
```

## Troubleshooting

### Common Issues
- **Server not found**: Check command path and arguments
- **Permission denied**: Verify file permissions and environment variables
- **Timeout**: Increase timeout values or optimize server performance
- **Tool not available**: Ensure server is running and tools are registered

### Debug Mode
```json
{
  "mcpServers": {
    "debug": {
      "command": "node",
      "args": ["--inspect", "./servers/skills-server.js"]
    }
  }
}
```

## Resources

- [Model Context Protocol](https://modelcontextprotocol.io)
- [MCP SDK Documentation](https://github.com/modelcontextprotocol/servers)
- [Agentic AI Foundation](https://aaif.org)
- [MCP Server Examples](https://github.com/modelcontextprotocol/servers)
