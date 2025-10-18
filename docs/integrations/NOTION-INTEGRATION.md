# Notion Integration Guide

## Overview

This project uses **two different Notion integrations** for different purposes. Understanding the distinction is critical:

### 1. Internal Integration (for Orchestrator) ✅ ACTIVE
- **Purpose**: REST API access for bidirectional sync with Todoist
- **URL**: https://www.notion.so/my-integrations
- **Authentication**: Static integration token (stored in 1Password)
- **API Version**: `2025-09-03` (latest with data source support)
- **Permissions Required**: Read content, Update content, Insert content
- **Rate Limits**: 180 requests/minute (3 req/sec)

### 2. MCP Server (for AI Tools) 🤖 SEPARATE PURPOSE

**Two Options Available**:

#### Option A: Notion's Remote MCP Server (Recommended for AI Tools)
- **Purpose**: Connects AI tools (Claude Desktop, ChatGPT, Cursor) to Notion workspace
- **URL**: `https://mcp.notion.com/mcp`
- **Authentication**: OAuth flow through AI tool (one-click setup)
- **Use Case**: For using AI assistants with your Notion workspace
- **Documentation**: https://developers.notion.com/docs/get-started-with-mcp

#### Option B: Self-Hosted Open-Source MCP Server (Advanced)
- **Repository**: https://github.com/makenotion/notion-mcp-server
- **Purpose**: Run your own MCP server for AI tools (custom infrastructure)
- **Authentication**: Notion integration token (same as orchestrator)
- **Use Case**: Teams wanting full control, custom deployments
- **Package**: `@notionhq/notion-mcp-server`
- **Documentation**: https://developers.notion.com/docs/hosting-open-source-mcp

**Important**: MCP servers are **NOT** used by the orchestrator. They're for connecting AI assistants (like Claude, ChatGPT) to Notion. The orchestrator uses the REST API directly via an Internal Integration.

---

## Understanding the Architecture

### What is MCP (Model Context Protocol)?

[Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an **open standard** that lets AI assistants interact with external data sources. Think of it as a universal adapter that allows AI tools to connect to services like Notion.

**Key Points**:
- **MCP Client**: Built into AI tools (Claude, ChatGPT, Cursor, VS Code Copilot)
- **MCP Server**: Hosted service that provides tools/resources to AI clients
- **Notion MCP**: Notion's implementation that exposes Notion data to AI tools

### What Your Orchestrator Uses

```
Your MCP Orchestrator Project
├── Orchestrator (orchestrator/)
│   └── Uses: Internal Integration → Notion REST API
│   └── Purpose: Sync tasks between Todoist ↔ Notion
│   └── Authentication: Integration token (ntn_***)
│
└── MCP Server (mcp-servers/notion/)
    └── Uses: Open-source notion-mcp-server implementation
    └── Purpose: Connect AI tools (Claude, etc.) to Notion
    └── Authentication: Same integration token (ntn_***)
```

**They are DIFFERENT things**:
1. **Orchestrator**: Your custom Node.js service using `@notionhq/client` SDK
2. **MCP Server**: Optional service for AI assistants (Claude Desktop, Cursor, etc.)

Both can share the same Internal Integration token!

---

## Internal Integration Setup (Required for Orchestrator)

### Step 1: Create Integration

1. Visit https://www.notion.so/my-integrations
2. Click **"New integration"**
3. Configure:
   - **Name**: `MCP Orchestrator`
   - **Type**: Internal (associated with your workspace)
   - **Capabilities**:
     - ✅ Read content
     - ✅ Update content
     - ✅ Insert content
     - ✅ Read comments (optional, for future features)
4. Click **"Submit"**
5. Copy the **Internal Integration Token** (starts with `ntn_`)

### Step 2: Save Token to 1Password

```bash
# Save using 1Password CLI
op item edit "NOTION_API_KEY" \
  --vault "MCP Orchestrator" \
  credential="ntn_YOUR_ACTUAL_TOKEN_HERE"

# Verify it's saved
op read "op://fpaw6lqhfpib2j2k3z3w4v2ypq/4g2brrn7tdcn5yabtqiwfxkknq/credential"
```

### Step 3: Share Databases with Integration

**Critical**: Integration can only access databases/pages explicitly shared with it.

For each database:
1. Open database in Notion app
2. Click **"..."** menu (top right)
3. Scroll to **"Connections"**
4. Click **"Add connections"**
5. Search for **"MCP Orchestrator"**
6. Click to add connection

**Required Databases**:
- ✅ Inbox (`c30178af-80b9-4bc3-9b3e-40000d4afe2a`)
- ✅ To Do (`36285606-3c94-4f72-a5a4-2bacb5d04a7b`)
- ✅ Commands & Patterns (`c30178af-80b9-4bc3-9b3e-40000d4afe2a`)

### Step 4: Verify Access

```bash
# Test from orchestrator directory
cd orchestrator
npm run dev

# Expected log output:
# [info]: Retrieved X pages from Notion
# [info]: Notion sync completed successfully

# If you see "object_not_found" error:
# → Database not shared with integration (repeat Step 3)
```

---

## API Version 2025-09-03: Data Sources Model

### What Changed (September 2025)

Notion introduced **multi-source databases**, a breaking change requiring code updates.

**Old Model (2022-06-28)**:
```
Database (ID: abc123)
  └─ Page 1
  └─ Page 2
```

**New Model (2025-09-03)**:
```
Database (ID: abc123)
  ├─ Data Source 1 (ID: xyz789)
  │   ├─ Page 1
  │   └─ Page 2
  └─ Data Source 2 (ID: def456)  ← Multiple sources possible!
      ├─ Page 3
      └─ Page 4
```

### Migration Required

#### 1. **Discover Data Sources**
Before any operation, fetch data source IDs:

```typescript
// GET /v1/databases/{database_id}
// Notion-Version: "2025-09-03"
const response = await notion.databases.retrieve({ database_id });

console.log(response.data_sources);
// [{ id: "xyz789", name: "Main Tasks" }, { id: "def456", name: "Archive" }]
```

#### 2. **Update Page Creation**
Old (fails with multiple sources):
```typescript
await notion.pages.create({
  parent: {
    type: "database_id",
    database_id: "abc123"  // ❌ Ambiguous if multiple sources exist
  }
});
```

New (required):
```typescript
await notion.pages.create({
  parent: {
    type: "data_source_id",
    data_source_id: "xyz789"  // ✅ Explicit data source
  }
});
```

#### 3. **Update Database Queries**
Old:
```typescript
// PATCH /v1/databases/{database_id}/query  ❌
await notion.databases.query({ database_id: "abc123" });
```

New:
```typescript
// PATCH /v1/data_sources/{data_source_id}/query  ✅
await notion.dataSources.query({ data_source_id: "xyz789" });
```

### Orchestrator Implementation

See updated implementation in:
- `orchestrator/src/sync/notion.ts` - Data source discovery
- `orchestrator/src/sync/bidirectional.ts` - Updated sync logic

---

## Rate Limits & Best Practices

### Rate Limits
- **General**: 180 requests/minute (3 req/sec) per integration
- **Search**: 30 requests/minute (stricter limit)
- **Polling Interval**: 300,000ms (5 min) - well within limits
- **Error Handling**: Exponential backoff on 429 responses

### Security Best Practices

#### ✅ What We're Doing Right
- Storing API key in 1Password (never in code)
- Using environment variables for config
- UUID-based references (immutable, survives renames)
- Separate service account for read-only vault access

#### 🔐 Additional Recommendations
1. **Secret Scanning**: Add pre-commit hooks
   ```bash
   # Install gitleaks
   brew install gitleaks

   # Add to .git/hooks/pre-commit
   gitleaks protect --staged --verbose
   ```

2. **Key Rotation**: Set calendar reminder (quarterly)
   - Refresh token in Notion settings
   - Update 1Password item
   - Restart orchestrator

3. **Audit Logging**: All API calls logged via winston
   ```typescript
   logger.info('Notion API call', {
     endpoint: '/v1/databases/query',
     data_source_id: 'xyz789',
     timestamp: new Date().toISOString()
   });
   ```

### Permission Model
Integration has **same access level as workspace member** who created it:
- Can read any page/database shared with it
- Can create/update/delete within shared pages
- Cannot access pages not explicitly shared
- Cannot modify workspace settings or add members

---

## Webhook Integration (Optional Enhancement)

### Current: Polling-Based Sync
- Notion: Every 5 minutes (300,000ms)
- Todoist: Every 3 minutes (180,000ms)
- Pro: Simple, reliable
- Con: 5-minute latency for Notion changes

### Alternative: Webhook-Based Sync
Real-time notifications when Notion content changes.

#### Setup Steps
1. **Expose Webhook Endpoint**
   ```bash
   # Option A: ngrok (local dev)
   ngrok http 3000
   # → https://abc123.ngrok.io

   # Option B: Tailscale (secure tunnel)
   tailscale funnel 3000
   # → https://your-machine.tail-scale.ts.net

   # Option C: Deployed service (production)
   # → https://orchestrator.yourdomain.com
   ```

2. **Configure in Notion Integration Settings**
   - Go to https://www.notion.so/my-integrations
   - Select "MCP Orchestrator"
   - Navigate to "Webhooks" tab
   - Click "Add webhook"
   - URL: `https://your-endpoint/webhooks/notion`
   - API Version: `2025-09-03`
   - Events:
     - ✅ `data_source.content_updated`
     - ✅ `data_source.schema_updated`
     - ✅ `page.created`
     - ✅ `page.updated`

3. **Update Orchestrator**
   See implementation in `orchestrator/src/webhooks/notion.ts` (already created, needs webhook-specific handlers)

#### Webhook Event Example
```json
{
  "id": "367cba44-b6f3-4c92-81e7-6a2e9659efd4",
  "timestamp": "2024-12-05T23:55:34.285Z",
  "type": "page.created",
  "data": {
    "parent": {
      "id": "36cc9195-760f-4fff-a67e-3a46c559b176",
      "type": "database",
      "data_source_id": "98024f3c-b1d3-4aec-a301-f01e0dacf023"
    }
  }
}
```

#### Decision: Deferred Until Basic Sync Working
Webhooks are a nice-to-have enhancement. Recommendation:
1. ✅ First: Complete database sharing and verify polling sync works
2. ⏸️ Later: Add webhooks for real-time updates (requires public URL)

---

## TypeScript SDK Upgrade

### Current Version
Check your `orchestrator/package.json`:
```json
{
  "dependencies": {
    "@notionhq/client": "^2.2.15"  // ← Likely using v2.x
  }
}
```

### Required Version for 2025-09-03
```bash
cd orchestrator
npm install @notionhq/client@^5.0.0

# Update client initialization
```

**Breaking Changes in v5**:
- `notion.databases.query()` → `notion.dataSources.query()`
- `notion.databases.retrieve()` → Returns database with `data_sources` array
- New namespace: `notion.dataSources.*` for data source operations
- Must set `notionVersion: "2025-09-03"` in client config

Example:
```typescript
import { Client } from "@notionhq/client";

const notion = new Client({
  auth: process.env.NOTION_API_KEY,
  notionVersion: "2025-09-03"  // ← Required for data sources
});

// Discover data sources
const db = await notion.databases.retrieve({
  database_id: "abc123"
});

const dataSourceId = db.data_sources[0].id;

// Query using data source
const pages = await notion.dataSources.query({
  data_source_id: dataSourceId
});
```

---

## Troubleshooting

### Error: `object_not_found`
**Message**: "Make sure the relevant pages and databases are shared with your integration"

**Solution**: Database not shared with integration
1. Open database in Notion app
2. Click "..." → "Connections" → Add "MCP Orchestrator"
3. Restart orchestrator to retry

### Error: `validation_error` - Multiple Data Sources
**Message**: "Databases with multiple data sources are not supported in this API version"

**Solution**: Upgrade to API version `2025-09-03`
1. Update `@notionhq/client` to v5.x
2. Set `notionVersion: "2025-09-03"` in client
3. Implement data source discovery (see Migration section above)
4. Update all database operations to use `data_source_id`

### Error: `unauthorized` (401)
**Possible Causes**:
1. Integration token incorrect/expired
   - Verify 1Password item: `op read "op://..."`
   - Regenerate token in Notion settings if needed
2. Integration deleted/disabled
   - Check https://www.notion.so/my-integrations
3. Service Account token incorrect
   - Verify OP_SERVICE_ACCOUNT_TOKEN in .env
   - Test: `op whoami`

### Error: `rate_limited` (429)
**Solution**: Back off and retry
```typescript
// Already implemented in orchestrator/src/utils/retry.ts
async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (error.code === "rate_limited") {
        const delay = Math.pow(2, i) * 1000; // Exponential backoff
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
      throw error;
    }
  }
  throw new Error("Max retries exceeded");
}
```

---

## Related Documentation

- **Notion API Reference**: https://developers.notion.com/reference
- **Authorization Guide**: https://developers.notion.com/docs/authorization
- **2025-09-03 Upgrade Guide**: https://developers.notion.com/docs/upgrade-guide-2025-09-03
- **Best Practices (Security)**: https://developers.notion.com/docs/best-practices-for-handling-api-keys
- **MCP Server (AI Tools)**: https://developers.notion.com/docs/get-started-with-mcp
- **TypeScript SDK v5**: https://github.com/makenotion/notion-sdk-js

---

## Next Steps

1. ✅ **Immediate**: Share databases with integration (user action required)
2. ✅ **Short-term**: Verify polling sync working
3. 🔄 **Medium-term**: Upgrade to API v2025-09-03 and SDK v5
4. 🔄 **Long-term**: Implement webhooks for real-time sync
5. 🔄 **Ongoing**: Quarterly token rotation, secret scanning

**Status**: Waiting for user to complete Step 3 (Share Databases with Integration)
