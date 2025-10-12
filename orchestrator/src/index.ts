import { config } from './config';
import { startNotionSync } from './sync/notion';
import { startTodoistSync } from './sync/todoist';
import { initializeLogger, logger } from './utils/logger';
import { webhookServer } from './webhooks/server';

async function main() {
  try {
    // Load config (with 1Password resolution if needed)
    const cfg = await config;

    // Initialize logger with resolved config
    initializeLogger(cfg);

    logger.info('Starting MCP Orchestrator...', {
      version: process.env.npm_package_version,
      nodeVersion: process.version,
      env: cfg.nodeEnv,
    });

    // Start webhook server
    const app = webhookServer(cfg);
    const server = app.listen(cfg.port, () => {
      logger.info(`Webhook server listening on port ${cfg.port}`);
    });

    // Start sync engines
    if (cfg.syncIntervalNotion > 0) {
      startNotionSync(cfg, cfg.syncIntervalNotion);
      logger.info(`Notion sync started (interval: ${cfg.syncIntervalNotion}ms)`);
    }

    if (cfg.syncIntervalTodoist > 0) {
      startTodoistSync(cfg, cfg.syncIntervalTodoist);
      logger.info(`Todoist sync started (interval: ${cfg.syncIntervalTodoist}ms)`);
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
