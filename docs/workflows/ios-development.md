# iOS Development Workflow Guide

Complete guide for full-featured remote development from iPhone using Notion AI, GitHub Copilot, Working Copy, and your Mac orchestrator.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Required Apps](#required-apps)
- [Setup Instructions](#setup-instructions)
- [File MCP Server Setup](#file-mcp-server-setup)
- [Development Workflows](#development-workflows)
- [Advanced Scenarios](#advanced-scenarios)

---

## Overview

**Goal**: Enable full software development workflow from iPhone, leveraging:
- **Notion AI** with access to Mac files via File MCP
- **GitHub Copilot** via GitHub iOS app
- **Working Copy** for Git operations and SSH terminal
- **Raycast iOS** for quick capture and search
- **Orchestrator** running on Mac (accessible via Tailscale)

**What You Can Do**:
- ✅ Create GitHub repositories with Copilot assistance
- ✅ Review and edit code with syntax highlighting
- ✅ Execute commands on Mac via SSH
- ✅ Access Notion AI with full Mac codebase context
- ✅ Capture tasks and sync across tools
- ✅ Search everything (Notion + Todoist) from iPhone

---

## Architecture

```
iPhone (Remote Development)
│
├─► Notion AI
│   ├── Analyzes Mac files via File MCP server
│   ├── Generates technical specs, documentation
│   └── Answers questions about codebase
│
├─► GitHub Copilot (GitHub iOS app)
│   ├── Code suggestions in PR reviews
│   ├── Create repos with AI-generated structure
│   └── Chat about code, debugging, architecture
│
├─► Working Copy Pro
│   ├── Git operations (clone, commit, push, merge)
│   ├── SSH terminal to Mac (tmux sessions)
│   ├── Code editor with AI integration
│   └── Execute commands remotely
│
├─► Raycast iOS
│   ├── Quick capture to Todoist/Notion
│   ├── Search across all tools
│   └── Trigger Mac scripts via API
│
└─► Tailscale VPN
    ├── Secure tunnel to Mac
    ├── Access orchestrator (port 3000)
    └── SSH without port forwarding

                    ↓ Tailscale VPN ↓

Mac (Home Server)
│
├─► Orchestrator (Port 3000)
│   ├── Todoist ↔ Notion sync
│   ├── Webhook endpoints
│   └── API for remote triggers
│
├─► File MCP Server (Port 3001)
│   ├── Exposes ~/dev/ directory
│   ├── Read-only access for Notion AI
│   └── Security scoped to allowed paths
│
└─► SSH Server (Port 22)
    ├── Accepts connections from Working Copy
    ├── Tmux sessions for persistent terminals
    └── Git operations, command execution
```

---

## Required Apps

### Essential (Free)

1. **Notion iOS** (Free)
   - Download: [App Store](https://apps.apple.com/app/notion/id1232780281)
   - Purpose: Document management, Notion AI with File MCP access
   - Setup: Sign in to your workspace

2. **Todoist iOS** (Free)
   - Download: [App Store](https://apps.apple.com/app/todoist/id572688855)
   - Purpose: Task management, Siri quick capture
   - Setup: Sign in to your account

3. **GitHub iOS** (Free)
   - Download: [App Store](https://apps.apple.com/app/github/id1477376905)
   - Purpose: GitHub Copilot Chat, create repos, review code
   - Setup: Sign in, enable Copilot in settings

4. **Raycast iOS** (Free)
   - Download: [App Store](https://apps.apple.com/app/raycast/id1632539667)
   - Purpose: Quick capture, search, script triggers
   - Setup: Sign in (syncs with Mac)

5. **Tailscale iOS** (Free)
   - Download: [App Store](https://apps.apple.com/app/tailscale/id1470499037)
   - Purpose: VPN tunnel to Mac, SSH access
   - Setup: Sign in, connect to tailnet

### Recommended (Paid)

6. **Working Copy Pro** ($19.99 one-time)
   - Download: [App Store](https://apps.apple.com/app/working-copy/id896694807)
   - Purpose: Git client, SSH terminal, code editor
   - Features: Unlimited repos, SSH keys, external editing
   - Setup: Purchase Pro unlock, configure SSH keys

### Optional

7. **Shortcuts** (Built-in iOS)
   - Purpose: Custom automation workflows
   - Use cases: SSH commands, webhook triggers, multi-step captures

8. **Prompt 3** ($14.99 - alternative to Working Copy SSH)
   - Download: [App Store](https://apps.apple.com/app/prompt-3/id1594420480)
   - Purpose: Dedicated SSH/Mosh client with tmux support
   - Use if: You prefer separate terminal app

---

## Setup Instructions

### Step 1: Tailscale VPN Setup

**On Mac**:
```bash
# Install Tailscale
brew install tailscale

# Start Tailscale
sudo tailscale up

# Get your machine name
tailscale status
# Note: Your Mac will be "macbook-pro.tailnet-name.ts.net" or similar
```

**On iPhone**:
1. Install Tailscale from App Store
2. Sign in with same account as Mac
3. Toggle VPN on
4. Verify connection: Settings → VPN (should show "Connected")

**Test connection**:
```bash
# On iPhone (via Working Copy terminal or Shortcuts):
ping macbook-pro.tailnet-name.ts.net
# Should receive responses
```

---

### Step 2: SSH Key Setup (For Working Copy)

**On Mac**:
```bash
# Create SSH key for iPhone (if not exists)
ssh-keygen -t ed25519 -C "iphone-working-copy"
# Save as: ~/.ssh/iphone_working_copy

# Add public key to authorized_keys
cat ~/.ssh/iphone_working_copy.pub >> ~/.ssh/authorized_keys

# Copy PRIVATE key to clipboard (for Working Copy)
cat ~/.ssh/iphone_working_copy | pbcopy
```

**On iPhone (Working Copy)**:
1. Open Working Copy
2. Settings → SSH Keys → Add Key
3. Name: "Mac SSH"
4. Paste private key from Mac clipboard
5. Save

**Test SSH**:
1. Working Copy → Remote → Add Server
2. Protocol: SSH
3. Host: `macbook-pro.tailnet-name.ts.net`
4. Port: `22`
5. Username: Your Mac username
6. Authentication: SSH Key → Select "Mac SSH"
7. Test Connection → Should succeed ✅

---

### Step 3: Orchestrator API Access

**On Mac** (verify orchestrator running):
```bash
# Check orchestrator status
pm2 status

# If not running:
cd ~/dev/repo/mcp-orchestrator-one-truth-repository/orchestrator
pm2 start npm --name "mcp-orchestrator" -- start

# Test API locally
curl http://localhost:3000/health
# Should return: {"status":"ok","version":"0.1.0"}
```

**On iPhone** (via Tailscale):
1. Open Safari
2. Navigate to: `http://macbook-pro.tailnet-name.ts.net:3000/health`
3. Should see: `{"status":"ok"}`

**Create Shortcut** (for easy access):
1. Shortcuts app → New Shortcut
2. Add "Get Contents of URL"
3. URL: `http://macbook-pro.tailnet-name.ts.net:3000/webhooks/sync-now`
4. Method: POST
5. Name: "Trigger Sync"
6. Add to Home Screen

---

### Step 4: GitHub Copilot Setup

**On iPhone (GitHub app)**:
1. Open GitHub app
2. Profile → Settings → Copilot
3. Enable "Copilot Chat"
4. Grant permissions

**Test Copilot**:
1. Open any repository in GitHub app
2. Tap chat icon (bottom bar)
3. Ask: "Explain this repository structure"
4. Should receive AI response ✅

**Create Repository with Copilot**:
1. GitHub app → Repositories → New
2. Name: "test-repo"
3. Open Copilot Chat
4. Ask: "Generate a Python project structure with FastAPI"
5. Copilot suggests files and structure
6. Create repository

---

### Step 5: Raycast iOS Setup

**On iPhone**:
1. Install Raycast from App Store
2. Sign in (same account as Mac)
3. Settings → Sync → Enable

**Verify sync**:
- Your Mac Raycast scripts should appear
- Search functionality syncs
- Shortcuts available

**Quick Capture**:
1. Open Raycast
2. Type: "Quick Task"
3. Enter task description
4. Raycast → Todoist → Orchestrator → Notion (synced)

---

## File MCP Server Setup

### What is File MCP?

The **File MCP Server** exposes your Mac's filesystem to AI tools (like Notion AI) via the Model Context Protocol. This allows Notion AI on your iPhone to:
- Read code files from your Mac
- Analyze entire codebases
- Answer questions about your projects
- Generate documentation based on actual code

**Security**: Read-only access, scoped to specific directories only.

---

### Installation (On Mac)

```bash
# Install File MCP server globally
npm install -g @modelcontextprotocol/server-filesystem

# Verify installation
which mcp-server-filesystem
# Should output: /usr/local/bin/mcp-server-filesystem
```

---

### Configuration

**Create config file**:
```bash
mkdir -p ~/Library/Application\ Support/MCP
nano ~/Library/Application\ Support/MCP/file-server-config.json
```

**Config contents**:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": [
        "/Users/YOUR_USERNAME/dev",
        "/Users/YOUR_USERNAME/Documents/Projects"
      ],
      "env": {
        "MCP_ALLOWED_PATHS": "/Users/YOUR_USERNAME/dev:/Users/YOUR_USERNAME/Documents/Projects"
      },
      "transport": "http",
      "port": 3001,
      "auth": {
        "type": "token",
        "token": "your-secure-random-token-here"
      }
    }
  }
}
```

**Generate secure token**:
```bash
# Generate random token
openssl rand -hex 32
# Copy output, add to config as "token" value
```

**Important**: Replace `YOUR_USERNAME` with your actual Mac username.

---

### Start File MCP Server

**Manual start** (for testing):
```bash
mcp-server-filesystem \
  --port 3001 \
  --auth-token "your-token-here" \
  /Users/YOUR_USERNAME/dev
```

**PM2 start** (persistent):
```bash
# Create PM2 ecosystem file
cat > ~/dev/file-mcp-ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'file-mcp-server',
    script: 'mcp-server-filesystem',
    args: [
      '--port', '3001',
      '--auth-token', 'your-token-here',
      '/Users/YOUR_USERNAME/dev'
    ],
    cwd: '/Users/YOUR_USERNAME',
    restart_delay: 3000,
    autorestart: true,
    watch: false
  }]
};
EOF

# Start with PM2
pm2 start ~/dev/file-mcp-ecosystem.config.js

# Save PM2 config
pm2 save

# Setup PM2 startup
pm2 startup
```

**Verify running**:
```bash
pm2 status
# Should show: file-mcp-server (online)

# Test locally
curl -H "Authorization: Bearer your-token-here" \
     http://localhost:3001/v1/files
# Should return: JSON list of files
```

---

### Connect Notion AI to File MCP

**Important**: Notion AI doesn't natively support custom MCP servers yet (as of Oct 2025). You have two options:

#### Option A: Use Claude Desktop as Intermediary (Recommended)

1. **On Mac** - Configure Claude Desktop:
```json
// File: ~/Library/Application Support/Claude/claude_desktop_config.json
{
  "mcpServers": {
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": ["/Users/YOUR_USERNAME/dev"],
      "env": {
        "MCP_ALLOWED_PATHS": "/Users/YOUR_USERNAME/dev"
      }
    },
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

2. **Workflow**:
   - iPhone: Write question in Notion page
   - Tag: `@claude-review` (custom automation)
   - Mac: Claude Desktop monitors Notion via webhook
   - Claude: Reads File MCP, answers question, updates Notion page

#### Option B: Direct API Integration (Advanced)

Create custom bridge service:

```typescript
// ~/dev/notion-file-bridge/index.ts
import express from 'express';
import { Client } from '@notionhq/client';
import axios from 'axios';

const app = express();
const notion = new Client({ auth: process.env.NOTION_API_KEY });

// Webhook: Notion page updated with @analyze tag
app.post('/webhooks/notion', async (req, res) => {
  const { page_id, tag } = req.body;

  if (tag === '@analyze') {
    // 1. Get question from Notion page
    const page = await notion.pages.retrieve({ page_id });
    const question = extractQuestion(page);

    // 2. Query File MCP for relevant files
    const files = await axios.get('http://localhost:3001/v1/files', {
      headers: { 'Authorization': 'Bearer your-token' },
      params: { query: question }
    });

    // 3. Send to AI (OpenAI, Anthropic, etc.)
    const answer = await analyzeWithAI(question, files.data);

    // 4. Update Notion page with answer
    await notion.blocks.children.append({
      block_id: page_id,
      children: [{ paragraph: { rich_text: [{ text: { content: answer } }] } }]
    });
  }

  res.json({ status: 'ok' });
});

app.listen(3002);
```

**Deploy with PM2**:
```bash
cd ~/dev/notion-file-bridge
npm install
pm2 start index.ts --name notion-file-bridge
```

---

## Development Workflows

### Workflow 1: Create Repository from iPhone

**Scenario**: You have an idea for a new project while away from Mac.

**Steps**:
1. **Capture idea** (Siri → Todoist):
   - "Add task to Todoist: Create Python FastAPI project for task automation"

2. **Orchestrator syncs** (3 min):
   - Todoist task → Notion page in "To Do" database

3. **Plan with Notion AI** (iPhone):
   - Open Notion page on iPhone
   - Ask Notion AI: "Create project plan for FastAPI task automation app"
   - Notion AI generates: Requirements, architecture, file structure

4. **Create repo with GitHub Copilot** (iPhone):
   - Open GitHub app
   - Create new repository: "task-automation-api"
   - Open Copilot Chat
   - Paste Notion AI's project plan
   - Ask: "Generate Python project structure based on this plan"
   - Copilot creates: `main.py`, `requirements.txt`, `README.md`, `.gitignore`

5. **Clone and setup on Mac** (via Working Copy SSH):
   - Working Copy → Remote → Add → GitHub
   - Clone: `task-automation-api`
   - Terminal (SSH to Mac):
     ```bash
     cd ~/dev
     git clone git@github.com:username/task-automation-api.git
     cd task-automation-api
     python -m venv venv
     source venv/bin/activate
     pip install -r requirements.txt
     ```

6. **Initial commit** (Working Copy):
   - Edit `README.md` in Working Copy editor
   - Stage changes
   - Commit: "feat: initial FastAPI project structure"
   - Push to GitHub

7. **Update Notion** (automatic):
   - GitHub webhook → Orchestrator detects new repo
   - Orchestrator updates Notion page with repo link
   - Status: "To Do" → "In Progress"

---

### Workflow 2: Code Review with Copilot on iPhone

**Scenario**: PR review request while away from Mac.

**Steps**:
1. **Notification** (GitHub app):
   - "You've been requested to review PR #42"

2. **Open PR** (GitHub app):
   - Review → Files changed
   - View diff with syntax highlighting

3. **Ask Copilot** (GitHub app):
   - Copilot Chat: "Analyze this PR for security issues"
   - Copilot reviews code, suggests improvements
   - Ask: "Is the error handling robust?"
   - Copilot provides feedback

4. **Add review comments**:
   - Tap line number → Add comment
   - Use Copilot suggestions: "Consider using context manager for file operations"
   - Submit review

5. **Run tests remotely** (Working Copy SSH):
   ```bash
   ssh mac.tailnet "cd ~/dev/project && ./run-tests.sh"
   ```

6. **Approve or request changes**:
   - Based on Copilot analysis and test results
   - Submit review with detailed feedback

---

### Workflow 3: Debug Issue with Notion AI File Access

**Scenario**: Production bug reported, need to analyze codebase.

**Steps**:
1. **Create debugging page** (Notion iPhone):
   - New page: "Debug: API timeout on /users endpoint"
   - Add context: Error logs, reproduction steps

2. **Ask Notion AI** (with File MCP access):
   - "Analyze the /users endpoint in ~/dev/api-project/routes/users.py"
   - Notion AI (via File MCP) reads file from Mac
   - Response: "Found potential issue on line 42: Missing timeout parameter in database query"

3. **Review related files**:
   - Ask: "Show me all database queries in this project"
   - Notion AI scans ~/dev/api-project
   - Lists: 12 files with database queries

4. **Generate fix**:
   - Ask: "Suggest fix for database timeout issue"
   - Notion AI provides code snippet with timeout parameter

5. **Apply fix** (Working Copy):
   - SSH to Mac:
     ```bash
     cd ~/dev/api-project
     git checkout -b fix/database-timeout
     ```
   - Working Copy: Edit `routes/users.py`
   - Apply Notion AI's suggested fix
   - Commit: "fix: add timeout to database queries"

6. **Create PR** (GitHub app):
   - Push branch
   - Create PR with Notion AI's analysis as description
   - Request review

7. **Update Notion** (automatic):
   - Orchestrator detects new PR
   - Links PR to debugging page
   - Status: "Debugging" → "Pending Review"

---

### Workflow 4: Write Documentation with File Context

**Scenario**: Need to document new API endpoints.

**Steps**:
1. **Create docs page** (Notion iPhone):
   - New page: "API Documentation - User Management"

2. **Ask Notion AI** (with File MCP):
   - "Generate API documentation for all endpoints in ~/dev/api-project/routes/users.py"
   - Notion AI reads file, generates:
     - Endpoint descriptions
     - Request/response schemas
     - Example curl commands
     - Error codes

3. **Refine documentation**:
   - Ask: "Add authentication examples for each endpoint"
   - Notion AI updates with JWT examples

4. **Export to Markdown** (Notion):
   - Export page as Markdown
   - Copy to clipboard

5. **Add to repo** (Working Copy):
   - SSH to Mac:
     ```bash
     cd ~/dev/api-project/docs
     cat > api-users.md
     # Paste Markdown from Notion
     # Ctrl+D to save
     git add docs/api-users.md
     git commit -m "docs: add user management API documentation"
     git push
     ```

6. **Sync back to Notion**:
   - Orchestrator detects new commit
   - Updates Notion page with GitHub file link
   - Adds tag: "Published"

---

### Workflow 5: Execute Complex Tasks via SSH

**Scenario**: Need to run multi-step deployment or maintenance tasks.

**Steps**:
1. **Connect via Working Copy**:
   - Remote → Mac SSH
   - Start tmux session:
     ```bash
     tmux new -s deploy
     ```

2. **Run deployment**:
   ```bash
   cd ~/dev/production-app
   git pull origin main

   # Build
   npm run build

   # Run tests
   npm test

   # Deploy (example)
   ./deploy.sh production

   # Monitor logs
   tail -f logs/production.log
   ```

3. **Detach from tmux** (if needed):
   - Press: `Ctrl+B`, then `D`
   - Session keeps running on Mac

4. **Reattach later**:
   ```bash
   tmux attach -t deploy
   ```

5. **Create iOS Shortcut** (for common tasks):
   - Shortcuts app → New Shortcut
   - Add "Run Script Over SSH"
   - Host: `mac.tailnet`
   - Script: `cd ~/dev/project && git pull && npm run build`
   - Name: "Deploy Project"

---

## Advanced Scenarios

### Scenario A: Multi-Repository Analysis

**Use Case**: Analyze patterns across multiple projects.

**Setup Notion AI query**:
```
Analyze error handling patterns in these projects:
- ~/dev/api-project
- ~/dev/frontend-app
- ~/dev/background-jobs

Compare and suggest standardization approach.
```

**Notion AI** (via File MCP):
- Reads all three project directories
- Identifies error handling patterns
- Generates comparison report
- Suggests unified error handling library

---

### Scenario B: Automated Code Reviews in Notion

**Workflow**:
1. GitHub webhook → Orchestrator on PR created
2. Orchestrator creates Notion page with PR details
3. Notion AI (File MCP) analyzes changed files
4. Notion AI adds review comments to page
5. You review Notion analysis on iPhone
6. Approve/reject in GitHub app

**Implementation** (orchestrator webhook):
```typescript
// orchestrator/src/webhooks/github.ts
app.post('/webhooks/github/pr', async (req, res) => {
  const { pull_request } = req.body;

  // Create Notion page
  const page = await notion.pages.create({
    parent: { database_id: process.env.NOTION_CODE_REVIEWS_DB },
    properties: {
      'PR Title': { title: [{ text: { content: pull_request.title } }] },
      'Repository': { select: { name: pull_request.repo.name } },
      'Status': { select: { name: 'Pending Review' } }
    }
  });

  // Trigger Notion AI analysis (via File MCP)
  // ... implementation depends on Notion AI API access

  res.json({ status: 'ok' });
});
```

---

### Scenario C: Sync VS Code Extensions

**Use Case**: Keep VS Code extensions synced between Mac and iPhone (via Working Copy).

**On Mac**:
```bash
# Export VS Code extensions
code --list-extensions > ~/dev/.vscode-extensions

# Commit to repo
cd ~/dev
git add .vscode-extensions
git commit -m "chore: update VS Code extensions list"
git push
```

**On iPhone** (Working Copy):
1. Pull latest changes
2. View `.vscode-extensions` file
3. When back on Mac:
   ```bash
   # Install extensions from list
   cat ~/dev/.vscode-extensions | xargs -L 1 code --install-extension
   ```

---

### Scenario D: Remote Orchestrator Control

**Create Shortcuts** for common orchestrator commands:

**Shortcut: "Sync Now"**:
```
GET http://mac.tailnet:3000/webhooks/sync-now
Method: POST
Headers: Authorization: Bearer your-orchestrator-token
```

**Shortcut: "Health Check"**:
```
GET http://mac.tailnet:3000/health
Show Result
```

**Shortcut: "View Sync Status"**:
```
GET http://mac.tailnet:3000/api/sync/status
Format JSON
Show Result
```

**Shortcut: "Create Notion Page from Clipboard"**:
```
Get Clipboard
Set Variable: content
POST http://mac.tailnet:3000/api/notion/create-page
Body: {"title": "Quick Capture", "content": [content]}
```

---

## Security Best Practices

### SSH Keys
- ✅ Use separate SSH key for iPhone (not your main key)
- ✅ Password-protect the key
- ✅ Revoke key if iPhone lost/stolen

### File MCP Server
- ✅ Use strong random token for authentication
- ✅ Scope to specific directories only (no `~/` root access)
- ✅ Read-only access (no write operations)
- ✅ Monitor access logs

### Tailscale
- ✅ Enable MFA on Tailscale account
- ✅ Use ACLs to restrict access if needed
- ✅ Regularly review connected devices

### Orchestrator API
- ✅ Require authentication tokens
- ✅ Rate limiting (prevent abuse)
- ✅ HTTPS only (even over Tailscale)

### 1Password
- ✅ Store all tokens/keys in 1Password
- ✅ Use 1Password on iPhone for quick access
- ✅ Enable Face ID for 1Password

---

## Troubleshooting

### Can't Connect to Mac via Tailscale

**Check**:
```bash
# On Mac
tailscale status
# Should show: "Connected"

# On iPhone
# Settings → VPN → Should show "Connected"
```

**Fix**:
- Restart Tailscale on both devices
- Check internet connection
- Verify same Tailscale account

---

### Working Copy SSH Timeout

**Check**:
```bash
# On Mac
sudo systemsetup -getremotelogin
# Should show: "Remote Login: On"
```

**Fix**:
```bash
# Enable SSH
sudo systemsetup -setremotelogin on

# Check SSH running
sudo launchctl list | grep ssh
# Should show: com.openssh.sshd
```

---

### File MCP Server Not Responding

**Check**:
```bash
# On Mac
pm2 status
# Should show: file-mcp-server (online)

# Check logs
pm2 logs file-mcp-server
```

**Fix**:
```bash
# Restart
pm2 restart file-mcp-server

# Or start manually for debugging
mcp-server-filesystem --port 3001 --auth-token "token" ~/dev
```

---

### Notion AI Not Accessing Files

**Issue**: Notion AI doesn't natively support custom MCP servers yet.

**Workarounds**:
1. Use Claude Desktop as intermediary (recommended)
2. Build custom bridge service (see Setup → Option B)
3. Wait for Notion to add custom MCP support (roadmap unclear)

**Current best approach**:
- Use GitHub Copilot for code analysis (works on iPhone)
- Use Working Copy's AI features (built-in)
- Use Notion AI for documentation/planning (without file access)

---

## Next Steps

1. ✅ Install required apps on iPhone
2. ✅ Setup Tailscale VPN (Mac + iPhone)
3. ✅ Configure Working Copy SSH access
4. ✅ Install File MCP server on Mac
5. ✅ Test GitHub Copilot in GitHub app
6. ✅ Create iOS Shortcuts for common tasks
7. ✅ Practice workflows (start with Workflow 1)

---

**Last Updated**: October 17, 2025
**Compatible with**: iOS 17+, macOS 14+
**Required**: Tailscale, Working Copy Pro ($19.99), GitHub Copilot subscription
