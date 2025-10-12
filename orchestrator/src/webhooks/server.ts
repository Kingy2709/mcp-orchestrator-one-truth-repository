import express, { Express, NextFunction, Request, Response } from 'express';
import { WebhookError } from '../utils/errors';
import { logger } from '../utils/logger';
import { handleGitHubWebhook } from './github';
import { handleTodoistWebhook } from './todoist';

export function webhookServer(): Express {
  const app = express();

  // Middleware
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  // Request logging
  app.use((req: Request, res: Response, next: NextFunction) => {
    logger.info('Incoming request', {
      method: req.method,
      path: req.path,
      ip: req.ip,
    });
    next();
  });

  // Health check endpoint
  app.get('/health', (req: Request, res: Response) => {
    res.status(200).json({
      status: 'ok',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      services: {
        notion: 'connected', // TODO: Add real health checks
        todoist: 'connected',
        onepassword: 'connected',
      },
    });
  });

  // Todoist webhook
  app.post('/webhooks/todoist', async (req: Request, res: Response) => {
    try {
      await handleTodoistWebhook(req, res);
    } catch (error) {
      logger.error('Todoist webhook handler error', { error });
      res.status(500).json({ error: 'Internal server error' });
    }
  });

  // GitHub webhook
  app.post('/webhooks/github', async (req: Request, res: Response) => {
    try {
      await handleGitHubWebhook(req, res);
    } catch (error) {
      logger.error('GitHub webhook handler error', { error });
      res.status(500).json({ error: 'Internal server error' });
    }
  });

  // 404 handler
  app.use((req: Request, res: Response) => {
    res.status(404).json({ error: 'Not found' });
  });

  // Error handler
  app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
    logger.error('Unhandled error', { error: err, path: req.path });

    if (err instanceof WebhookError) {
      res.status(err.statusCode).json({ error: err.message });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  });

  return app;
}
