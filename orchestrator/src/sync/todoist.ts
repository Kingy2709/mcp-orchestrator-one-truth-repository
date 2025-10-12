import { TodoistApi } from '@doist/todoist-api-typescript';
import { config } from '../config';
import { logger } from '../utils/logger';
import { TodoistError } from '../utils/errors';

let todoistClient: TodoistApi | null = null;
let syncInterval: NodeJS.Timeout | null = null;

export function getTodoistClient(): TodoistApi {
  if (!todoistClient) {
    todoistClient = new TodoistApi(config.todoistApiToken);
  }
  return todoistClient;
}

export async function syncTodoistTasks() {
  try {
    logger.info('Starting Todoist sync...');
    
    const todoist = getTodoistClient();
    const tasks = await todoist.getTasks();

    logger.info(`Retrieved ${tasks.length} tasks from Todoist`);
    
    // TODO: Implement sync logic with Notion and Google Calendar
    
    logger.info('Todoist sync completed successfully');
  } catch (error) {
    logger.error('Failed to sync Todoist tasks', { error });
    throw new TodoistError('Todoist sync failed', error);
  }
}

export function startTodoistSync(intervalMs: number) {
  if (syncInterval) {
    clearInterval(syncInterval);
  }

  syncInterval = setInterval(async () => {
    try {
      await syncTodoistTasks();
    } catch (error) {
      logger.error('Sync interval error', { error });
    }
  }, intervalMs);

  // Run initial sync
  syncTodoistTasks().catch((error) => {
    logger.error('Initial Todoist sync failed', { error });
  });
}

export function stopTodoistSync() {
  if (syncInterval) {
    clearInterval(syncInterval);
    syncInterval = null;
  }
}
