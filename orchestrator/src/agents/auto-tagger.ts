import { config } from '../config';
import { logger } from '../utils/logger';

interface Task {
  id: string;
  content: string;
  labels: string[];
}

interface TaggingResult {
  suggestedTags: string[];
  confidence: number;
}

export async function autoTagTask(task: Task): Promise<TaggingResult> {
  if (!config.aiTaggingEnabled) {
    logger.debug('AI tagging disabled, skipping', { taskId: task.id });
    return { suggestedTags: [], confidence: 0 };
  }

  logger.info('Auto-tagging task', { taskId: task.id, content: task.content });

  try {
    const result = await analyzeTaskContent(task.content);

    logger.info('Auto-tagging complete', {
      taskId: task.id,
      suggestedTags: result.suggestedTags,
      confidence: result.confidence,
    });

    // TODO: Apply tags to Todoist task via API

    return result;
  } catch (error) {
    logger.error('Failed to auto-tag task', { error, taskId: task.id });
    return { suggestedTags: [], confidence: 0 };
  }
}

async function analyzeTaskContent(content: string): Promise<TaggingResult> {
  // TODO: Implement actual AI analysis using GPT-4 or Claude
  // For now, use simple keyword matching

  const suggestedTags: string[] = [];

  // Work-related keywords
  if (/\b(meeting|client|project|deadline|presentation)\b/i.test(content)) {
    suggestedTags.push('@work');
  }

  // Personal keywords
  if (/\b(home|family|personal|grocery|shopping)\b/i.test(content)) {
    suggestedTags.push('@personal');
  }

  // Research keywords
  if (/\b(research|investigate|learn|study|explore)\b/i.test(content)) {
    suggestedTags.push('@research');
  }

  // Code keywords
  if (/\b(code|implement|fix|debug|refactor|feature)\b/i.test(content)) {
    suggestedTags.push('@code');
  }

  // Urgent keywords
  if (/\b(urgent|asap|critical|important|priority)\b/i.test(content)) {
    suggestedTags.push('@urgent');
  }

  const confidence = suggestedTags.length > 0 ? 0.7 : 0.3;

  return { suggestedTags, confidence };
}

// Future: Implement embeddings-based tagging with OpenAI or Claude API
async function analyzeWithEmbeddings(content: string): Promise<TaggingResult> {
  // TODO: Use OpenAI embeddings or Claude API for semantic analysis
  // const embedding = await openai.embeddings.create({ input: content, model: "text-embedding-3-small" });
  // Compare with known tag embeddings to find best matches

  return { suggestedTags: [], confidence: 0 };
}
