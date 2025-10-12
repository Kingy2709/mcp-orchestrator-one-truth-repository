import { Client } from '@notionhq/client';

export interface MCPTool {
  name: string;
  description: string;
  inputSchema: {
    type: string;
    properties: Record<string, unknown>;
    required: string[];
  };
  handler: (notion: Client, args: Record<string, unknown>) => Promise<unknown>;
}

export const notionTools: MCPTool[] = [
  {
    name: 'search_pages',
    description: 'Search for pages in Notion workspace',
    inputSchema: {
      type: 'object',
      properties: {
        query: {
          type: 'string',
          description: 'Search query',
        },
        limit: {
          type: 'number',
          description: 'Maximum number of results (default: 10)',
        },
      },
      required: ['query'],
    },
    handler: async (notion, args) => {
      const query = args.query as string;
      const limit = (args.limit as number) || 10;

      const response = await notion.search({
        query,
        page_size: limit,
        filter: { property: 'object', value: 'page' },
      });

      return response.results;
    },
  },
  {
    name: 'create_page',
    description: 'Create a new page in Notion',
    inputSchema: {
      type: 'object',
      properties: {
        parent_id: {
          type: 'string',
          description: 'Parent page or database ID',
        },
        title: {
          type: 'string',
          description: 'Page title',
        },
        content: {
          type: 'string',
          description: 'Page content (markdown)',
        },
      },
      required: ['parent_id', 'title'],
    },
    handler: async (notion, args) => {
      const parentId = args.parent_id as string;
      const title = args.title as string;
      const content = (args.content as string) || '';

      const response = await notion.pages.create({
        parent: { page_id: parentId },
        properties: {
          title: {
            title: [{ text: { content: title } }],
          },
        },
        children: content ? [
          {
            object: 'block',
            paragraph: {
              rich_text: [{ text: { content } }],
            },
          },
        ] : [],
      });

      return response;
    },
  },
  {
    name: 'query_database',
    description: 'Query a Notion database',
    inputSchema: {
      type: 'object',
      properties: {
        database_id: {
          type: 'string',
          description: 'Database ID',
        },
        filter: {
          type: 'object',
          description: 'Notion filter object (optional)',
        },
        sorts: {
          type: 'array',
          description: 'Sort configuration (optional)',
        },
      },
      required: ['database_id'],
    },
    handler: async (notion, args) => {
      const databaseId = args.database_id as string;
      const filter = args.filter as Record<string, unknown> | undefined;
      const sorts = args.sorts as Array<unknown> | undefined;

      const response = await notion.databases.query({
        database_id: databaseId,
        filter,
        sorts,
      });

      return response.results;
    },
  },
  {
    name: 'update_page',
    description: 'Update properties of an existing Notion page',
    inputSchema: {
      type: 'object',
      properties: {
        page_id: {
          type: 'string',
          description: 'Page ID to update',
        },
        properties: {
          type: 'object',
          description: 'Properties to update',
        },
      },
      required: ['page_id', 'properties'],
    },
    handler: async (notion, args) => {
      const pageId = args.page_id as string;
      const properties = args.properties as Record<string, unknown>;

      const response = await notion.pages.update({
        page_id: pageId,
        properties,
      });

      return response;
    },
  },
];
