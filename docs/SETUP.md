# Setup Guide

Complete installation and configuration guide for MCP Orchestrator.

## Prerequisites

- **macOS** (Apple Silicon or Intel)
- **Node.js 20+** (LTS): `brew install node@20`
- **Docker Desktop**: Download from [docker.com](https://www.docker.com/products/docker-desktop)
- **1Password CLI**: `brew install --cask 1password/tap/1password-cli`
- **Todoist Premium**: Required for Google Calendar sync
- **Notion Workspace**: With API integration access
- **GitHub Copilot Pro+**: For agent delegation

## Step 1: Clone Repository

```bash
git clone https://github.com/Kingy2709/mcp-orchestrator-one-truth-repository.git
cd mcp-orchestrator-one-truth-repository
```

## Step 2: Run Setup Script

```bash
./scripts/setup.sh
```

This will:
- Install all npm dependencies
- Create `.env` from template
- Set up git hooks
- Build TypeScript projects

## Step 3: Configure 1Password Service Account

### Create Service Account

1. Visit [1Password Service Accounts](https://developer.1password.com/docs/service-accounts)
2. Create new service account: `mcp-orchestrator`
3. Grant read access to "Raycast" vault (or create dedicated vault)
4. Copy service account token (starts with `ops_`)

### Store Token

Add to `.env`:

```bash
OP_SERVICE_ACCOUNT_TOKEN=ops_ey...
```

## Step 4: Configure API Keys

### Notion API

1. Visit [Notion Integrations](https://www.notion.so/my-integrations)
2. Create new integration: "MCP Orchestrator"
3. Copy Internal Integration Token
4. Share target workspace/databases with integration

Add to `.env`:

```bash
NOTION_API_KEY=secret_...
NOTION_TASKS_DATABASE_ID=...
NOTION_RESEARCH_DATABASE_ID=...
```

### Todoist API

1. Visit [Todoist Integrations](https://todoist.com/prefs/integrations)
2. Scroll to "API token" section
3. Copy token

Add to `.env`:

```bash
TODOIST_API_TOKEN=...
```

### GitHub PAT

1. Visit [GitHub Tokens](https://github.com/settings/tokens)
2. Create new token (classic) with scopes:
   - `repo` (full)
   - `workflow`
   - `read:org`
3. Copy token

Add to `.env`:

```bash
GITHUB_PAT=ghp_...
```

## Step 5: Configure Webhooks

### Todoist Webhook

1. Start orchestrator: `docker-compose up -d`
2. Get Tailscale IP: `tailscale ip`
3. Visit [Todoist App Management](https://developer.todoist.com/appconsole.html)
4. Add webhook URL: `https://<tailscale-ip>:3000/webhooks/todoist`
5. Generate and save webhook secret to `.env`

### GitHub Webhook (Optional)

1. Visit repository Settings → Webhooks
2. Add webhook URL: `https://<tailscale-ip>:3000/webhooks/github`
3. Select events: Push, Pull Request, Issues
4. Generate secret and save to `.env`

## Step 6: Start Orchestrator

### Using Docker (Recommended)

```bash
docker-compose up -d
```

View logs:

```bash
docker-compose logs -f orchestrator
```

### Using PM2 (Alternative)

```bash
cd orchestrator
npm run build
pm2 start dist/index.js --name mcp-orchestrator
pm2 save
pm2 startup
```

## Step 7: Verify Setup

```bash
./scripts/health-check.sh
```

Should output:

```
✅ Orchestrator is running
✅ Docker containers running
✅ Configuration valid
```

## Step 8: Install Raycast Extensions

```bash
mkdir -p ~/.config/raycast/scripts
cp raycast-extensions/*.sh ~/.config/raycast/scripts/
chmod +x ~/.config/raycast/scripts/*.sh
```

Configure in Raycast:
1. Open Raycast preferences
2. Extensions → Script Commands
3. Add directory: `~/.config/raycast/scripts`

## Step 9: Test Workflow

1. **Quick Capture**: Say to Siri: "Add to Todoist: Test task"
2. **Check Logs**: `docker-compose logs -f orchestrator`
3. **Verify Notion**: Task should appear in Notion database
4. **Verify Calendar**: Task should sync to Google Calendar (if priority ≥ 2)

## Troubleshooting

### Orchestrator Won't Start

- Check logs: `docker-compose logs orchestrator`
- Verify `.env` configuration: `cat .env`
- Test 1Password: `op whoami`

### Webhooks Not Working

- Verify Tailscale is running: `tailscale status`
- Check firewall allows incoming connections
- Test webhook endpoint: `curl http://localhost:3000/health`

### Sync Not Working

- Check API keys are valid
- Verify database IDs are correct
- Review orchestrator logs for errors

## Next Steps

- Read [ADHD-OPTIMIZATIONS.md](ADHD-OPTIMIZATIONS.md) for workflow patterns
- Configure agents in [agents/](../agents/)
- Customize auto-tagging rules
- Set up Notion database templates

## Support

For issues, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or open a GitHub issue.
