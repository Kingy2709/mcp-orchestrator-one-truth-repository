# Notion Developer Reference

Complete reference for Notion API, MCP, and integration patterns. Updated for **Notion 3.0** (API version 2025-09-03).

---

## Table of Contents

- [Quick Links](#quick-links)
- [Integration Strategy for This Project](#integration-strategy-for-this-project)
- [Public vs Internal Integration](#public-vs-internal-integration)
- [Notion MCP vs REST API vs Custom MCP](#notion-mcp-vs-rest-api-vs-custom-mcp)
- [Architecture for Multi-Device Workflow](#architecture-for-multi-device-workflow)
- [Documentation Links by Category](#documentation-links-by-category)
- [Notion 3.0 Key Changes](#notion-30-key-changes)

---

## Quick Links

| Resource | URL |
|----------|-----|
| **Developer Home** | https://developers.notion.com |
| **Getting Started** | https://developers.notion.com/docs/getting-started |
| **API Reference** | https://developers.notion.com/reference/intro |
| **Changelog** | https://developers.notion.com/page/changelog |
| **Examples** | https://developers.notion.com/page/examples |

---

## Integration Strategy for This Project

### Your Architecture Goal

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Workflow Vision                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Raycast (MacOS)          ──────►  Orchestrator (Mac)        │
│  Quick capture scripts              Sync service daemon      │
│  Search everything                  Port 3000                │
│                                                               │
│  Notion (MacOS/iOS)       ◄────────►  Orchestrator           │
│  Document organization              Bidirectional sync       │
│  Notion AI intelligence             REST API                 │
│                                                               │
│  Todoist (MacOS/iOS)      ◄────────►  Orchestrator           │
│  Task management                    Bidirectional sync       │
│  Quick capture via Siri             REST API                 │
│                                                               │
│  VS Code Copilot (MacOS)  ──────►  Custom MCP Server         │
│  Primary developer agent            Optional: AI context     │
│  Terminal integration               from Notion/Todoist      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Recommended Integration Type: **Internal Integration** ✅

**Why Internal (Private) Integration?**

✅ **Correct for your use case**:
- Personal automation (not distributing to others)
- Single workspace access
- Simpler setup (no OAuth flow)
- Direct API token management
- Full control over permissions
- Cheaper/easier to maintain

⚠️ **Public Integration downsides** (for personal use):
- ⚠️ More complex setup (OAuth implementation required)
- ⚠️ Requires web server for OAuth callback URL
- ⚠️ Token management complexity (access + refresh tokens)
- ⚠️ App review process if distributing publicly
- ✅ **No functional downside** if you implement OAuth correctly
- ❌ **Unnecessary complexity** for single-workspace personal use
- 💡 **Verdict**: Internal Integration is simpler and sufficient for your needs

**Your Current Setup is Optimal**:
```
Internal Integration: "MCP Orchestrator"
├── Token: ntn_*** (in 1Password)
├── Workspace: Your personal Notion
├── Permissions: Read/Update/Insert content
└── Used by:
    ├── Orchestrator (REST API sync)
    └── Custom MCP Server (optional AI access)
```

---

## Public vs Internal Integration

### Internal Integration (Private) 🔒

**Best for**: Personal automation, internal tools, single workspace

**Characteristics**:
- ✅ Private to your workspace
- ✅ Simple setup (create → copy token)
- ✅ No OAuth flow needed
- ✅ Direct API access
- ✅ Manual page sharing
- ✅ Full API access (all endpoints)
- ✅ No app review process

**Token Management**:
- Static token: `ntn_***` (never expires unless revoked)
- Store in 1Password (your current setup)
- Use in server-side code only
- Can be revoked/regenerated anytime

**Use Cases**:
- ✅ Your orchestrator (Todoist ↔ Notion sync)
- ✅ Custom MCP server (AI tool integration)
- ✅ Personal automation scripts
- ✅ Internal team tools

**Setup**:
1. https://www.notion.so/my-integrations
2. Create "New integration"
3. Name: "MCP Orchestrator"
4. Associated workspace: Your workspace
5. Capabilities: Read/Update/Insert content
6. Copy "Internal Integration Secret"
7. Share databases with integration

---

### Public Integration (OAuth) 🌐

**Best for**: Distribution to other users, SaaS products, marketplace apps

**Characteristics**:
- ✅ Multi-workspace support
- ✅ User authorization flow
- ✅ Granular permissions (OAuth scopes)
- ✅ User can revoke access
- ⚠️ Complex OAuth implementation
- ⚠️ Requires web server for callback
- ⚠️ App review for Notion integrations directory

**Token Management**:
- OAuth 2.0 flow (authorization code)
- Access token: Short-lived (expires in hours)
- Refresh token: Long-lived (get new access tokens)
- Token introspection API (check validity)
- Token revocation API (user revokes)

**Use Cases**:
- ❌ Not needed for your orchestrator
- ❌ Overkill for personal use
- ✅ If building SaaS product for others
- ✅ If distributing in Notion integrations directory

**Setup**:
1. Create public integration
2. Configure OAuth redirect URLs
3. Implement OAuth flow in your app
4. Handle access/refresh tokens
5. Submit for app review (if distributing)

**OAuth Flow**:
```
User → Clicks "Connect Notion" button
     → Redirected to Notion authorization page
     → Grants permissions to your app
     → Redirected back to your app with code
     → Your app exchanges code for access token
     → Your app stores tokens securely
     → Your app makes API requests with access token
```

---

### Comparison Table

|  | **Internal Integration** | **Public Integration** |
|---|---|---|
| **Setup Time** | 5 minutes | Several hours |
| **Authentication** | Static token | OAuth 2.0 |
| **Token Lifespan** | Permanent (until revoked) | Access: Hours, Refresh: Long-lived |
| **Workspace Access** | Single workspace | Multiple workspaces |
| **Distribution** | Private only | Can distribute to others |
| **OAuth Implementation** | None required | Full OAuth flow needed |
| **Web Server** | Not required | Required (for OAuth callback) |
| **User Authorization** | Manual page sharing | OAuth consent screen |
| **Revocation** | Integration settings | User can revoke anytime |
| **App Review** | None | Required for directory listing |
| **Use Case** | ✅ Personal automation (your project) | ❌ SaaS products for others |

---

## Notion MCP vs REST API vs Custom MCP

### Understanding the Three Approaches

```
┌─────────────────────────────────────────────────────────────┐
│                Your Project Uses All Three                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  1. REST API (Direct)              orchestrator/             │
│     ├── Use: Automated sync        @notionhq/client          │
│     ├── Auth: Internal token       Direct HTTP requests      │
│     └── Purpose: Todoist ↔ Notion  Background daemon         │
│                                                               │
│  2. Notion MCP (Remote)            https://mcp.notion.com    │
│     ├── Use: AI tools              Claude, ChatGPT           │
│     ├── Auth: OAuth                One-click setup           │
│     └── Purpose: AI workspace      Optional: Easy setup      │
│                                                               │
│  3. Custom MCP (Self-hosted)       mcp-servers/notion/       │
│     ├── Use: AI tools              VS Code Copilot           │
│     ├── Auth: Internal token       Same as orchestrator      │
│     └── Purpose: AI workspace      Optional: Full control    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

### 1. REST API (Direct) 🔧

**What**: Direct HTTP requests to Notion's REST API

**Used By**: Your orchestrator service

**Architecture**:
```
orchestrator/src/sync/notion.ts
    ↓
@notionhq/client SDK
    ↓
HTTPS requests to api.notion.com
    ↓
Notion workspace (your databases)
```

**When to Use**:
- ✅ **Automated sync** (Todoist ↔ Notion)
- ✅ **Background daemon** (runs 24/7 on Mac)
- ✅ **Programmatic access** (scheduled operations)
- ✅ **Batch operations** (sync many tasks)
- ✅ **Custom business logic** (auto-tagging, grouping)

**Pros**:
- ✅ Full API access (all endpoints)
- ✅ Predictable, documented behavior
- ✅ TypeScript SDK available
- ✅ Rate limits: 180 req/min (3 req/sec)
- ✅ Direct control over all operations
- ✅ No intermediary services

**Cons**:
- ⚠️ Requires code (not point-and-click)
- ⚠️ Manual error handling
- ⚠️ Must handle rate limits
- ⚠️ No AI-optimized tools

**Code Example**:
```typescript
// Your orchestrator/src/sync/notion.ts
import { Client } from '@notionhq/client';

const notion = new Client({
  auth: process.env.NOTION_API_KEY,
  notionVersion: '2025-09-03'
});

// Query database
const database = await notion.databases.retrieve({
  database_id: 'your-database-id'
});

const dataSourceId = database.data_sources[0].id;

const response = await notion.dataSources.query({
  data_source_id: dataSourceId,
  filter: {
    property: 'Status',
    select: { equals: 'In Progress' }
  }
});

// Create page
await notion.pages.create({
  parent: {
    type: 'data_source_id',
    data_source_id: dataSourceId
  },
  properties: {
    'Name': { title: [{ text: { content: 'New task' } }] },
    'Status': { select: { name: 'To Do' } }
  }
});
```

**This is Your Primary Integration** ✅

---

### 2. Notion MCP (Remote Hosted) ☁️

**What**: Notion's hosted MCP server at https://mcp.notion.com/mcp

**Used By**: AI tools (Claude Desktop, ChatGPT, Cursor)

**Important Clarification**:
- ✅ **YES, this IS what you're doing!** MCP servers connect AI assistants to data sources
- Your project uses MCP to connect **VS Code Copilot** and **Notion AI** to Notion/Todoist
- The orchestrator (background daemon) uses REST API directly (not MCP)
- MCP = AI tool integration (which is your primary goal!)

**Architecture**:
```
Claude Desktop
    ↓
MCP Protocol (STDIO/HTTP)
    ↓
https://mcp.notion.com/mcp (Notion's server)
    ↓
OAuth token for user's workspace
    ↓
Notion workspace (your databases)
```

**When to Use**:
- ✅ **AI assistants** (Claude, ChatGPT, Cursor, Notion AI)
- ✅ **Quick setup** (one-click OAuth)
- ✅ **No infrastructure** (Notion hosts it)
- ✅ **AI-optimized tools** (token-efficient)
- ✅ **This IS AI tool integration** (what you're building!)
- ❌ Not for orchestrator background daemon (use REST API for that)

**Pros**:
- ✅ One-click setup (OAuth in AI tool)
- ✅ No infrastructure to maintain
- ✅ Optimized for AI agents
- ✅ Supports multiple AI tools
- ✅ Notion manages updates

**Cons**:
- ⚠️ OAuth per AI tool (not shared token)
- ⚠️ Less customization
- ⚠️ Depends on Notion's uptime
- ⚠️ Can't modify available tools

**Setup**:
```json
// Claude Desktop: ~/Library/Application Support/Claude/claude_desktop_config.json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-client-notion"],
      "env": {
        "NOTION_OAUTH_URL": "https://mcp.notion.com/mcp"
      }
    }
  }
}
```

Then authorize via Claude's UI (one-click OAuth).

**Available Tools** (AI can use):
- `notion-search`: Search pages/databases
- `notion-fetch`: Get page by URL
- `notion-create-pages`: Create pages
- `notion-update-page`: Modify pages
- `notion-create-database`: Create databases
- `notion-get-teams`: List teamspaces
- `notion-get-users`: User info
- `notion-create-comment`: Add comments

**This is Optional for Your Project** (if you want AI tools)

---

### 3. Custom MCP (Self-Hosted) 🏗️

**What**: Open-source MCP server you run locally

**Used By**: AI tools (VS Code Copilot, Claude, Cursor)

**Architecture**:
```
VS Code Copilot
    ↓
MCP Protocol (STDIO)
    ↓
mcp-servers/notion/ (your local server)
    ↓
Internal Integration token (same as orchestrator)
    ↓
Notion workspace (your databases)
```

**When to Use**:
- ✅ **VS Code Copilot** (your primary AI agent)
- ✅ **Custom tools** (add features not in Notion MCP)
- ✅ **Same token** (reuse orchestrator's integration)
- ✅ **Full control** (modify, extend, debug)
- ✅ **Local development** (no OAuth needed)
- ❌ Not for orchestrator (use REST API)

**Pros**:
- ✅ Reuse integration token
- ✅ Full customization (add custom tools)
- ✅ Local control (debug, modify)
- ✅ No OAuth complexity
- ✅ Works offline (local network)

**Cons**:
- ⚠️ Requires setup/maintenance
- ⚠️ Must run server process
- ⚠️ You handle updates
- ⚠️ More complex than remote MCP

**Setup**:
```json
// VS Code settings.json
{
  "github.copilot.chat.mcpServers": {
    "notionApi": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_TOKEN": "ntn_your_token_here"
      }
    }
  }
}
```

Or use your custom implementation:
```bash
cd mcp-servers/notion
npm install
npm run build
npm start  # Runs MCP server on STDIO
```

**Available Tools** (same as remote MCP):
- All standard MCP tools
- ✅ Plus: Add custom tools (e.g., `sync-to-todoist`)

**This is Optional but Recommended** for VS Code Copilot integration

---

### Comparison Table

|  | **REST API (Direct)** | **Notion MCP (Remote)** | **Custom MCP (Self-Hosted)** |
|---|---|---|---|
| **Purpose** | Automated sync | AI tools access | AI tools access |
| **Authentication** | Internal token | OAuth per AI tool | Internal token (shared) |
| **Setup Complexity** | Medium (code required) | Easy (one-click) | Medium (server setup) |
| **Infrastructure** | Your orchestrator daemon | Notion-hosted | You host locally |
| **Customization** | Full (any logic) | None (pre-built tools) | Full (open-source) |
| **Rate Limits** | 180 req/min | 180 req/min | 180 req/min (shared) |
| **Best For** | ✅ Orchestrator sync | AI assistants (quick) | ✅ VS Code Copilot |
| **Your Project** | ✅ **Primary** (orchestrator/) | Optional (easy AI) | ✅ **Recommended** (mcp-servers/) |
| **Token Sharing** | N/A | No (OAuth per tool) | ✅ Yes (same token) |
| **Offline Use** | ✅ Yes (local daemon) | ❌ No (cloud service) | ✅ Yes (local server) |

---

### Recommended Setup for Your Project

```
Your Mac
├── Orchestrator (orchestrator/)
│   ├── Method: REST API (Direct)
│   ├── SDK: @notionhq/client
│   ├── Auth: Internal token (ntn_***)
│   ├── Purpose: Todoist ↔ Notion automated sync
│   └── Status: ✅ PRIMARY (critical for workflow)
│
├── Custom MCP Server (mcp-servers/notion/)
│   ├── Method: MCP Protocol (Self-Hosted)
│   ├── Package: @notionhq/notion-mcp-server
│   ├── Auth: Same internal token (ntn_***)
│   ├── Purpose: VS Code Copilot access to Notion context
│   └── Status: ✅ RECOMMENDED (enhances Copilot)
│
└── Optional: Notion MCP (Remote)
    ├── Method: MCP Protocol (Notion-Hosted)
    ├── URL: https://mcp.notion.com/mcp
    ├── Auth: OAuth (separate from token)
    ├── Purpose: Claude Desktop or other AI tools
    └── Status: ⚠️ OPTIONAL (only if using Claude/ChatGPT)
```

**Why This Setup?**
1. **REST API**: Best for orchestrator (automated sync, background daemon)
2. **Custom MCP**: Best for VS Code Copilot (reuse token, full control)
3. **Remote MCP**: Optional if you use Claude Desktop (easy OAuth)

---

## Architecture for Multi-Device Workflow

### Your Goal: MacOS + iOS Seamless Work

```
┌─────────────────────────────────────────────────────────────┐
│                     MacOS (Primary)                          │
├─────────────────────────────────────────────────────────────┤
│  Orchestrator Daemon                                         │
│  ├── PM2 managed (always running)                            │
│  ├── Syncs Todoist ↔ Notion (every 3-5 min)                 │
│  └── Webhook server (port 3000)                              │
│                                                               │
│  Raycast                                                      │
│  ├── Quick capture scripts (raycast-extensions/)             │
│  ├── Search everything (Notion + Todoist)                    │
│  └── Trigger: Cmd+Space → type → capture                     │
│                                                               │
│  VS Code + Copilot                                            │
│  ├── Primary developer agent (code, terminal)                │
│  ├── Custom MCP Server (mcp-servers/notion/)                 │
│  └── Context from Notion/Todoist via MCP                     │
│                                                               │
│  Notion Desktop App                                           │
│  ├── Document organization                                    │
│  ├── Notion AI (summarize, write, organize)                  │
│  └── Syncs to Todoist via orchestrator                       │
│                                                               │
│  Todoist Desktop App                                          │
│  ├── Task management                                          │
│  ├── Quick add (Cmd+Shift+A)                                 │
│  └── Syncs to Notion via orchestrator                        │
└─────────────────────────────────────────────────────────────┘

                              ↕ Cloud Sync ↕

┌─────────────────────────────────────────────────────────────┐
│                  iOS (Full Development Capable!)             │
├─────────────────────────────────────────────────────────────┤
│  Raycast iOS App ✅                                          │
│  ├── Quick capture (same as MacOS)                           │
│  ├── Search across Notion + Todoist                          │
│  ├── Script commands available                               │
│  └── Syncs with Mac via Raycast cloud                        │
│                                                               │
│  Notion iOS App                                               │
│  ├── Full access to workspace                                │
│  ├── Notion AI available (same as desktop)                   │
│  ├── File MCP integration (access Mac files)                 │
│  └── Syncs via Notion cloud ✅                               │
│                                                               │
│  Todoist iOS App                                              │
│  ├── Full task management                                     │
│  ├── Siri quick capture ("Add task to Todoist")              │
│  ├── Widgets, notifications                                   │
│  └── Syncs via Todoist cloud ✅                              │
│                                                               │
│  GitHub iOS App with Copilot ✅                              │
│  ├── GitHub Copilot Chat available                           │
│  ├── Create repositories                                      │
│  ├── Review/edit code                                         │
│  ├── Merge PRs, manage issues                                │
│  └── Full repository access                                  │
│                                                               │
│  Working Copy App ✅ (Git + Terminal + AI)                   │
│  ├── Full-featured Git client                                │
│  ├── SSH terminal access (tmux support)                      │
│  ├── AI integration (Copilot-like features)                  │
│  ├── Code editor with syntax highlighting                    │
│  ├── Execute commands on Mac via SSH                         │
│  └── Sync with GitHub, GitLab, etc.                          │
│                                                               │
│  Shortcuts App (iOS)                                          │
│  ├── Custom workflows                                         │
│  ├── Siri integration                                         │
│  ├── SSH to Mac (execute commands)                           │
│  └── Trigger orchestrator webhooks                           │
│                                                               │
│  Tailscale VPN ✅                                            │
│  ├── Secure tunnel to Mac                                    │
│  ├── Access orchestrator API (port 3000)                     │
│  ├── SSH to Mac from anywhere                                │
│  └── Execute remote commands                                 │
└─────────────────────────────────────────────────────────────┘
```

### Does This Work? ✅ ABSOLUTELY YES!

**What Works Seamlessly Everywhere**:
1. ✅ **Raycast (MacOS + iOS)** → Orchestrator → Notion/Todoist
2. ✅ **Notion (MacOS/iOS + AI)** → Cloud sync + File MCP for Mac files
3. ✅ **Todoist (MacOS/iOS)** → Cloud sync → Always in sync
4. ✅ **Orchestrator (Mac)** → Syncs both directions (Notion ↔ Todoist)
5. ✅ **VS Code Copilot (MacOS)** → Custom MCP → Full context
6. ✅ **GitHub Copilot (iOS)** → Via GitHub app → Create repos, review code
7. ✅ **Working Copy (iOS)** → SSH to Mac → Execute commands, edit code
8. ✅ **Tailscale (iOS)** → VPN tunnel → Access Mac orchestrator remotely

**Only Limitation**:
1. ⚠️ **Orchestrator daemon**: Runs on Mac only (not iOS)
   - Solution: Mac stays running (or use cloud deployment in future)

**iOS Full Development Workflow**:
```
On iPhone (Remote Work):
1. Siri: "Add task to Todoist: Review PR #123"
   ↓
2. Todoist app saves task
   ↓
3. Todoist cloud syncs
   ↓
4. Your Mac orchestrator detects new task (next poll: 3 min)
   ↓
5. Orchestrator creates page in Notion
   ↓
6. Notion cloud syncs
   ↓
7. Notion iOS app shows new page
   ↓
8. Notion AI (on iOS): "Analyze PR #123 codebase" (via File MCP → Mac files)
   ↓
9. GitHub iOS app: Review PR, use Copilot Chat for code suggestions
   ↓
10. Working Copy app: SSH to Mac, run tests, execute git commands
    ↓
11. Raycast iOS: Quick search across Notion/Todoist, trigger scripts
    ↓
12. GitHub iOS app: Create new repo (Copilot assists with README/structure)
```

**Key Insight**:
- ✅ **Full development workflow possible on iOS!**
- ✅ **GitHub Copilot**: Available via GitHub iOS app
- ✅ **Terminal access**: Via Working Copy (SSH to Mac)
- ✅ **File access**: Notion AI via File MCP server on Mac
- ✅ **Repository management**: Create repos, review code on GitHub app
- ✅ **Orchestrator**: Runs on Mac, accessible via Tailscale VPN---

### Remote Work Strategy

**Scenario**: You're away from Mac, only have iPhone

**What You Can Do on iOS**:
1. ✅ **Capture tasks**: Siri → Todoist (instant)
2. ✅ **Review tasks**: Todoist app (full access)
3. ✅ **Read/edit documents**: Notion app (full access)
4. ✅ **Use Notion AI**: Analyze code, write specs (via File MCP → Mac files)
5. ✅ **Create repositories**: GitHub app with Copilot assistance
6. ✅ **Review code**: GitHub app with Copilot Chat suggestions
7. ✅ **Execute commands**: Working Copy SSH to Mac (tmux sessions)
8. ✅ **Edit code**: Working Copy editor (syntax highlighting, Git operations)
9. ✅ **Quick capture**: Raycast iOS app (same as Mac)
10. ✅ **Access orchestrator**: Tailscale VPN → Mac API (port 3000)

**What Syncs Automatically**:
- ✅ Todoist: Instant cloud sync (native app)
- ✅ Notion: Instant cloud sync (native app)
- ✅ Orchestrator: Polls every 3-5 min (on your Mac at home)

**Example Remote Workflow**:
```
11:00 AM (on iPhone)
└─► Siri: "Add Todoist task: Fix webhook timeout bug"

11:03 AM (your Mac at home)
└─► Orchestrator detects new Todoist task
    └─► Creates Notion page in "To Do" database
        └─► Properties: Status=To Do, Priority=High

11:03 AM (on iPhone)
└─► Notion app refreshes, shows new page
    └─► You open page, use Notion AI: "Research webhook timeout best practices"
        └─► Notion AI writes research notes
            └─► You review, add thoughts

6:00 PM (back at Mac)
└─► VS Code Copilot sees Notion page (via custom MCP)
    └─► You ask: "Implement the webhook timeout fix from my notes"
        └─► Copilot reads Notion context, writes code
```

**Critical iOS Enhancements** (Recommended Setup):

1. **Tailscale VPN** ✅ **ESSENTIAL**
   - Secure tunnel to Mac from anywhere
   - Access orchestrator API (http://mac-hostname.tailnet:3000)
   - SSH to Mac: `ssh user@mac-hostname.tailnet`
   - No port forwarding, no firewall issues

2. **File MCP Server** ✅ **GAME-CHANGER**
   - Install on Mac: `npm install -g @modelcontextprotocol/server-filesystem`
   - Configure Notion AI to access Mac files
   - Notion AI can read/analyze your codebase remotely
   - Security: Scope to specific directories (e.g., `~/dev/`)

3. **Working Copy Pro** ✅ **PROFESSIONAL TOOL**
   - Full Git client (clone, commit, push, merge)
   - SSH terminal with tmux support
   - Code editor with syntax highlighting
   - AI integration (analyze code, suggest fixes)
   - Execute commands on Mac via SSH

4. **GitHub iOS App** ✅ **COPILOT AVAILABLE**
   - GitHub Copilot Chat built-in
   - Create repos with Copilot assistance
   - Review PRs with AI suggestions
   - Manage issues, projects, actions

5. **Raycast iOS** ✅ **ALREADY USING**
   - Quick capture (same scripts as Mac)
   - Search Notion/Todoist
   - Trigger shortcuts
   - Sync with Mac Raycast

6. **iOS Shortcuts** ✅ **AUTOMATION**
   - SSH commands: `ssh user@mac "cd ~/dev && git pull"`
   - Webhook triggers: `curl http://mac:3000/webhooks/trigger-sync`
   - Multi-step workflows: Capture → Process → Execute

---

## Documentation Links by Category

### Getting Started
- **Developer Home**: https://developers.notion.com
- **Getting Started Guide**: https://developers.notion.com/docs/getting-started
- **API Reference Home**: https://developers.notion.com/reference/intro
- **Examples**: https://developers.notion.com/page/examples

### Authentication & Tokens
- **Best Practices (API Keys)**: https://developers.notion.com/docs/best-practices-for-handling-api-keys
- **Authentication Overview**: https://developers.notion.com/reference/authentication
- **Create Token**: https://developers.notion.com/reference/create-a-token
- **Introspect Token**: https://developers.notion.com/reference/introspect-token
- **Revoke Token**: https://developers.notion.com/reference/revoke-token
- **Refresh Token**: https://developers.notion.com/reference/refresh-a-token

### API Capabilities & Limits
- **Capabilities**: https://developers.notion.com/reference/capabilities
- **Request Limits**: https://developers.notion.com/reference/request-limits (180 req/min, 3 req/sec)
- **Status Codes**: https://developers.notion.com/reference/status-codes

### Versioning (Notion 3.0)
- **Versioning Guide**: https://developers.notion.com/reference/versioning
- **Changes by Version**: https://developers.notion.com/reference/changes-by-version
- **Changelog**: https://developers.notion.com/page/changelog

### Webhooks
- **Webhooks Overview**: https://developers.notion.com/reference/webhooks
- **Events & Delivery**: https://developers.notion.com/reference/webhooks-events-delivery

### Data Sources API (New in 2025-09-03) ⭐
- **Create Data Source**: https://developers.notion.com/reference/create-a-data-source
- **Update Data Source**: https://developers.notion.com/reference/update-a-data-source
- **Update Properties**: https://developers.notion.com/reference/update-data-source-properties
- **Retrieve Data Source**: https://developers.notion.com/reference/retrieve-a-data-source
- **Query Data Source**: https://developers.notion.com/reference/query-a-data-source
- **Filter Entries**: https://developers.notion.com/reference/filter-data-source-entries
- **Sort Entries**: https://developers.notion.com/reference/sort-data-source-entries
- **List Templates**: https://developers.notion.com/reference/list-data-source-templates

### Databases API (Legacy, still supported)
- **Create Database**: https://developers.notion.com/reference/database-create
- **Update Database**: https://developers.notion.com/reference/database-update
- **Retrieve Database**: https://developers.notion.com/reference/database-retrieve

---

## Notion 3.0 Key Changes

### What's New in API Version 2025-09-03

**Released**: September 2025

**Major Change**: Database → Data Sources → Pages hierarchy

#### Before (2022-06-28):
```
Database (abc123)
├── Page 1
├── Page 2
└── Page 3
```

#### After (2025-09-03):
```
Database (abc123)
├── Data Source 1 (xyz789)
│   ├── Page 1
│   └── Page 2
└── Data Source 2 (def456)
    └── Page 3
```

**Why It Matters**:
- ✅ Multiple data sources per database (e.g., different views, filters)
- ✅ Better organization for large databases
- ✅ Template support per data source
- ⚠️ Breaking change: Must use `data_source_id` instead of `database_id`

---

### Migration Required for Your Orchestrator

**Current Code** (works with 2022-06-28):
```typescript
// orchestrator/src/sync/notion.ts
const response = await notion.databases.query({
  database_id: 'abc123'
});
```

**New Code** (required for 2025-09-03):
```typescript
// 1. Discover data sources
const database = await notion.databases.retrieve({
  database_id: 'abc123'
});

const dataSourceId = database.data_sources[0].id; // xyz789

// 2. Query data source
const response = await notion.dataSources.query({
  data_source_id: dataSourceId
});
```

**See**: `docs/NOTION-INTEGRATION.md` for complete migration guide

---

### New Token Management APIs

**Introspect Token** (check validity):
```bash
curl -X POST https://api.notion.com/v1/auth/introspect \
  -H "Authorization: Bearer ntn_***" \
  -H "Notion-Version: 2025-09-03"
```

**Response**:
```json
{
  "type": "integration",
  "workspace_id": "workspace-uuid",
  "workspace_name": "Your Workspace",
  "capabilities": ["read_content", "update_content", "insert_content"]
}
```

**Revoke Token** (programmatically):
```bash
curl -X POST https://api.notion.com/v1/auth/revoke \
  -H "Authorization: Bearer ntn_***" \
  -H "Notion-Version: 2025-09-03"
```

---

### Webhooks Improvements

**New in 2025-09-03**:
- ✅ Version-aware event delivery
- ✅ Data source events: `data_source.content_updated`
- ✅ Retry mechanism improvements
- ✅ Webhook signature verification

**Setup**:
```bash
curl -X POST https://api.notion.com/v1/webhooks \
  -H "Authorization: Bearer ntn_***" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-orchestrator.com/webhooks/notion",
    "event_types": ["data_source.content_updated", "page.created", "page.updated"]
  }'
```

**See**: `docs/NOTION-INTEGRATION.md` Webhook section

---

## Next Steps

### Immediate Actions

1. ✅ **Your integration type is correct**: Internal Integration (private)
2. ✅ **Your architecture is sound**: REST API for orchestrator, optional MCP for AI
3. ⚠️ **Share databases**: Final blocker (see `docs/NOTION-INTEGRATION.md` Step 3)
4. ⏳ **Test sync**: Verify Todoist ↔ Notion working
5. ⏳ **Upgrade to 2025-09-03**: After basic sync validated

### Optional Enhancements

6. ⚠️ **Setup custom MCP**: For VS Code Copilot integration (see `docs/MCP-SERVER-SETUP.md`)
7. ⚠️ **Setup webhooks**: Real-time sync instead of polling (requires public URL)
8. ⚠️ **iOS Shortcuts**: Custom workflows for iPhone capture

### Reference Documents

- **Setup Guide**: `docs/NOTION-INTEGRATION.md` (integration setup, API migration)
- **MCP Setup**: `docs/MCP-SERVER-SETUP.md` (AI tools integration)
- **Architecture**: `ARCHITECTURE.md` (system design)
- **This Reference**: `docs/NOTION-DEVELOPER-REFERENCE.md` (complete API reference)

---

**Last Updated**: October 17, 2025
**Notion API Version**: 2025-09-03
**Your Integration**: Internal Integration (correct for personal use)
