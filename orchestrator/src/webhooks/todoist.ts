import { Request, Response } from 'express';
import crypto from 'crypto';
import { config } from '../config';
import { logger } from '../utils/logger';
import { WebhookError } from '../utils/errors';
import { delegateTask } from '../agents/task-delegator';
import { autoTagTask } from '../agents/auto-tagger';

interface TodoistWebhookEvent {
  event_name: string;
  user_id: string;
  event_data: {
    id: string;
    content: string;
    description?: string;
    labels?: string[];
    priority?: number;
    due?: { date: string };
  };
}

function verifyTodoistSignature(req: Request): boolean {
  if (!config.todoistWebhookSecret) {
    logger.warn('Todoist webhook secret not configured, skipping verification');
    return true;
  }

  const signature = req.headers['x-todoist-hmac-sha256'] as string;
  if (!signature) {
    return false;
  }

  const body = JSON.stringify(req.body);
  const expectedSignature = crypto
    .createHmac('sha256', config.todoistWebhookSecret)
    .update(body)
    .digest('base64');

  return signature === expectedSignature;
}

export async function handleTodoistWebhook(req: Request, res: Response) {
  // Verify signature
  if (!verifyTodoistSignature(req)) {
    throw new WebhookError('Invalid webhook signature', 401);
  }

  const event = req.body as TodoistWebhookEvent;
  logger.info('Todoist webhook event received', {
    eventName: event.event_name,
    taskId: event.event_data.id,
  });

  try {
    switch (event.event_name) {
      case 'item:added':
        await handleTaskAdded(event.event_data);
        break;
      
      case 'item:completed':
        await handleTaskCompleted(event.event_data);
        break;
      
      case 'item:updated':
        await handleTaskUpdated(event.event_data);
        break;
      
      default:
        logger.debug('Unhandled Todoist event', { eventName: event.event_name });
    }

    res.status(200).send('OK');
  } catch (error) {
    logger.error('Error processing Todoist webhook', { error, event });
    throw error;
  }
}

async function handleTaskAdded(taskData: TodoistWebhookEvent['event_data']) {
  logger.info('Processing new task', { taskId: taskData.id, content: taskData.content });

  try {
    // Auto-tag the task
    if (config.aiTaggingEnabled) {
      await autoTagTask({
        id: taskData.id,
        content: taskData.content,
        labels: taskData.labels || [],
      });
    }

    // Check for agent delegation triggers
    if (config.agentDelegationEnabled) {
      await delegateTask({
        id: taskData.id,
        content: taskData.content,
        labels: taskData.labels || [],
      });
    }

    // Sync to Notion
    // TODO: Implement Notion sync

    logger.info('Task added successfully processed', { taskId: taskData.id });
  } catch (error) {
    logger.error('Failed to process task added', { error, taskData });
    throw error;
  }
}

async function handleTaskCompleted(taskData: TodoistWebhookEvent['event_data']) {
  logger.info('Processing completed task', { taskId: taskData.id });

  try {
    // Log to Notion completions database
    // TODO: Implement completion logging

    logger.info('Task completion processed', { taskId: taskData.id });
  } catch (error) {
    logger.error('Failed to process task completion', { error, taskData });
    throw error;
  }
}

async function handleTaskUpdated(taskData: TodoistWebhookEvent['event_data']) {
  logger.info('Processing updated task', { taskId: taskData.id });

  try {
    // Sync update to Notion
    // TODO: Implement update sync

    logger.info('Task update processed', { taskId: taskData.id });
  } catch (error) {
    logger.error('Failed to process task update', { error, taskData });
    throw error;
  }
}
