import { logger } from '../utils/logger';

interface Task {
  id: string;
  content: string;
  labels: string[];
}

interface TaskGroup {
  groupId: string;
  groupName: string;
  tasks: Task[];
  similarity: number;
}

export async function groupSimilarTasks(newTask: Task, existingTasks: Task[]): Promise<TaskGroup | null> {
  logger.info('Analyzing task for grouping', { taskId: newTask.id });

  try {
    const similarTasks = await findSimilarTasks(newTask, existingTasks);

    if (similarTasks.length === 0) {
      logger.debug('No similar tasks found', { taskId: newTask.id });
      return null;
    }

    const groupName = await suggestGroupName(newTask, similarTasks);

    const group: TaskGroup = {
      groupId: `group-${Date.now()}`,
      groupName,
      tasks: [newTask, ...similarTasks],
      similarity: calculateAverageSimilarity(similarTasks),
    };

    logger.info('Task group created', {
      groupId: group.groupId,
      groupName: group.groupName,
      taskCount: group.tasks.length,
      similarity: group.similarity,
    });

    return group;
  } catch (error) {
    logger.error('Failed to group tasks', { error, taskId: newTask.id });
    return null;
  }
}

async function findSimilarTasks(targetTask: Task, candidates: Task[]): Promise<Task[]> {
  // TODO: Implement embeddings-based similarity search
  // For now, use simple keyword matching

  const targetWords = new Set(
    targetTask.content.toLowerCase().split(/\W+/).filter(w => w.length > 3)
  );

  const similar: Array<{ task: Task; score: number }> = [];

  for (const candidate of candidates) {
    if (candidate.id === targetTask.id) continue;

    const candidateWords = new Set(
      candidate.content.toLowerCase().split(/\W+/).filter(w => w.length > 3)
    );

    // Calculate Jaccard similarity
    const intersection = new Set([...targetWords].filter(x => candidateWords.has(x)));
    const union = new Set([...targetWords, ...candidateWords]);
    const similarity = intersection.size / union.size;

    if (similarity > 0.3) {
      similar.push({ task: candidate, score: similarity });
    }
  }

  // Sort by similarity and return top 5
  return similar
    .sort((a, b) => b.score - a.score)
    .slice(0, 5)
    .map(s => s.task);
}

async function suggestGroupName(task: Task, similarTasks: Task[]): Promise<string> {
  // TODO: Use AI to generate meaningful group name
  // For now, extract common words

  const allContent = [task, ...similarTasks].map(t => t.content).join(' ');
  const words = allContent.toLowerCase().split(/\W+/);

  const wordFreq = words.reduce((acc, word) => {
    if (word.length > 3) {
      acc[word] = (acc[word] || 0) + 1;
    }
    return acc;
  }, {} as Record<string, number>);

  const topWords = Object.entries(wordFreq)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([word]) => word);

  return topWords.join(' ') + ' project';
}

function calculateAverageSimilarity(tasks: Task[]): number {
  // Placeholder: return static value
  // TODO: Calculate actual average similarity score
  return 0.65;
}
