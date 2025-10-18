# MCP Server Setup Guide

## Overview

This guide explains how to set up the **Notion MCP Server** to connect AI assistants (Claude Desktop, ChatGPT, Cursor, VS Code) to your Notion workspace.

**Important**: This is **separate** from the orchestrator service. The MCP server is for AI tools, not for the Todoist sync.

---

## What is the Notion MCP Server?

The Notion MCP Server implements the [Model Context Protocol](https://modelcontextprotocol.io/), allowing AI assistants to:
- Read pages and databases
- Create and update content
- Search across your workspace
- Manage tasks and properties

**Two Deployment Options**:

### 1. Notion's Remote MCP (Recommended)
- **URL**: `https://mcp.notion.com/mcp`
- **Setup**: One-click OAuth in AI tool settings
- **Pros**: No infrastructure, instant setup, optimized for AI
- **Cons**: Less customization, requires OAuth per AI tool

### 2. Self-Hosted Open-Source MCP (Advanced)
- **Repository**: https://github.com/makenotion/notion-mcp-server
- **Setup**: Run locally or deploy to your infrastructure
- **Pros**: Full control, use existing integration token, customizable
- **Cons**: Requires maintenance, manual setup

---

## Option 1: Notion's Remote MCP (Easiest)

### Step 1: Connect via AI Tool

#### Claude Desktop
1. Open Claude Desktop
2. Go to **Settings** → **Developer** → **Model Context Protocol**
3. Click **"Add Server"**
4. Select **"Notion"** from directory
5. Complete OAuth flow (authorizes Claude to access Notion)

#### ChatGPT
1. Open ChatGPT
2. Go to **Settings** → **Connectors** ([direct link](https://chatgpt.com/#settings/Connectors))
3. Click **"Add Connection"**
4. Select **"Notion"**
5. Authorize access to your workspace

#### Cursor
1. Open Cursor
2. Go to **Settings** → **MCP Servers**
3. Search for **"Notion"** in MCP directory
4. Click **"Connect"** and authorize

### Step 2: Grant Page Access

After OAuth:
1. Open databases you want AI to access
2. Click **"..."** → **"Connections"**
3. Add the **MCP connection** (shows as "Notion MCP" or AI tool name)

### Step 3: Test Connection

In your AI tool, try:
```
Search my Notion workspace for "project planning"
```

Expected behavior:
- AI searches your Notion pages
- Returns relevant results
- Can read page contents if granted access

---

## Option 2: Self-Hosted MCP Server (Your Project)

### Why Self-Host?

Your project includes `mcp-servers/notion/` which uses the open-source implementation. Benefits:
- **Reuse existing integration**: Same `ntn_***` token as orchestrator
- **Full control**: Customize tools, add features, control infrastructure
- **Local development**: Test AI integrations without OAuth
- **Cost-effective**: No per-user OAuth, one integration token

### Architecture

```
Your Machine
├── Orchestrator (orchestrator/)
│   └── Port 3000: Webhook server & sync service
│   └── Uses: @notionhq/client (Notion SDK)
│
└── MCP Server (mcp-servers/notion/)
    └── STDIO or HTTP transport
    └── Uses: @notionhq/notion-mcp-server
    └── Connects: AI tools → Your Notion integration
```

### Setup Instructions

#### 1. Install MCP Server Package

```bash
cd mcp-servers/notion

# Option A: Install Notion's package
npm install @notionhq/notion-mcp-server

# Option B: Use npx (no install needed)
# Configuration will reference npx directly
```

#### 2. Configure AI Tool (Claude Desktop Example)

**File**: `~/Library/Application\ Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "notionApi": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_TOKEN": "ntn_YOUR_INTEGRATION_TOKEN_HERE"
      }
    }
  }
}
```

**Using your orchestrator's token**:
```json
{
  "mcpServers": {
    "notionApi": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_TOKEN": "op://fpaw6lqhfpib2j2k3z3w4v2ypq/4g2brrn7tdcn5yabtqiwfxkknq/credential"
      }
    }
  }
}
```

**Note**: Claude Desktop doesn't support 1Password CLI resolution in `env`. You'll need to:
1. Read token: `op read "op://fpaw6lqhfpib2j2k3z3w4v2ypq/4g2brrn7tdcn5yabtqiwfxkknq/credential"`
2. Paste actual token value in config

#### 3. Configure for Cursor

**File**: `~/.cursor/mcp.json`

```json
{
  "mcpServers": {
    "notionApi": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_TOKEN": "ntn_YOUR_TOKEN_HERE"
      }
    }
  }
}
```

#### 4. Configure for VS Code Copilot

**File**: VS Code settings JSON

```json
{
  "github.copilot.chat.mcpServers": {
    "notionApi": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_TOKEN": "ntn_YOUR_TOKEN_HERE"
      }
    }
  }
}
```

### Alternative: HTTP Transport (For Web Apps)

If building a web interface that needs MCP access:

```bash
# Start MCP server with HTTP transport
npx @notionhq/notion-mcp-server --transport http --port 3001

# Auto-generated auth token shown in console:
# Generated auth token: a1b2c3d4e5f6789abcdef...
```

**Making requests**:
```bash
curl -H "Authorization: Bearer your-mcp-auth-token" \
     -H "Content-Type: application/json" \
     -H "mcp-session-id: session-123" \
     -d '{"jsonrpc": "2.0", "method": "initialize", "params": {}, "id": 1}' \
     http://localhost:3001/mcp
```

---

## MCP Server Capabilities

### Available Tools (via MCP Protocol)

When AI tools connect to Notion MCP, they get access to:

#### Search & Discovery
- `notion-search`: Search pages, databases, and connected tools (Slack, Drive, Jira)
- `notion-fetch`: Retrieve page/database content by URL
- `notion-get-teams`: List teamspaces and membership
- `notion-get-users`: Retrieve user information

#### Content Creation
- `notion-create-pages`: Create one or more pages with properties
- `notion-create-database`: Create new databases with schema
- `notion-update-page`: Modify page properties or content
- `notion-update-database`: Update database properties

#### Organization
- `notion-move-pages`: Move pages to different parents
- `notion-duplicate-page`: Clone pages (async operation)

#### Collaboration
- `notion-create-comment`: Add comments to pages
- `notion-get-comments`: Retrieve discussion threads

### Rate Limits (Same as REST API)

- **General**: 180 requests/minute (3 req/sec)
- **Search**: 30 requests/minute (stricter)

AI tools automatically handle rate limiting by spacing requests.

---

## Comparison: Remote vs Self-Hosted

|  | **Notion's Remote MCP** | **Self-Hosted MCP Server** |
|---|---|---|
| **Setup Complexity** | One-click OAuth | Manual integration token config |
| **Authentication** | Per-user OAuth | Shared integration token |
| **Infrastructure** | Notion-hosted (no maintenance) | Run locally or deploy |
| **API Version** | Latest (2025-09-03) | Configurable (supports older versions) |
| **Customization** | None (pre-built tools) | Full (open-source, forkable) |
| **Cost** | Free (Notion-hosted) | Free (self-hosted, optional deployment costs) |
| **Use Case** | Quick AI assistant connections | Custom integrations, internal tools |
| **Supported Clients** | Claude, ChatGPT, Cursor, more | Any MCP-compatible client |

---

## Integration with Your Orchestrator

### Shared Resources

Both orchestrator and MCP server can use the **same Notion integration**:

```
Internal Integration: "MCP Orchestrator"
├── Token: ntn_*** (stored in 1Password)
├── Used by: Orchestrator (@notionhq/client SDK)
└── Used by: MCP Server (@notionhq/notion-mcp-server)
```

**Permissions**: Integration needs access to same databases
- ✅ Orchestrator syncs: Inbox, To Do, Commands & Patterns
- ✅ MCP Server reads/writes: Same databases (if shared)

### Why You Might Want Both

1. **Orchestrator**: Automated background sync (Todoist ↔ Notion)
2. **MCP Server**: Interactive AI commands via Claude/Cursor

**Example Workflow**:
1. Create task in Todoist via Siri
2. Orchestrator syncs to Notion automatically
3. Ask Claude: "Show me tasks due this week"
4. Claude uses MCP to search Notion database
5. You ask: "Create project plan for task X"
6. Claude uses MCP to create structured Notion pages

---

## Testing Your MCP Server

### Via Claude Desktop

```
Test commands to try in Claude:

1. "Search my Notion workspace for 'orchestrator'"
2. "Show me all pages in my To Do database"
3. "Create a new page titled 'MCP Test' in my Inbox"
4. "What tasks are marked as urgent?"
```

### Via Cursor

```
Test in Cursor chat:

1. Right-click on file → Ask Copilot
2. "Create a technical spec in Notion for this file"
3. Cursor uses MCP to create page with code analysis
```

### Via VS Code

```
Test in Copilot Chat:

1. @workspace "Document this function in Notion"
2. Copilot uses MCP to create/update Notion page
```

---

## Troubleshooting

### Error: "MCP server not responding"

**Cause**: MCP server not running or config incorrect

**Solution**:
1. Check AI tool logs (usually in settings/developer tools)
2. Verify `command` path is correct (`npx` available in PATH)
3. Test manually:
   ```bash
   npx -y @notionhq/notion-mcp-server
   # Should start and show "MCP server running"
   ```

### Error: "Notion API authentication failed"

**Cause**: Integration token incorrect or not accessible

**Solution**:
1. Verify token in 1Password:
   ```bash
   op read "op://fpaw6lqhfpib2j2k3z3w4v2ypq/4g2brrn7tdcn5yabtqiwfxkknq/credential"
   ```
2. Paste actual token (not `op://` reference) in AI tool config
3. Ensure token starts with `ntn_`

### Error: "Database not found" or "No results"

**Cause**: Databases not shared with integration

**Solution**:
- Open database in Notion
- Click "..." → "Connections"
- Add "MCP Orchestrator" integration
- Retry AI command

### MCP Server Not Appearing in AI Tool

**Cause**: Config file location incorrect or JSON invalid

**Solution**:
1. **Claude Desktop**: `~/Library/Application Support/Claude/claude_desktop_config.json`
2. **Cursor**: `~/.cursor/mcp.json`
3. Validate JSON syntax (no trailing commas, proper quotes)
4. Restart AI tool after config changes

---

## Advanced: Custom MCP Tools

### Forking the Open-Source MCP Server

```bash
# Clone Notion's MCP server
git clone https://github.com/makenotion/notion-mcp-server.git
cd notion-mcp-server

# Install dependencies
npm install

# Build
npm run build

# Run locally
npm start
```

**Customize**: Edit `src/` to add custom tools, modify behavior

**Example Custom Tool**:
```typescript
// src/tools/custom-sync.ts
export async function syncToTodoist(notionPageId: string) {
  // Your custom logic here
  // Call your orchestrator's API
  // Trigger immediate sync
}
```

---

## Next Steps

### If Using Notion's Remote MCP
1. ✅ Connect AI tool via OAuth (5 minutes)
2. ✅ Share databases with MCP connection
3. ✅ Test AI commands
4. 🎉 Use AI assistants with Notion!

### If Using Self-Hosted MCP
1. ✅ Use existing integration token from orchestrator
2. ✅ Configure AI tool with MCP server command
3. ✅ Restart AI tool to load config
4. ✅ Test MCP tools via AI chat
5. 🎉 Full control over MCP implementation!

### Resources

- **MCP Protocol Spec**: https://modelcontextprotocol.io/
- **Notion MCP Docs**: https://developers.notion.com/docs/mcp
- **Open-Source Server**: https://github.com/makenotion/notion-mcp-server
- **SDK for JavaScript**: https://github.com/makenotion/notion-sdk-js
- **MCP Clients**: https://developers.notion.com/docs/common-mcp-clients

**Status**: Optional enhancement for AI tool integration (not required for orchestrator sync)
