#!/usr/bin/env bash
set -euo pipefail

echo "🔐 Setting up 1Password for MCP Orchestrator"
echo "=============================================="
echo ""

# Step 1: Create dedicated vault
echo "📦 Creating 'MCP Orchestrator' vault..."
op vault create "MCP Orchestrator" --description "Secrets for MCP Orchestrator - Notion, Todoist, GitHub integrations" || echo "Vault may already exist"

# Step 2: Create Service Account
echo ""
echo "🔑 Creating Service Account..."
echo "⚠️  The token will be shown ONCE - save it immediately!"
echo ""

op service-account create mcp-orchestrator-service-account \
  --vault "MCP Orchestrator:read_items" \
  --raw > /tmp/mcp-sa-token.txt

SA_TOKEN=$(cat /tmp/mcp-sa-token.txt)

echo "✅ Service Account created!"
echo ""
echo "Token (save this NOW): $SA_TOKEN"
echo ""

# Step 3: Save Service Account token in 1Password itself
echo "💾 Saving Service Account token to 1Password..."
op item create \
  --category "API Credential" \
  --vault "MCP Orchestrator" \
  --title "mcp-orchestrator.service-account-token" \
  --tags "mcp-orchestrator,service-account" \
  token="$SA_TOKEN" \
  type="service-account" \
  notes="1Password Service Account token for MCP Orchestrator. Scope: read_items on 'MCP Orchestrator' vault. Used to resolve op:// references at runtime. Treat as bootstrap credential."

echo "✅ Service Account token saved to 1Password"

# Step 4: Migrate Todoist token
echo ""
echo "📋 Migrating Todoist API token..."
TODOIST_TOKEN=$(op item get "todoist.api-token" --vault "Automation" --fields token)
op item create \
  --category "API Credential" \
  --vault "MCP Orchestrator" \
  --title "todoist.api-token" \
  --tags "mcp-orchestrator,todoist" \
  token="$TODOIST_TOKEN" \
  type="bearer" \
  notes="Todoist API token for MCP Orchestrator bidirectional sync. Premium plan required for Google Calendar integration. Scopes: data:read_write, project:delete. Used by: orchestrator sync engine."

echo "✅ Todoist token migrated"

# Step 5: Migrate Notion token (consolidate from multiple)
echo ""
echo "📘 Migrating Notion API token..."
echo "⚠️  You have multiple Notion tokens. Using 'notion.api-token' (generic one)"
NOTION_TOKEN=$(op item get "notion.api-token" --vault "Automation" --fields credential)
op item create \
  --category "API Credential" \
  --vault "MCP Orchestrator" \
  --title "notion.api-key.mcp-orchestrator" \
  --tags "mcp-orchestrator,notion" \
  credential="$NOTION_TOKEN" \
  type="bearer" \
  notes="Notion integration API key for MCP Orchestrator. Grant database access to: Tasks, Research, Completions. Capabilities: Read content, Update content, Insert content. Used by: orchestrator sync engine, Notion MCP server."

echo "✅ Notion token migrated"

# Step 6: Migrate GitHub token
echo ""
echo "🐙 Migrating GitHub PAT..."
if op item get "github.api-token.vscode.automation" --vault "Automation" &> /dev/null; then
  GITHUB_TOKEN=$(op item get "github.api-token.vscode.automation" --vault "Automation" --fields credential 2>/dev/null || op item get "github.api-token.vscode.automation" --vault "Automation" --fields token)
  op item create \
    --category "API Credential" \
    --vault "MCP Orchestrator" \
    --title "github.personal-access-token.mcp-orchestrator" \
    --tags "mcp-orchestrator,github" \
    personal_access_token="$GITHUB_TOKEN" \
    type="personal-access-token" \
    notes="GitHub Personal Access Token for MCP Orchestrator. Scopes: repo (full), workflow (write), read:org, read:user. Used for: webhook signature verification, Copilot Agents API, GitHub MCP server. Fine-grained alternative: repo contents, workflows, metadata, issues, pull requests."

  echo "✅ GitHub token migrated"
else
  echo "⚠️  github.api-token.vscode.automation not found. Skipping."
  echo "   You'll need to create a new GitHub PAT: https://github.com/settings/tokens"
  echo "   Scopes needed: repo, workflow, read:org, read:user"
fi

# Step 7: Optional - OpenAI (for AI features)
echo ""
echo "🤖 Migrating OpenAI API key (optional)..."
if op item get "openai.api-key.iterm2.personal" --vault "Automation" &> /dev/null; then
  read -p "Do you want to use OpenAI for AI tagging features? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    OPENAI_KEY=$(op item get "openai.api-key.iterm2.personal" --vault "Automation" --fields credential 2>/dev/null || op item get "openai.api-key.iterm2.personal" --vault "Automation" --fields api_key)
    op item create \
      --category "API Credential" \
      --vault "MCP Orchestrator" \
      --title "openai.api-key.mcp-orchestrator" \
      --tags "mcp-orchestrator,openai" \
      credential="$OPENAI_KEY" \
      type="bearer" \
      notes="OpenAI API key for MCP Orchestrator AI features. Used for: task auto-tagging (gpt-4), embeddings (text-embedding-3-small), semantic similarity search. Model: gpt-4 (configurable to gpt-4-turbo, claude-3-5-sonnet). Rate limits: check usage.openai.com."

    echo "✅ OpenAI key migrated"
  else
    echo "⏭️  Skipped OpenAI migration"
  fi
else
  echo "⏭️  openai.api-key.iterm2.personal not found. Skipping."
fi

# Clean up
rm -f /tmp/mcp-sa-token.txt

echo ""
echo "=============================================="
echo "✅ 1Password setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Update .env with new Service Account token:"
echo "   OP_SERVICE_ACCOUNT_TOKEN=$SA_TOKEN"
echo ""
echo "2. Verify vault access:"
echo "   op vault get 'MCP Orchestrator'"
echo ""
echo "3. Test secret resolution:"
echo "   op read 'op://MCP Orchestrator/todoist.api-token/token'"
echo ""
echo "4. Update .env references to use new vault:"
echo "   TODOIST_API_TOKEN=op://MCP Orchestrator/todoist.api-token/token"
echo "   NOTION_API_KEY=op://MCP Orchestrator/notion.api-key.mcp-orchestrator/credential"
echo "   GITHUB_PAT=op://MCP Orchestrator/github.personal-access-token.mcp-orchestrator/personal_access_token"
echo ""
echo "5. Restart orchestrator:"
echo "   cd orchestrator && npm run dev"
echo ""
