# GitHub Copilot Integration

> Complete guide for integrating GitHub Copilot with MCP servers for Notion access and agent delegation.

## Table of Contents

1. [Overview](#overview)
2. [MCP Server Setup](#mcp-server-setup)
3. [Agent Configuration](#agent-configuration)
4. [Usage Examples](#usage-examples)
5. [Troubleshooting](#troubleshooting)

---

## Overview

**GitHub Copilot Integration provides:**

- ✅ **Notion MCP Server**: Search and create Notion pages from Copilot Chat
- ✅ **Agent Delegation**: @research/@code tags trigger automated Copilot Agents
- ✅ **1Password Integration**: Secure credential injection via Service Account

**Architecture:**

```
Copilot Chat → Notion MCP Server → 1Password (NOTION_API_KEY) → Notion API
                                                                         ↓
n8n Workflow detects @research/@code tag → GitHub Actions → Copilot Agent
```

---

## MCP Server Setup

### 1. Install Official Notion MCP Server

```bash
# Global installation
npm install -g @makenotion/notion-mcp-server

# Verify installation
which notion-mcp-server
# Expected: /usr/local/bin/notion-mcp-server or similar
```

### 2. Configure Copilot

**Create or edit `~/.copilot/config.json`:**

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

**Explanation:**

- `command`: Executable name (globally installed)
- `env.NOTION_API_KEY`: 1Password secret reference
- MCP server launched automatically when Copilot Chat starts

### 3. Launch VS Code with 1Password Injection

```bash
# Set Service Account token
export OP_SERVICE_ACCOUNT_TOKEN="ops_ey..."

# Option 1: Launch VS Code with op run
op run -- code .

# Option 2: Add to shell profile for automatic injection
echo 'alias code="op run -- code"' >> ~/.zshrc
source ~/.zshrc

# Now every `code .` command automatically injects 1Password secrets
```

### 4. Test in Copilot Chat

Open Copilot Chat and try:

```
User: "Search Notion for OAuth research tasks"

Copilot: [Uses Notion MCP] I found 3 pages related to OAuth research:
1. OAuth Integration (Last edited: Oct 15, 2025)
2. GitHub OAuth Flow (Last edited: Oct 10, 2025)
3. Todoist OAuth Investigation (Last edited: Oct 5, 2025)

Would you like me to open any of these pages?
```

**Available MCP Commands:**

- `search_pages` - Search Notion workspace
- `create_page` - Create new Notion page
- `update_page` - Update existing page
- `query_database` - Query Notion database with filters

---

## Agent Configuration

### Overview

**Agent delegation workflow:**

1. n8n detects @research or @code tag (from AI auto-tagger)
2. HTTP Request node calls GitHub API `repository_dispatch`
3. GitHub Actions workflow triggered
4. Copilot Agent executes task
5. Results written to Notion page
6. Todoist task marked complete

### 1. Create Agent Configuration Files

**`agents/research-agent.yml`:**

```yaml
name: research-agent
description: Searches GitHub repos and documentation, generates summaries

tools:
  - github_search
  - web_scraping
  - notion_mcp

prompt_template: |
  Research the following topic and create a comprehensive summary:

  Topic: {{ task_content }}

  Steps:
  1. Search GitHub repositories for relevant code examples
  2. Find official documentation
  3. Summarize key findings
  4. Create Notion page with results

  Output format: Markdown with code examples
```

**`agents/code-agent.yml`:**

```yaml
name: code-agent
description: Implements features and creates pull requests

tools:
  - github_api
  - file_operations
  - notion_mcp

prompt_template: |
  Implement the following feature:

  Feature: {{ task_content }}
  Repository: mcp-orchestrator-one-truth-repository

  Steps:
  1. Create feature branch
  2. Implement feature with tests
  3. Create pull request
  4. Update Notion page with PR link

  Follow project conventions in .github/copilot-instructions.md
```

### 2. Create GitHub Actions Workflows

**`.github/workflows/research-agent.yml`:**

```yaml
name: Research Agent

on:
  repository_dispatch:
    types: [copilot_agent_trigger]

jobs:
  research:
    if: github.event.client_payload.agent == 'research-agent'
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

      - name: Run GitHub Copilot Agent
        run: |
          gh copilot agent run \
            --agent research-agent \
            --prompt "${{ github.event.client_payload.prompt }}" \
            --config agents/research-agent.yml

      - name: Update Notion with Results
        uses: makenotion/notion-github-action@v1
        with:
          notion-token: ${{ env.NOTION_API_KEY }}
          page-id: ${{ github.event.client_payload.context.notion_page }}
          content: ${{ steps.research.outputs.summary }}
```

**`.github/workflows/code-agent.yml`:**

```yaml
name: Code Agent

on:
  repository_dispatch:
    types: [copilot_agent_trigger]

jobs:
  code:
    if: github.event.client_payload.agent == 'code-agent'
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

      - name: Run GitHub Copilot Agent
        run: |
          gh copilot agent run \
            --agent code-agent \
            --prompt "${{ github.event.client_payload.prompt }}" \
            --config agents/code-agent.yml \
            --create-pr

      - name: Update Todoist Task
        run: |
          curl -X POST "https://api.todoist.com/rest/v2/tasks/${{ github.event.client_payload.task_id }}/close" \
            -H "Authorization: Bearer ${{ secrets.TODOIST_API_TOKEN }}"
```

### 3. Configure n8n HTTP Request Node

**In n8n workflow (Node 5 - Conditional Agent Trigger):**

```yaml
Type: HTTP Request
Method: POST
URL: https://api.github.com/repos/Kingy2709/mcp-orchestrator-one-truth-repository/dispatches
Headers:
  Authorization: Bearer {{ $credentials.github_pat }}
  Accept: application/vnd.github+json
Body:
  event_type: "copilot_agent_trigger"
  client_payload:
    agent: "{{ $node["OpenAI"].json.tags.includes("@research") ? "research-agent" : "code-agent" }}"
    task_id: "{{ $json.event_data.id }}"
    prompt: "{{ $json.event_data.content }}"
    context:
      notion_page: "{{ $node["Notion"].json.url }}"
      priority: "{{ $json.event_data.priority }}"
```

---

## Usage Examples

### Example 1: Research OAuth Integration

**User creates task in Todoist:**

```
"Research OAuth 2.0 flow for GitHub integration @work @research"
```

**Workflow:**

1. n8n receives webhook from Todoist
2. OpenAI node tags: `["@work", "@research"]` with 0.92 confidence
3. Notion database updated
4. HTTP Request triggers GitHub Actions (research-agent.yml)
5. Copilot Agent:
   - Searches GitHub for OAuth examples
   - Finds official GitHub OAuth documentation
   - Generates summary with code examples
   - Creates Notion page: "OAuth 2.0 Integration Research"
6. Todoist task updated with link to Notion page

**Result**: 5 minutes from Siri command to complete research summary in Notion.

### Example 2: Implement Feature

**User creates task in Todoist:**

```
"Add rate limiting to webhook endpoint @code @urgent"
```

**Workflow:**

1. n8n receives webhook
2. OpenAI tags: `["@code", "@urgent", "@work"]` with 0.88 confidence
3. Notion updated
4. GitHub Actions triggers code-agent.yml
5. Copilot Agent:
   - Creates branch: `feature/webhook-rate-limiting`
   - Implements rate limiting middleware
   - Adds tests
   - Creates PR with description
   - Updates Notion with PR link
6. Todoist task marked complete

**Result**: Feature implemented, tested, and ready for review in < 10 minutes.

### Example 3: Manual Copilot Chat Query

**In VS Code Copilot Chat:**

```
User: "Create a Notion page summarizing our n8n architecture"

Copilot: [Uses Notion MCP] I'll create a page in your Notion workspace.

[Reads ARCHITECTURE.md and n8n workflow documentation]

Created page: "n8n Architecture Summary"
- Bidirectional sync workflow
- AI auto-tagging with OpenAI
- Conflict resolution logic
- Error handling strategy

Link: https://notion.so/...
```

---

## Troubleshooting

### Issue: "MCP server not found"

**Symptoms**: Copilot Chat doesn't recognize Notion MCP commands.

**Fix**:

1. Check `~/.copilot/config.json` exists and has correct syntax
2. Verify `notion-mcp-server` is globally installed:

   ```bash
   npm list -g @makenotion/notion-mcp-server
   ```

3. Restart VS Code

### Issue: "Authentication error" from Notion MCP

**Symptoms**: MCP server fails with 401 Unauthorized.

**Fix**:

1. Verify 1Password Service Account token is set:

   ```bash
   echo $OP_SERVICE_ACCOUNT_TOKEN
   # Should output: ops_ey...
   ```

2. Test 1Password reference manually:

   ```bash
   op read "op://Automation/NOTION_API_KEY/credential"
   # Should output: secret_...
   ```

3. Relaunch VS Code with `op run -- code .`

### Issue: GitHub Actions workflow not triggering

**Symptoms**: Create task with @research tag, no workflow execution.

**Fix**:

1. Check `OP_SERVICE_ACCOUNT_TOKEN` is set in GitHub Secrets
2. Verify n8n HTTP Request node has correct repository URL
3. Check GitHub Actions logs for errors:

   ```bash
   gh run list --workflow=research-agent.yml
   ```

4. Test repository_dispatch manually:

   ```bash
   curl -X POST \
     -H "Authorization: Bearer $GITHUB_PAT" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/repos/Kingy2709/mcp-orchestrator-one-truth-repository/dispatches \
     -d '{"event_type":"copilot_agent_trigger","client_payload":{"agent":"research-agent","prompt":"Test"}}'
   ```

### Issue: Agent execution slow (> 5 minutes)

**Symptoms**: Agent tasks take longer than expected.

**Optimization**:

1. Use `gpt-3.5-turbo` for simpler tasks (faster than GPT-4)
2. Cache GitHub search results in Notion
3. Reduce scope of research (specific repos only)
4. Run agents in parallel for multiple tasks

---

## Best Practices

### Security

✅ **Use Service Account** for all automation (not personal 1Password account)
✅ **Scope GitHub PAT** to minimum permissions (repo, workflow)
✅ **Review agent outputs** before merging PRs
❌ **Never log credentials** in workflows

### Performance

✅ **Batch agent requests** (process multiple tasks together)
✅ **Cache research results** in Notion (avoid duplicate searches)
✅ **Use specific prompts** (faster than open-ended research)
✅ **Set timeouts** (abort after 5 minutes)

### Workflow Optimization

✅ **Tag consistently**: Use @research/@code, not random tags
✅ **Clear task descriptions**: Better prompts → better agent results
✅ **Review AI confidence**: Manual review if < 0.7
✅ **Monitor execution logs**: Check GitHub Actions for errors

---

## References

- [Official Notion MCP Server](https://github.com/makenotion/notion-mcp-server)
- [GitHub Copilot Agents Documentation](https://github.com/features/copilot)
- [Model Context Protocol Spec](https://modelcontextprotocol.io/docs)
- [1Password Setup Guide](../setup/1password.md)
- [n8n Workflow Configuration](../setup/n8n.md)
