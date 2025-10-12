# ADHD-Optimized Workflows

Strategies and patterns for maintaining focus and reducing context-switching.

## Core Principles

1. **Friction-Free Capture** - Less than 5 seconds from thought to storage
2. **Automatic Organization** - AI handles tagging and categorization
3. **Backend Operation** - Minimal UI interaction required
4. **Context Preservation** - Everything connects back to Notion
5. **Delegate When Possible** - Let agents handle research/implementation

## Workflow Patterns

### Quick Capture Flow

**Problem**: Ideas lost while trying to open apps

**Solution**: Voice → Todoist → Auto-processed

```
You: "Hey Siri, add to Todoist: Research OAuth 2.0 best practices"
  ↓
Todoist: Creates task with natural language parsing
  ↓
Orchestrator: Detects "research" keyword
  ↓
Auto-tags: @research, @work
  ↓
Triggers: research-agent (runs in background)
  ↓
Saves: Notion page with findings
  ↓
Notifies: Todoist comment "Research complete!"
```

**Time: < 5 seconds** for capture, agent runs async

### Context-Switching Reduction

**Problem**: Jumping between apps breaks flow

**Solution**: Live in Calendar + Raycast

- **Calendar View**: Todoist syncs all priority tasks (priority 1-3)
- **Raycast Search**: Unified search across Notion + Todoist
- **Never Open Apps**: Everything accessible via Raycast commands

```bash
# Raycast commands
⌘+Space → "Quick Task: Review PR"
⌘+Space → "Search: OAuth research"
⌘+Space → "Show Today" (Todoist in Raycast)
```

### Priority Management

**Problem**: Everything feels urgent

**Solution**: AI-based priority detection + Calendar sync

```
Task content → AI analysis → Priority suggestion

"Fix production bug" → Priority 1 (urgent, blocks)
"Research new framework" → Priority 3 (important)
"Clean desk" → Priority 4 (low)
```

**Only Priority 1-3 appear in Calendar** → reduces visual clutter

### Task Grouping

**Problem**: Similar tasks scattered across lists

**Solution**: AI detects similarity, suggests projects

```
Tasks:
- Research React patterns
- Learn React hooks
- Read React docs

Orchestrator → Detects similarity (embeddings)
  ↓
Suggests: "React Learning" project
  ↓
User confirms (one-click in Todoist)
```

### Recurring Task Logging

**Problem**: Can't see completion patterns

**Solution**: Log to Notion automatically

```
Complete: "Take medication" (daily recurring)
  ↓
Orchestrator logs to Notion:
- Completion timestamp
- Streak count (days in a row)
- Time taken
- Notes (optional)
  ↓
Todoist creates next occurrence
  ↓
Notion shows streak graph
```

**Benefit**: Visual motivation from streak tracking

### Agent Delegation

**Problem**: Research/implementation tasks get postponed

**Solution**: Tag with @research/@code, agent handles it

```
Task: "Research best state management for React @research"
  ↓
Orchestrator → Triggers research-agent
  ↓
Agent (background):
1. Searches GitHub (Redux, Zustand, Jotai, etc.)
2. Reads documentation
3. Compares approaches
4. Creates Notion page with summary
  ↓
Updates Todoist: "Research complete! View: [link]"
```

**Time saved**: 1-2 hours of manual research

### Notification Management

**Problem**: Constant interruptions break focus

**Solution**: Batch notifications, context-aware timing

**Settings**:
- **Todoist**: Notifications off (orchestrator handles)
- **Notion**: Notifications off
- **Orchestrator**: Only notifies when:
  - Agent completes task
  - Sync conflict needs resolution
  - High-priority task overdue

**Result**: Check orchestrator once per day, or when convenient

## Daily Workflow

### Morning (5 minutes)

1. Open Raycast → "Show Today"
2. Review Calendar (synced from Todoist)
3. Re-prioritize if needed (drag in Calendar)
4. Close all apps

### Throughout Day

- **Capture**: Voice to Siri (instant)
- **Check progress**: Glance at Calendar
- **Never context-switch**: Let orchestrator handle background tasks

### Evening (5 minutes)

1. Review Notion → Completions log
2. Check agent-generated research
3. Archive completed projects
4. Plan tomorrow (voice capture)

## Advanced Patterns

### Project-Based Focus

Create Todoist filters:
- `@work & today` → Work mode
- `@personal & today` → Personal mode
- `@urgent` → Emergency mode

Orchestrator respects filters for Calendar sync

### Context Stacking

Link related items:
- Todoist task → Notion page (auto-linked by orchestrator)
- Notion page → GitHub PR (agent creates link)
- GitHub PR → Todoist task (webhook updates)

**Benefit**: Full context always available, no manual linking

### Batch Processing

Schedule "process inbox" blocks:
- Morning: 9:00 AM
- Lunch: 12:30 PM
- Evening: 5:00 PM

Orchestrator accumulates non-urgent notifications, delivers in batches

## Customization

### Auto-Tagging Rules

Edit `orchestrator/src/agents/auto-tagger.ts`:

```typescript
// Add custom patterns
if (/\b(gym|workout|exercise)\b/i.test(content)) {
  suggestedTags.push('@health');
}
```

### Agent Triggers

Edit `agents/*.yml` to add keywords:

```yaml
triggers:
  - tag: "@research"
  - keyword: "research"
  - keyword: "investigate"
  - keyword: "compare"  # Add custom trigger
```

### Sync Intervals

Edit `.env`:

```bash
SYNC_INTERVAL_NOTION=180000  # 3 minutes (faster)
SYNC_INTERVAL_TODOIST=300000 # 5 minutes (slower)
```

## Tips

1. **Trust the System**: Let orchestrator handle organization
2. **Capture Everything**: Filter later, not during capture
3. **Review Weekly**: Check Notion for insights (streak tracking, completion patterns)
4. **Delegate Aggressively**: Use @research/@code tags liberally
5. **Minimize Apps**: Live in Calendar + Raycast only

## Metrics to Track

Orchestrator logs to Notion:
- **Capture latency**: Siri → Todoist → Notion time
- **Agent success rate**: % of delegated tasks completed
- **Context switches**: How often you open Todoist/Notion apps
- **Task completion rate**: Daily/weekly completion %

**Goal**: < 1 minute total time in Todoist/Notion apps per day
