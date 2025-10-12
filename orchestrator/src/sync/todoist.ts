import { TodoistApi } from '@doist/todoist-api-typescript';
import type { Config } from '../config';
import { TodoistError } from '../utils/errors';
import { logger } from '../utils/logger';



export function getTodoistClient(config: Config): TodoistApi {
  return new TodoistApi(config.todoistApiToken);
}

export async function syncTodoistTasks(config: Config) {
  try {
    logger.info('Starting Todoist sync...');

  const todoist = getTodoistClient(config);
    const tasks = await todoist.getTasks();

    logger.info(`Retrieved ${tasks.length} tasks from Todoist`);

    // TODO: Implement sync logic with Notion and Google Calendar

    logger.info('Todoist sync completed successfully');
  } catch (error) {
    logger.error('Failed to sync Todoist tasks', { error });
    throw new TodoistError('Todoist sync failed', error);
  }
}

export function startTodoistSync(config: Config, intervalMs: number) {
  let syncInterval: NodeJS.Timeout | null = null; // Declare syncInterval here
  if (syncInterval) {
    clearInterval(syncInterval);
  }
  syncInterval = setInterval(async () => {
    try {
      await syncTodoistTasks(config);
    } catch (error) {
      logger.error('Sync interval error', { error });
    }
  }, intervalMs);
  // Run initial sync
  syncTodoistTasks(config).catch((error) => {
    logger.error('Initial Todoist sync failed', { error });
  });
}

export function stopTodoistSync(syncInterval: NodeJS.Timeout | null) {
  if (syncInterval) {
    clearInterval(syncInterval);
    syncInterval = null;
  }
}
