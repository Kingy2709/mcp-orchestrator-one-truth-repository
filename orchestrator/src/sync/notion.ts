import { Client } from '@notionhq/client';
import type { Config } from '../config';
import { NotionError } from '../utils/errors';
import { logger } from '../utils/logger';



export function getNotionClient(config: Config): Client {
  return new Client({
    auth: config.notionApiKey,
  });
}

export async function syncNotionToTodoist(config: Config) {
  try {
    logger.info('Starting Notion → Todoist sync...');

  const notion = getNotionClient(config);

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

export async function syncTodoistToNotion(config: Config) {
  try {
    logger.info('Starting Todoist → Notion sync...');

  // TODO: Implement Todoist → Notion sync logic

    logger.info('Todoist → Notion sync completed successfully');
  } catch (error) {
    logger.error('Failed to sync Todoist → Notion', { error });
    throw new NotionError('Todoist to Notion sync failed', error);
  }
}

export function startNotionSync(config: Config, intervalMs: number) {
  let syncInterval: NodeJS.Timeout | null = null;
  if (syncInterval) {
    clearInterval(syncInterval);
  }

  syncInterval = setInterval(async () => {
    try {
      await syncNotionToTodoist(config);
      await syncTodoistToNotion(config);
    } catch (error) {
      logger.error('Sync interval error', { error });
    }
  }, intervalMs);

  // Run initial sync
  syncNotionToTodoist(config).catch((error) => {
    logger.error('Initial Notion sync failed', { error });
  });
}

export function stopNotionSync(syncInterval: NodeJS.Timeout | null) {
  if (syncInterval) {
    clearInterval(syncInterval);
    syncInterval = null;
  }
}
