import { Request, Response } from 'express';
import crypto from 'crypto';
import { config } from '../config';
import { logger } from '../utils/logger';
import { WebhookError } from '../utils/errors';

interface GitHubWebhookEvent {
  action: string;
  repository: {
    full_name: string;
  };
  sender: {
    login: string;
  };
}

function verifyGitHubSignature(req: Request): boolean {
  if (!config.githubWebhookSecret) {
    logger.warn('GitHub webhook secret not configured, skipping verification');
    return true;
  }

  const signature = req.headers['x-hub-signature-256'] as string;
  if (!signature) {
    return false;
  }

  const body = JSON.stringify(req.body);
  const expectedSignature = 'sha256=' + crypto
    .createHmac('sha256', config.githubWebhookSecret)
    .update(body)
    .digest('hex');

  return signature === expectedSignature;
}

export async function handleGitHubWebhook(req: Request, res: Response) {
  // Verify signature
  if (!verifyGitHubSignature(req)) {
    throw new WebhookError('Invalid webhook signature', 401);
  }

  const event = req.headers['x-github-event'] as string;
  const payload = req.body as GitHubWebhookEvent;

  logger.info('GitHub webhook event received', {
    event,
    action: payload.action,
    repository: payload.repository.full_name,
  });

  try {
    switch (event) {
      case 'push':
        await handlePush(payload);
        break;
      
      case 'pull_request':
        await handlePullRequest(payload);
        break;
      
      case 'issues':
        await handleIssue(payload);
        break;
      
      default:
        logger.debug('Unhandled GitHub event', { event });
    }

    res.status(200).send('OK');
  } catch (error) {
    logger.error('Error processing GitHub webhook', { error, event });
    throw error;
  }
}

async function handlePush(payload: GitHubWebhookEvent) {
  logger.info('Processing push event', { repository: payload.repository.full_name });
  
  // TODO: Implement push event handling
  // Could trigger Notion updates, Copilot Agent tasks, etc.
}

async function handlePullRequest(payload: GitHubWebhookEvent) {
  logger.info('Processing PR event', {
    repository: payload.repository.full_name,
    action: payload.action,
  });
  
  // TODO: Implement PR event handling
}

async function handleIssue(payload: GitHubWebhookEvent) {
  logger.info('Processing issue event', {
    repository: payload.repository.full_name,
    action: payload.action,
  });
  
  // TODO: Implement issue event handling
}
