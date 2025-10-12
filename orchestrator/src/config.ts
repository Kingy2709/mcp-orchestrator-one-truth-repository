import { config as dotenvConfig } from 'dotenv';
import { z } from 'zod';
import * as path from 'path';

// Load .env file
dotenvConfig({ path: path.resolve(__dirname, '../../.env') });

// Define configuration schema with Zod
const ConfigSchema = z.object({
  // Node environment
  nodeEnv: z.enum(['development', 'production', 'test']).default('development'),
  logLevel: z.enum(['error', 'warn', 'info', 'debug']).default('info'),
  port: z.coerce.number().default(3000),

  // 1Password Service Account
  opServiceAccountToken: z.string().min(1, '1Password Service Account token required'),

  // Notion API
  notionApiKey: z.string().min(1, 'Notion API key required'),
  notionTasksDatabaseId: z.string().optional(),
  notionResearchDatabaseId: z.string().optional(),
  notionCompletionsDatabaseId: z.string().optional(),

  // Todoist API
  todoistApiToken: z.string().min(1, 'Todoist API token required'),
  todoistWebhookSecret: z.string().optional(),

  // GitHub
  githubPat: z.string().optional(),
  githubWebhookSecret: z.string().optional(),

  // Sync intervals (milliseconds)
  syncIntervalNotion: z.coerce.number().default(300000), // 5 minutes
  syncIntervalTodoist: z.coerce.number().default(180000), // 3 minutes

  // AI settings
  aiTaggingEnabled: z.coerce.boolean().default(true),
  aiModel: z.enum(['gpt-4', 'claude-3-5-sonnet', 'gpt-4o']).default('gpt-4'),

  // Agent settings
  agentDelegationEnabled: z.coerce.boolean().default(true),
  agentTriggerTags: z.string().default('research,code,summary'),

  // Optional: Tailscale
  tailscaleIp: z.string().optional(),

  // Optional: Sentry
  sentryDsn: z.string().optional(),
});

export type Config = z.infer<typeof ConfigSchema>;

// Parse and validate environment variables
function loadConfig(): Config {
  try {
    return ConfigSchema.parse({
      nodeEnv: process.env.NODE_ENV,
      logLevel: process.env.LOG_LEVEL,
      port: process.env.PORT,
      
      opServiceAccountToken: process.env.OP_SERVICE_ACCOUNT_TOKEN,
      
      notionApiKey: process.env.NOTION_API_KEY,
      notionTasksDatabaseId: process.env.NOTION_TASKS_DATABASE_ID,
      notionResearchDatabaseId: process.env.NOTION_RESEARCH_DATABASE_ID,
      notionCompletionsDatabaseId: process.env.NOTION_COMPLETIONS_DATABASE_ID,
      
      todoistApiToken: process.env.TODOIST_API_TOKEN,
      todoistWebhookSecret: process.env.TODOIST_WEBHOOK_SECRET,
      
      githubPat: process.env.GITHUB_PAT,
      githubWebhookSecret: process.env.GITHUB_WEBHOOK_SECRET,
      
      syncIntervalNotion: process.env.SYNC_INTERVAL_NOTION,
      syncIntervalTodoist: process.env.SYNC_INTERVAL_TODOIST,
      
      aiTaggingEnabled: process.env.AI_TAGGING_ENABLED,
      aiModel: process.env.AI_MODEL,
      
      agentDelegationEnabled: process.env.AGENT_DELEGATION_ENABLED,
      agentTriggerTags: process.env.AGENT_TRIGGER_TAGS,
      
      tailscaleIp: process.env.TAILSCALE_IP,
      sentryDsn: process.env.SENTRY_DSN,
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error('Configuration validation failed:');
      error.errors.forEach((err) => {
        console.error(`  - ${err.path.join('.')}: ${err.message}`);
      });
      process.exit(1);
    }
    throw error;
  }
}

export const config = loadConfig();
