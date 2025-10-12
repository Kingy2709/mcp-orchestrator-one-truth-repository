# Architecture

## System Overview

The MCP Orchestrator is a distributed system running locally on macOS that provides a single source of truth across AI tools. It consists of:

1. **Core Orchestrator Service** - Central coordination and sync logic
2. **MCP Server Layer** - Protocol implementations for each service
3. **Webhook Receivers** - Event-driven triggers from external services
4. **AI Agents** - Automated task processing via GitHub Copilot
5. **Raycast Extensions** - Quick capture and search interfaces

## Data Flow

### Voice Capture Flow

```
Siri Command
    ↓
Todoist (natural language parse)
    ↓
Webhook Event → Orchestrator
    ↓
AI Auto-Tagger (analyze content)
    ↓
┌─────────────┬─────────────┬─────────────┐
│             │             │             │
▼             ▼             ▼             ▼
Notion      Google      Todoist      Agent
Database    Calendar    (update)     (delegate)
```

### Bidirectional Sync Flow

```
Notion Database          Todoist Tasks
       ↓                        ↓
   [Change                [Change
    Event]                 Event]
       ↓                        ↓
       └──→ Orchestrator ←──────┘
               │
               ├─→ Conflict Resolution
               │   (timestamp + priority)
               │
               ├─→ Update Notion
               ├─→ Update Todoist
               └─→ Update Google Calendar
```

### Agent Delegation Flow

```
Task Created: "Research OAuth @research"
    ↓
Orchestrator detects @research tag
    ↓
Trigger Copilot Agent via GitHub API
    ↓
Agent Executes:
├─→ GitHub repo search
├─→ Documentation scraping
├─→ Summary generation
└─→ Notion page creation
    ↓
Update Todoist: "Research complete"
    ↓
Notification to user
```

## Component Architecture

### Orchestrator Service

```
orchestrator/
├── src/
│   ├── index.ts              # Entry point, PM2 daemon
│   ├── config.ts             # Env loading, Zod validation
│   │
│   ├── sync/
│   │   ├── notion.ts         # Notion API client + sync
│   │   ├── todoist.ts        # Todoist API client + sync
│   │   └── bidirectional.ts  # Conflict resolution logic
│   │
│   ├── webhooks/
│   │   ├── server.ts         # Express server (port 3000)
│   │   ├── todoist.ts        # POST /webhooks/todoist
│   │   └── github.ts         # POST /webhooks/github
│   │
│   ├── agents/
│   │   ├── task-delegator.ts # Tag detection → Agent trigger
│   │   ├── auto-tagger.ts    # AI categorization rules
│   │   └── task-grouper.ts   # Similarity detection (embeddings)
│   │
│   ├── secrets/
│   │   └── onepassword.ts    # Service Account SDK wrapper
│   │
│   └── utils/
│       ├── logger.ts         # Winston structured logging
│       └── errors.ts         # Custom error classes
```

**Key Dependencies:**
- `@notionhq/client` - Official Notion SDK
- `@doist/todoist-api-typescript` - Todoist SDK
- `@1password/sdk` - Service Account integration
- `express` - Webhook HTTP server
- `winston` - Structured logging
- `zod` - Runtime validation

**Runtime:**
- PM2 process manager (not LaunchAgent)
- Restarts on crash
- Log rotation (max 10MB, 7 days)
- Health check endpoint: `GET /health`

### MCP Server Layer

Each MCP server implements the [Model Context Protocol](https://modelcontextprotocol.io) specification:

```
mcp-servers/
├── notion/          # Notion MCP server
│   └── src/
│       ├── index.ts    # MCP server entry
│       ├── tools.ts    # Available tools:
│       │               #   - search_pages
│       │               #   - create_page
│       │               #   - update_page
│       │               #   - query_database
│       └── types.ts    # Notion type definitions
│
├── todoist/         # Todoist MCP server
│   └── src/
│       ├── index.ts
│       └── tools.ts    # Tools:
│                       #   - list_tasks
│                       #   - create_task
│                       #   - update_task
│                       #   - complete_task
│
├── onepassword/     # 1Password MCP server (read-only)
│   └── src/
│       ├── index.ts
│       └── tools.ts    # Tools:
│                       #   - get_secret
│                       #   - list_items
│
└── orchestrator/    # Meta-operations MCP server
    └── src/
        ├── index.ts
        └── tools.ts    # Tools:
                        #   - trigger_sync
                        #   - get_status
                        #   - list_agents
```

**Protocol:**
- Transport: stdio (for local) or HTTP (for remote)
- Message format: JSON-RPC 2.0
- Authentication: 1Password Service Account token

**Usage:**
- Copilot Chat uses MCP servers as tools
- Example: "Use Notion MCP to search for OAuth research"

### Webhook Receivers

```typescript
// webhooks/server.ts
const app = express();

app.post('/webhooks/todoist', async (req, res) => {
  const event = req.body; // Todoist event payload
  
  // Verify webhook signature
  if (!verifyTodoistSignature(req)) {
    return res.status(401).send('Invalid signature');
  }
  
  // Process event
  switch (event.event_name) {
    case 'item:added':
      await handleTaskAdded(event.event_data);
      break;
    case 'item:completed':
      await handleTaskCompleted(event.event_data);
      break;
  }
  
  res.status(200).send('OK');
});
```

**Webhook Sources:**
- Todoist: Task events (create, complete, update, delete)
- GitHub: Repository events (push, PR, issue)

**Configuration:**
- Todoist webhook URL: `https://<tailscale-ip>:3000/webhooks/todoist`
- GitHub webhook URL: `https://<tailscale-ip>:3000/webhooks/github`
- Use Tailscale for secure tunnel (no ngrok/public IP needed)

### AI Agents

```typescript
// agents/task-delegator.ts
export async function delegateTask(task: Task) {
  const tags = task.labels;
  
  if (tags.includes('research')) {
    await triggerCopilotAgent({
      agent: 'research-agent',
      prompt: `Research: ${task.content}`,
      context: {
        taskId: task.id,
        notionDatabase: 'Research Hub',
      },
    });
  }
  
  if (tags.includes('code')) {
    await triggerCopilotAgent({
      agent: 'code-agent',
      prompt: `Implement: ${task.content}`,
      context: {
        taskId: task.id,
        repository: 'mcp-orchestrator-one-truth-repository',
      },
    });
  }
}
```

**Agent Configurations:**
- `agents/research-agent.yml` - GitHub search + doc scraping
- `agents/code-agent.yml` - Implementation with PR creation
- `agents/summary-agent.yml` - Content synthesis

**Trigger Mechanism:**
- Copilot Agents API (GitHub REST API)
- Or: GitHub CLI `gh copilot agent run`

### Raycast Extensions

```bash
# raycast-extensions/quick-task.sh
#!/usr/bin/env bash

# Quick capture to Todoist via Raycast
task="$1"
priority="${2:-4}"

curl -X POST "https://api.todoist.com/rest/v2/tasks" \
  -H "Authorization: Bearer $TODOIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"content\":\"$task\",\"priority\":$priority}"
```

**Available Scripts:**
- `quick-task.sh` - Siri/Raycast → Todoist
- `save-to-notion.sh` - Clipboard → Notion page
- `search-everything.sh` - Unified search (Notion + Todoist + GitHub)

**Installation:**
- Copy to `~/.config/raycast/scripts/`
- Set executable: `chmod +x *.sh`
- Configure in Raycast preferences

## Security

### Secret Management

```
1Password Service Account
    ↓
orchestrator/src/secrets/onepassword.ts
    ↓
Load secrets at runtime:
├─→ NOTION_API_KEY
├─→ TODOIST_API_TOKEN
├─→ GITHUB_PAT
└─→ WEBHOOK_SECRET
    ↓
Store in memory (never disk)
```

**Best Practices:**
- ✅ Use 1Password Service Account (not Environments or `op inject`)
- ✅ Rotate tokens quarterly
- ✅ Scope GitHub PAT to minimum permissions
- ✅ Verify webhook signatures
- ❌ Never log secrets
- ❌ Never commit .env files

### Network Security

```
Local Mac (orchestrator)
    ↓
Tailscale VPN (100.x.x.x)
    ↓
├─→ Notion API (HTTPS)
├─→ Todoist API (HTTPS)
├─→ GitHub API (HTTPS)
└─→ 1Password API (HTTPS)
```

**Tailscale Benefits:**
- Private IP (no public exposure)
- End-to-end encryption
- Works behind NAT/firewall
- Access from iPhone/iPad via Tailscale app

## Deployment

### Local Development

```bash
# Start orchestrator
cd orchestrator
npm run dev

# Start MCP servers
cd mcp-servers/notion
npm start
```

### Docker Compose (Recommended)

```yaml
# docker-compose.yml
version: '3.8'

services:
  orchestrator:
    build: ./orchestrator
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - OP_SERVICE_ACCOUNT_TOKEN=${OP_SERVICE_ACCOUNT_TOKEN}
    restart: unless-stopped
    volumes:
      - ./logs:/app/logs

  mcp-notion:
    build: ./mcp-servers/notion
    restart: unless-stopped

  mcp-todoist:
    build: ./mcp-servers/todoist
    restart: unless-stopped

  mcp-onepassword:
    build: ./mcp-servers/onepassword
    restart: unless-stopped

  mcp-orchestrator:
    build: ./mcp-servers/orchestrator
    restart: unless-stopped
```

**Commands:**
- `docker-compose up -d` - Start all services
- `docker-compose logs -f orchestrator` - View logs
- `docker-compose restart orchestrator` - Restart service
- `docker-compose down` - Stop all services

### PM2 (Alternative)

```bash
# Install PM2
npm install -g pm2

# Start orchestrator
pm2 start orchestrator/dist/index.js --name mcp-orchestrator

# Start MCP servers
pm2 start mcp-servers/notion/dist/index.js --name mcp-notion
pm2 start mcp-servers/todoist/dist/index.js --name mcp-todoist

# Save configuration
pm2 save

# Auto-start on Mac boot
pm2 startup
```

## Monitoring

### Health Checks

```bash
# Check orchestrator status
curl http://localhost:3000/health

# Response:
# {
#   "status": "ok",
#   "uptime": 3600,
#   "services": {
#     "notion": "connected",
#     "todoist": "connected",
#     "onepassword": "connected"
#   }
# }
```

### Logging

```typescript
// utils/logger.ts
import winston from 'winston';

export const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
  ],
});
```

**Log Rotation:**
- Max size: 10MB per file
- Keep: 7 days
- Compress: gzip old logs

**Key Metrics:**
- Sync latency (Notion ↔ Todoist)
- Webhook processing time
- Agent delegation success rate
- API error rates

## Scaling Considerations

**Current Design (Single Mac):**
- ✅ Sufficient for 1 user
- ✅ Low latency (local network)
- ✅ No cloud costs

**Future Multi-User (Not Implemented):**
- Move to cloud (AWS/GCP)
- Add PostgreSQL for state
- Redis for task queue
- Horizontal scaling with Kubernetes

## References

- [Model Context Protocol Spec](https://modelcontextprotocol.io/docs)
- [Notion API Reference](https://developers.notion.com/reference)
- [Todoist API Reference](https://developer.todoist.com/rest/v2)
- [1Password Service Accounts](https://developer.1password.com/docs/service-accounts)
- [GitHub Copilot Agents](https://github.com/features/copilot)
