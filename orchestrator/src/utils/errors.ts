export class OrchestratorError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
    public details?: unknown
  ) {
    super(message);
    this.name = 'OrchestratorError';
    Error.captureStackTrace(this, this.constructor);
  }
}

export class NotionError extends OrchestratorError {
  constructor(message: string, details?: unknown) {
    super(message, 'NOTION_ERROR', 500, details);
    this.name = 'NotionError';
  }
}

export class TodoistError extends OrchestratorError {
  constructor(message: string, details?: unknown) {
    super(message, 'TODOIST_ERROR', 500, details);
    this.name = 'TodoistError';
  }
}

export class WebhookError extends OrchestratorError {
  constructor(message: string, statusCode: number = 400, details?: unknown) {
    super(message, 'WEBHOOK_ERROR', statusCode, details);
    this.name = 'WebhookError';
  }
}

export class ConfigurationError extends OrchestratorError {
  constructor(message: string, details?: unknown) {
    super(message, 'CONFIG_ERROR', 500, details);
    this.name = 'ConfigurationError';
  }
}

export class SyncConflictError extends OrchestratorError {
  constructor(message: string, details?: unknown) {
    super(message, 'SYNC_CONFLICT', 409, details);
    this.name = 'SyncConflictError';
  }
}
