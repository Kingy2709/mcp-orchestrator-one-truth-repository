import { Client } from '@notionhq/client';
import { config } from '../config';
import { NotionError } from '../utils/errors';
import { logger } from '../utils/logger';

let notionClient: Client | null = null;
let syncInterval: NodeJS.Timeout | null = null;

export function getNotionClient(): Client {
  if (!notionClient) {
    notionClient = new Client({
      auth: config.notionApiKey,
    });
  }
  return notionClient;
}

export async function syncNotionToTodoist() {
  try {
    logger.info('Starting Notion → Todoist sync...');

    const notion = getNotionClient();

    // Query tasks database
    if (!config.notionTasksDatabaseId) {
      logger.warn('Notion tasks database ID not configured, skipping sync');
      return;
    }

    const response = await notion.databases.query({
      database_id: config.notionTasksDatabaseId,
      filter: {
        property: 'Synced to Todoist',
        checkbox: {
          equals: false,
        },
      },
    });

    logger.info(`Found ${response.results.length} unsynced tasks in Notion`);

    // TODO: Implement actual sync logic with Todoist
    // For now, just log the tasks
    response.results.forEach((page) => {
      logger.debug('Unsynced task', { pageId: page.id });
    });

    logger.info('Notion → Todoist sync completed successfully');
  } catch (error) {
    logger.error('Failed to sync Notion → Todoist', { error });
    throw new NotionError('Notion sync failed', error);
  }
}

export async function syncTodoistToNotion() {
  try {
    logger.info('Starting Todoist → Notion sync...');

    // TODO: Implement Todoist → Notion sync logic

    logger.info('Todoist → Notion sync completed successfully');
  } catch (error) {
    logger.error('Failed to sync Todoist → Notion', { error });
    throw new NotionError('Todoist to Notion sync failed', error);
  }
}

export function startNotionSync(intervalMs: number) {
  if (syncInterval) {
    clearInterval(syncInterval);
  }

  syncInterval = setInterval(async () => {
    try {
      await syncNotionToTodoist();
      await syncTodoistToNotion();
    } catch (error) {
      logger.error('Sync interval error', { error });
    }
  }, intervalMs);

  // Run initial sync
  syncNotionToTodoist().catch((error) => {
    logger.error('Initial Notion sync failed', { error });
  });
}

export function stopNotionSync() {
  if (syncInterval) {
    clearInterval(syncInterval);
    syncInterval = null;
  }
}
