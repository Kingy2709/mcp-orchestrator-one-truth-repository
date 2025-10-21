# CLI → Notion Bridge via n8n

> Use n8n webhooks to give GitHub Copilot CLI (and other tools) access to Notion databases.

## Table of Contents

1. [Overview](#overview)
2. [Workflow 1: Search Notion Tasks](#workflow-1-search-notion-tasks)
3. [Workflow 2: Create Notion Page](#workflow-2-create-notion-page)
4. [Workflow 3: Get Recent Tasks](#workflow-3-get-recent-tasks)
5. [CLI Integration](#cli-integration)
6. [Copilot Chat Integration](#copilot-chat-integration)
7. [Security](#security)
8. [Troubleshooting](#troubleshooting)

---

## Overview

**Problem:** GitHub Copilot CLI can't directly access Notion MCP servers.

**Solution:** Use n8n webhooks as a REST API gateway to Notion.

**Architecture:**

```
GitHub Copilot CLI / Shell Scripts
          ↓
    curl / HTTP request
          ↓
  n8n Webhook Endpoint (https://yourname.app.n8n.cloud/webhook/...)
          ↓
    Notion API Node
          ↓
   Format & Return JSON
          ↓
  Back to CLI / Copilot
```

**Benefits:**
- ✅ No custom code to maintain
- ✅ Uses your existing n8n setup
- ✅ Works with n8n Cloud or self-hosted
- ✅ Easy to add more endpoints
- ✅ Built-in Notion credential management

---

## Workflow 1: Search Notion Tasks

**Purpose:** Search your Notion To Do database from CLI

### n8n Workflow Configuration

**Step 1: Create New Workflow**

1. In n8n, click **+ Add Workflow**
2. Name: `CLI Bridge - Search Notion Tasks`

**Step 2: Add Webhook Trigger**

```yaml
Node: Webhook
Type: Webhook
HTTP Method: GET
Path: notion-search
Authentication: None (or Header Auth - see Security section)
Respond: Using 'Respond to Webhook' Node
```

**Step 3: Add Function Node (Parse Query)**

```javascript
// Extract search query from URL parameter
const query = $input.params.query || '';
const limit = parseInt($input.params.limit) || 10;

return {
  json: {
    query: query,
    limit: limit
  }
};
```

**Step 4: Add Notion Node (Query Database)**

```yaml
Node: Notion
Credential: Notion API (your existing credential)
Resource: Database Page
Operation: Get Many
Database: To Do (select your database)
Filters:
  - Property: Title
    Condition: Contains
    Value: {{ $json.query }}
Limit: {{ $json.limit }}
Sort:
  - Property: Last_Synced
    Direction: Descending
```

**Step 5: Add Function Node (Format Response)**

```javascript
// Format Notion results for CLI consumption
const tasks = $input.all().map(item => {
  const props = item.json.properties;
  
  return {
    id: item.json.id,
    title: props.Title?.title?.[0]?.plain_text || 'Untitled',
    status: props.Status?.status?.name || 'No Status',
    priority: props.Priority?.select?.name || 'None',
    due_date: props['Due Date']?.date?.start || null,
    tags: props.Tags?.multi_select?.map(t => t.name) || [],
    url: item.json.url
  };
});

return {
  json: {
    count: tasks.length,
    tasks: tasks
  }
};
```

**Step 6: Add Respond to Webhook Node**

```yaml
Node: Respond to Webhook
Response Code: 200
Response Body: {{ $json }}
```

**Step 7: Activate Workflow**

Click **Active** toggle in top right.

### Test in CLI

```bash
# Get webhook URL from n8n (click on Webhook node → "Test URL" or "Production URL")
WEBHOOK_URL="https://yourname.app.n8n.cloud/webhook/notion-search"

# Test search
curl "${WEBHOOK_URL}?query=OAuth&limit=5" | jq

# Expected output:
# {
#   "count": 3,
#   "tasks": [
#     {
#       "id": "abc123",
#       "title": "Research OAuth 2.0 flow",
#       "status": "In Progress",
#       "priority": "High",
#       "due_date": "2025-10-25",
#       "tags": ["@work", "@research"],
#       "url": "https://notion.so/..."
#     },
#     ...
#   ]
# }
```

---

## Workflow 2: Create Notion Page

**Purpose:** Create Notion tasks from CLI

### n8n Workflow Configuration

**Step 1: Create New Workflow**

Name: `CLI Bridge - Create Notion Task`

**Step 2: Add Webhook Trigger**

```yaml
Node: Webhook
HTTP Method: POST
Path: notion-create
Authentication: Header Auth (recommended - see Security)
Respond: Using 'Respond to Webhook' Node
```

**Step 3: Add Function Node (Parse Body)**

```javascript
// Extract task data from POST body
const body = $input.item.json.body || $input.item.json;

return {
  json: {
    title: body.title || 'Untitled Task',
    status: body.status || 'Not Started',
    priority: body.priority || 'Medium',
    tags: body.tags || [],
    notes: body.notes || ''
  }
};
```

**Step 4: Add Notion Node (Create Page)**

```yaml
Node: Notion
Resource: Database Page
Operation: Create
Database: To Do
Properties:
  Title: {{ $json.title }}
  Status: {{ $json.status }}
  Priority: {{ $json.priority }}
  Tags: {{ $json.tags }}
  Notes: {{ $json.notes }}
  Last_Synced: {{ $now }}
```

**Step 5: Add Function Node (Format Response)**

```javascript
const page = $input.item.json;

return {
  json: {
    success: true,
    id: page.id,
    url: page.url,
    title: page.properties.Title?.title?.[0]?.plain_text || 'Created'
  }
};
```

**Step 6: Add Respond to Webhook Node**

```yaml
Response Code: 201
Response Body: {{ $json }}
```

### Test in CLI

```bash
WEBHOOK_URL="https://yourname.app.n8n.cloud/webhook/notion-create"

# Create task
curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Research OAuth 2.0 implementation",
    "status": "Not Started",
    "priority": "High",
    "tags": ["@work", "@research"],
    "notes": "Need to understand GitHub OAuth flow for CLI integration"
  }' | jq

# Expected output:
# {
#   "success": true,
#   "id": "xyz789",
#   "url": "https://notion.so/...",
#   "title": "Research OAuth 2.0 implementation"
# }
```

---

## Workflow 3: Get Recent Tasks

**Purpose:** Get recent tasks (for quick status checks)

### n8n Workflow Configuration

**Step 1: Create New Workflow**

Name: `CLI Bridge - Recent Tasks`

**Step 2: Add Webhook Trigger**

```yaml
HTTP Method: GET
Path: notion-recent
```

**Step 3: Add Notion Node**

```yaml
Resource: Database Page
Operation: Get Many
Database: To Do
Filters: None (get all)
Sort:
  - Property: Last_Synced
    Direction: Descending
Limit: 20
```

**Step 4: Add Function Node (Format)**

```javascript
const tasks = $input.all().map(item => {
  const props = item.json.properties;
  
  return {
    title: props.Title?.title?.[0]?.plain_text || 'Untitled',
    status: props.Status?.status?.name || 'No Status',
    due_date: props['Due Date']?.date?.start || null,
    last_synced: props.Last_Synced?.date?.start || null
  };
});

// Group by status
const grouped = tasks.reduce((acc, task) => {
  const status = task.status;
  if (!acc[status]) acc[status] = [];
  acc[status].push(task);
  return acc;
}, {});

return {
  json: {
    total: tasks.length,
    by_status: grouped,
    tasks: tasks.slice(0, 10) // Top 10
  }
};
```

**Step 5: Respond to Webhook**

### Test in CLI

```bash
curl "https://yourname.app.n8n.cloud/webhook/notion-recent" | jq

# Expected output:
# {
#   "total": 15,
#   "by_status": {
#     "In Progress": [{ ... }, { ... }],
#     "Not Started": [{ ... }],
#     "Done": [{ ... }]
#   },
#   "tasks": [...]
# }
```

---

## CLI Integration

### Create Shell Aliases

**Add to `~/.zshrc`:**

```bash
# =============================================================================
# Notion CLI Bridge (via n8n)
# =============================================================================
# n8n webhook base URL (Cloud or self-hosted)
export N8N_NOTION_BASE="https://yourname.app.n8n.cloud/webhook"

# Search Notion tasks
notion-search() {
  local query="${1:-}"
  local limit="${2:-10}"
  
  if [ -z "$query" ]; then
    echo "Usage: notion-search <query> [limit]"
    return 1
  fi
  
  curl -s "${N8N_NOTION_BASE}/notion-search?query=${query}&limit=${limit}" | jq
}

# Create Notion task
notion-create() {
  local title="$1"
  
  if [ -z "$title" ]; then
    echo "Usage: notion-create <title>"
    return 1
  fi
  
  curl -s -X POST "${N8N_NOTION_BASE}/notion-create" \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"$title\",\"status\":\"Not Started\",\"tags\":[\"@cli\"]}" | jq
}

# Get recent tasks
notion-recent() {
  curl -s "${N8N_NOTION_BASE}/notion-recent" | jq '.tasks[] | "\(.status): \(.title)"'
}

# Notion status summary
notion-status() {
  curl -s "${N8N_NOTION_BASE}/notion-recent" | jq -r '.by_status | to_entries[] | "\(.key): \(.value | length) tasks"'
}
```

**Reload shell:**

```bash
exec zsh
```

### Usage Examples

```bash
# Search for OAuth tasks
notion-search "OAuth"

# Search with limit
notion-search "research" 5

# Create task
notion-create "Review PR for OAuth integration"

# Check recent tasks
notion-recent

# Status summary
notion-status
# Output:
# In Progress: 3 tasks
# Not Started: 5 tasks
# Done: 7 tasks
```

---

## Copilot Chat Integration

### Use in Terminal with Copilot

```bash
# Search and analyze with Copilot
notion-search "OAuth" | copilot "summarize these tasks and suggest next steps"

# Create task from Copilot suggestion
copilot "suggest a task for implementing OAuth" | notion-create

# Get context for Copilot
copilot "based on these tasks: $(notion-recent), what should I prioritize?"
```

### Create Copilot Shortcut (Future)

When GitHub Copilot CLI supports plugins:

```json
// ~/.copilot/plugins/notion.json
{
  "name": "notion",
  "description": "Query Notion tasks",
  "commands": {
    "search": {
      "endpoint": "https://yourname.app.n8n.cloud/webhook/notion-search",
      "method": "GET"
    }
  }
}
```

---

## Security

### Option 1: No Authentication (Development Only)

**Use for:** Testing, local self-hosted n8n

**Risk:** Anyone with webhook URL can access your Notion data

### Option 2: Header Authentication (Recommended)

**In n8n Webhook Node:**

```yaml
Authentication: Header Auth
Header Name: X-API-Key
Expected Value: your-secret-key-here
```

**Generate secret key:**

```bash
# Generate random key
openssl rand -hex 32

# Store in 1Password
op item create --category "API Credential" \
  --vault "CLI" \
  --title "n8n.api-key.cli" \
  credential="<generated-key>"

# Add to .zshrc
export N8N_API_KEY=$(op read "op://CLI/n8n.api-key.cli/credential")
```

**Update aliases to use auth:**

```bash
notion-search() {
  curl -s -H "X-API-Key: $N8N_API_KEY" \
    "${N8N_NOTION_BASE}/notion-search?query=${1}&limit=${2:-10}" | jq
}
```

### Option 3: IP Whitelist (n8n Cloud Pro)

**For n8n Cloud Pro subscribers:**

1. Settings → Security → IP Whitelist
2. Add your home/office IP
3. Webhooks only accessible from whitelisted IPs

---

## Troubleshooting

### Issue: Webhook returns 404

**Symptoms:**
```bash
curl "https://yourname.app.n8n.cloud/webhook/notion-search"
# 404 Not Found
```

**Fix:**

1. Check workflow is **Active** (toggle in top right)
2. Use **Production URL** (not Test URL) from webhook node
3. Verify path matches: `/webhook/notion-search` (no typo)

---

### Issue: Empty results

**Symptoms:**
```json
{
  "count": 0,
  "tasks": []
}
```

**Fix:**

1. Check Notion database ID is correct
2. Verify Notion credential has database access
3. Test query in Notion UI first
4. Check filter syntax in Notion node

---

### Issue: Authentication error

**Symptoms:**
```bash
curl -H "X-API-Key: wrong-key" "..."
# 401 Unauthorized
```

**Fix:**

1. Verify API key in n8n webhook node settings
2. Check `$N8N_API_KEY` environment variable:
   ```bash
   echo $N8N_API_KEY | head -c 20
   ```
3. Reload shell: `exec zsh`

---

### Issue: Slow response (>5s)

**Cause:** Notion API is slow, or n8n processing complex data

**Fix:**

1. Reduce limit: `?limit=5` instead of 50
2. Add caching layer (future enhancement)
3. Use webhook response timeout in n8n
4. Consider background job + polling pattern

---

## Advanced: Background Job Pattern

**For long-running queries:**

### Workflow 1: Start Job

```
Webhook (POST /notion-search-async)
  ↓
Generate Job ID
  ↓
Store in n8n database (or Redis)
  ↓
Return Job ID immediately
  ↓
(Background) Query Notion
  ↓
Update job status
```

### Workflow 2: Check Status

```
Webhook (GET /notion-search-status?job_id=...)
  ↓
Lookup job in database
  ↓
Return status + results if complete
```

---

## Cost Estimate (n8n Cloud)

| Activity | Per Request | Daily (10 queries) | Monthly |
|----------|-------------|-------------------|---------|
| Search tasks | 3-5 executions | 30-50 | 900-1,500 |
| Create task | 2-3 executions | 6-9 | 180-270 |
| Recent tasks | 3-4 executions | 12-16 | 360-480 |
| **Total** | **~10** | **~50** | **~1,500** |

**Conclusion:** Well within n8n Starter quota (2,500/month) ✅

---

## Next Steps

1. **Create workflows** in n8n (3 workflows, ~15 minutes)
2. **Add aliases** to .zshrc (~5 minutes)
3. **Test in terminal** (search, create, recent)
4. **Integrate with Copilot** (pipe to copilot command)
5. **Add authentication** (Header Auth with 1Password key)

---

## References

- n8n Webhook Documentation: <https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/>
- Notion API Reference: <https://developers.notion.com/reference/intro>
- Project Repository: [mcp-orchestrator-one-truth-repository](https://github.com/Kingy2709/mcp-orchestrator-one-truth-repository)

---

**Ready to build?** Start with Workflow 1 (Search) and test in CLI. Once working, add the other two workflows and shell aliases! 🚀
