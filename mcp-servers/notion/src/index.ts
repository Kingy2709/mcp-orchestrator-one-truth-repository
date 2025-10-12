import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema } from '@modelcontextprotocol/sdk/types.js';
import { Client } from '@notionhq/client';
import { notionTools } from './tools.js';

const NOTION_API_KEY = process.env.NOTION_API_KEY;

if (!NOTION_API_KEY) {
  console.error('NOTION_API_KEY environment variable is required');
  process.exit(1);
}

const notion = new Client({ auth: NOTION_API_KEY });
const server = new Server(
  {
    name: 'mcp-notion',
    version: '0.1.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: notionTools.map(tool => ({
      name: tool.name,
      description: tool.description,
      inputSchema: tool.inputSchema,
    })),
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const tool = notionTools.find(t => t.name === request.params.name);

  if (!tool) {
    throw new Error(`Unknown tool: ${request.params.name}`);
  }

  try {
    const result = await tool.handler(notion, request.params.arguments || {});
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  } catch (error) {
    throw new Error(`Tool execution failed: ${error}`);
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Notion MCP server running on stdio');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
