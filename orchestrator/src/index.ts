import { config } from './config';
import { startNotionSync } from './sync/notion';
import { startTodoistSync } from './sync/todoist';
import { logger } from './utils/logger';
import { webhookServer } from './webhooks/server';

async function main() {
  try {
    logger.info('Starting MCP Orchestrator...', {
      version: process.env.npm_package_version,
      nodeVersion: process.version,
      env: config.nodeEnv,
    });

    // Start webhook server
    const app = webhookServer();
    const server = app.listen(config.port, () => {
      logger.info(`Webhook server listening on port ${config.port}`);
    });

    // Start sync engines
    if (config.syncIntervalNotion > 0) {
      startNotionSync(config.syncIntervalNotion);
      logger.info(`Notion sync started (interval: ${config.syncIntervalNotion}ms)`);
    }

    if (config.syncIntervalTodoist > 0) {
      startTodoistSync(config.syncIntervalTodoist);
      logger.info(`Todoist sync started (interval: ${config.syncIntervalTodoist}ms)`);
    }

    // Graceful shutdown
    const shutdown = async (signal: string) => {
      logger.info(`Received ${signal}, shutting down gracefully...`);

      server.close(() => {
        logger.info('HTTP server closed');
        process.exit(0);
      });

      // Force exit after 10s
      setTimeout(() => {
        logger.error('Forced shutdown after timeout');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

  } catch (error) {
    logger.error('Fatal error during startup', { error });
    process.exit(1);
  }
}

main();
