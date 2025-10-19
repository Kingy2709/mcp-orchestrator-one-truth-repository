# 1Password Configuration

> Comprehensive guide for 1Password integration with n8n workflow and GitHub Copilot MCP servers.

## Table of Contents

1. [Overview](#overview)
2. [Service Account Setup](#service-account-setup)
3. [Storing Credentials](#storing-credentials)
4. [n8n Integration](#n8n-integration)
5. [GitHub Copilot MCP Integration](#github-copilot-mcp-integration)
6. [GitHub Actions (CI/CD)](#github-actions-cicd)
7. [Best Practices](#best-practices)

---

## Overview

**Strategy:**

- **Service Account**: For n8n credential injection and CI/CD pipelines
- **Vault**: "Automation" (dedicated vault for all automation secrets)
- **Reference Format**: `op://Automation/ITEM_NAME/field_name`

**Why 1Password?**

✅ Centralized secret management  
✅ Audit trail (every access logged)  
✅ No secrets in code or environment files  
✅ Service Accounts for automation (no human login required)  
✅ SDK integration with n8n, GitHub Actions, Copilot MCP

---

## Service Account Setup

### 1. Create Service Account

1. Go to [1Password Developer Tools](https://my.1password.com/developer-tools/infrastructure-secrets/service-accounts)
2. Click **Create Service Account**
3. Name: `1password.op-service-account-token.mcp-orchestrator`
4. Description: "n8n workflow automation + GitHub Copilot MCP + CI/CD"
5. Click **Create**
6. **Copy the token immediately** (shows only once): `ops_ey...`

### 2. Grant Vault Access

1. In Service Account settings, click **Grant Access to Vaults**
2. Select **Automation** vault
3. Permission: **Read**
4. Click **Save**

### 3. Store Service Account Token

```bash
# Store in 1Password (bootstrap secret)
op item create --category="API Credential" \
  --vault="Automation" \
  --title="OP_SERVICE_ACCOUNT_TOKEN" \
  --tags="mcp-orchestrator,1password,service-account" \
  credential="ops_ey..."

# Or manually via 1Password app:
# 1. Open 1Password
# 2. Select "Automation" vault
# 3. Click "+" → "API Credential"
# 4. Title: OP_SERVICE_ACCOUNT_TOKEN
# 5. Credential field: paste token
# 6. Tags: mcp-orchestrator, 1password, service-account
# 7. Save
```

---

## Storing Credentials

### Naming Convention

**Format**: `{SERVICE}_{TYPE}_{SCOPE}` (uppercase matches environment variable convention)

| Credential | Item Name | Category |
|------------|-----------|----------|
| Notion API Key | `NOTION_API_KEY` | API Credential |
| Todoist API Token | `TODOIST_API_TOKEN` | API Credential |
| GitHub Personal Access Token | `GITHUB_PERSONAL_ACCESS_TOKEN` | API Credential |
| OpenAI API Key | `OPENAI_API_KEY` | API Credential |
| Claude API Key | `CLAUDE_API_KEY` | API Credential |

### Standard Structure

```json
{
  "title": "TODOIST_API_TOKEN",
  "category": "API_CREDENTIAL",
  "tags": ["mcp-orchestrator", "todoist", "api-token"],
  "fields": [
    {
      "id": "credential",
      "type": "CONCEALED",
      "label": "credential",
      "value": "YOUR_API_TOKEN_HERE"
    },
    {
      "id": "notesPlain",
      "type": "STRING",
      "label": "notesPlain",
      "value": "Todoist API token for bidirectional sync with Notion via n8n"
    }
  ]
}
```

### Create Credentials via CLI

```bash
# Notion API Key
op item create --category="API Credential" \
  --vault="Automation" \
  --title="NOTION_API_KEY" \
  --tags="mcp-orchestrator,notion,api-key" \
  credential="secret_..."

# Todoist API Token
op item create --category="API Credential" \
  --vault="Automation" \
  --title="TODOIST_API_TOKEN" \
  --tags="mcp-orchestrator,todoist,api-token" \
  credential="..."

# GitHub PAT (for Copilot Agent triggers)
op item create --category="API Credential" \
  --vault="Automation" \
  --title="GITHUB_PERSONAL_ACCESS_TOKEN" \
  --tags="mcp-orchestrator,github,pat" \
  credential="ghp_..."

# OpenAI API Key (for n8n AI auto-tagging)
op item create --category="API Credential" \
  --vault="Automation" \
  --title="OPENAI_API_KEY" \
  --tags="mcp-orchestrator,openai,api-key" \
  credential="sk-..."
```

---

## n8n Integration

### n8n Cloud (Recommended)

**1Password Service Account not directly supported** in n8n Cloud. Use credential storage instead:

1. **n8n Credentials → Add Credential**
2. Select credential type: "Notion API", "Todoist API", "OpenAI API"
3. Paste API key/token from 1Password manually
4. Name: matches 1Password item (e.g., "NOTION_API_KEY")

**Rotation workflow:**
- Update credential in 1Password
- Manually update in n8n Credentials panel
- Re-test affected workflows

### n8n Self-Hosted

**Use 1Password CLI injection** for environment variables:

```bash
# .env file
OP_SERVICE_ACCOUNT_TOKEN=ops_ey...
NOTION_API_KEY=op://Automation/NOTION_API_KEY/credential
TODOIST_API_TOKEN=op://Automation/TODOIST_API_TOKEN/credential
OPENAI_API_KEY=op://Automation/OPENAI_API_KEY/credential

# docker-compose.yml
services:
  n8n:
    image: n8nio/n8n:latest
    env_file: .env
    command: /bin/sh -c "op run --env-file=.env -- n8n start"
```

**Benefit**: Secrets never stored in Docker environment, always fetched at runtime.

---

## GitHub Copilot MCP Integration

### Install Official Notion MCP Server

```bash
# Global installation
npm install -g @makenotion/notion-mcp-server
```

### Configure Copilot with 1Password Injection

**`~/.copilot/config.json`:**

```json
{
  "mcpServers": {
    "notion": {
      "command": "notion-mcp-server",
      "env": {
        "NOTION_API_KEY": "op://Automation/NOTION_API_KEY/credential"
      }
    }
  }
}
```

### Launch Copilot with 1Password Injection

```bash
# Set Service Account token
export OP_SERVICE_ACCOUNT_TOKEN="ops_ey..."

# Launch VS Code with op run
op run -- code .

# Now Copilot MCP servers can access 1Password credentials
```

**In Copilot Chat:**

```
User: "Search Notion for OAuth research tasks"
Copilot: [Uses Notion MCP with 1Password-injected API key] Found 3 pages...
```

---

## GitHub Actions (CI/CD)

### 1. Add Service Account Token to GitHub Secrets

1. Go to repository settings: **Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Name: `OP_SERVICE_ACCOUNT_TOKEN`
4. Value: Your Service Account token from 1Password
5. Click **Add secret**

### 2. Use 1Password Action in Workflows

**`.github/workflows/deploy.yml`:**

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Load secrets from 1Password
        uses: 1password/load-secrets-action@v1
        with:
          export-env: true
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
          NOTION_API_KEY: op://Automation/NOTION_API_KEY/credential
          TODOIST_API_TOKEN: op://Automation/TODOIST_API_TOKEN/credential
      
      - name: Run integration tests
        run: npm run test:integration
        # Tests can access $NOTION_API_KEY, $TODOIST_API_TOKEN from environment
```

### Benefits

✅ Secrets never stored in GitHub (only Service Account token)  
✅ Rotate API keys in 1Password, CI/CD picks up automatically  
✅ Audit trail in 1Password shows GitHub Actions access  
✅ Works across multiple repositories (share Service Account)

---

## Best Practices

### Security

✅ **Use Service Account** (not personal account) for automation  
✅ **Rotate tokens quarterly** (set calendar reminder)  
✅ **Scope GitHub PAT** to minimum permissions (repo, workflow)  
✅ **Review audit logs** weekly (1Password → Activity)  
❌ **Never log secrets** in n8n workflows or GitHub Actions  
❌ **Never commit `.env`** files (use `.env.template` with placeholders)

### Naming

✅ **Uppercase item names** match environment variables (`NOTION_API_KEY`)  
✅ **Tag consistently**: `["mcp-orchestrator", "{service}", "{type}"]`  
✅ **Descriptive notes**: "Used by n8n bidirectional sync workflow"  
✅ **Standard field names**: Use `credential` field for secrets (stable UUID)

### Reference Format

**Always use full secret reference syntax:**

```
op://Automation/NOTION_API_KEY/credential
└─┬──┘ └────┬────┘ └──────┬──────┘ └────┬────┘
  │         │              │             │
Vault     Item         Section        Field
```

**Why?** Survives renames (vault, item, field) because UUIDs don't change.

### Rotation Workflow

**Quarterly token rotation:**

1. **Generate new token** (Notion, Todoist, GitHub settings)
2. **Update in 1Password** (Automation vault)
3. **Test n8n workflow** (trigger manual execution)
4. **Test Copilot MCP** (restart VS Code with `op run -- code .`)
5. **Revoke old token** (in service provider settings)

**No code changes needed** - all integrations read from 1Password at runtime.

---

## Troubleshooting

### Issue: "Item not found"

**Cause**: Service Account doesn't have read access to vault.

**Fix**:
1. Go to [Service Account settings](https://my.1password.com/developer-tools/infrastructure-secrets/service-accounts)
2. Click your Service Account → **Vaults**
3. Ensure "Automation" vault has **Read** permission
4. Click **Save**

### Issue: "Invalid field reference"

**Cause**: Field name mismatch (e.g., `token` vs `credential`).

**Fix**:
```bash
# Inspect item to see actual field names
op item get "TODOIST_API_TOKEN" --vault="Automation" --format=json

# Use correct field name in reference
op://Automation/TODOIST_API_TOKEN/credential  # ✅ Correct
op://Automation/TODOIST_API_TOKEN/token       # ❌ Wrong (unless custom field exists)
```

### Issue: n8n workflow fails with "Authentication error"

**Cause**: n8n Cloud doesn't support `op://` references.

**Solution**: Manually paste credentials in n8n UI (Settings → Credentials).

---

## References

- [1Password Service Accounts](https://developer.1password.com/docs/service-accounts/)
- [1Password CLI Secret References](https://developer.1password.com/docs/cli/secret-references/)
- [1Password GitHub Actions Integration](https://developer.1password.com/docs/ci-cd/github-actions/)
- [n8n Credentials Documentation](https://docs.n8n.io/credentials/)
