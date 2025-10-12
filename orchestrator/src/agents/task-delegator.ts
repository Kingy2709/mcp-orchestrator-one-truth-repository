import type { Config } from '../config';
import { logger } from '../utils/logger';

interface Task {
  id: string;
  content: string;
  labels: string[];
}

export async function delegateTask(config: Config, task: Task) {
  if (!config.agentDelegationEnabled) {
    logger.debug('Agent delegation disabled, skipping', { taskId: task.id });
    return;
  }

  const triggerTags = config.agentTriggerTags.split(',').map(t => t.trim());
  const matchingTags = task.labels.filter(label => triggerTags.includes(label));

  if (matchingTags.length === 0) {
    logger.debug('No agent trigger tags found', { taskId: task.id, labels: task.labels });
    return;
  }

  logger.info('Delegating task to Copilot Agent', {
    taskId: task.id,
    matchingTags,
  });

  for (const tag of matchingTags) {
    try {
      await triggerAgent(tag, task);
    } catch (error) {
      logger.error('Failed to trigger agent', { error, tag, taskId: task.id });
    }
  }
}

async function triggerAgent(agentType: string, task: Task) {
  logger.info(`Triggering ${agentType} agent`, { taskId: task.id });

  // TODO: Implement actual Copilot Agent triggering via GitHub API
  // For now, just log the intention

  switch (agentType) {
    case 'research':
      logger.info('Would trigger research agent', {
        prompt: `Research: ${task.content}`,
        context: {
          taskId: task.id,
          notionDatabase: 'Research Hub',
        },
      });
      break;

    case 'code':
      logger.info('Would trigger code agent', {
        prompt: `Implement: ${task.content}`,
        context: {
          taskId: task.id,
          repository: 'mcp-orchestrator-one-truth-repository',
        },
      });
      break;

    case 'summary':
      logger.info('Would trigger summary agent', {
        prompt: `Summarize: ${task.content}`,
        context: {
          taskId: task.id,
        },
      });
      break;

    default:
      logger.warn('Unknown agent type', { agentType });
  }

  // TODO: Actual implementation would use GitHub Copilot API:
  // POST /repos/:owner/:repo/copilot/agents
  // or: gh copilot agent run --agent research-agent --prompt "..."
}
