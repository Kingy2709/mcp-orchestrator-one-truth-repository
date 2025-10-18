#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Fixing 1Password items in MCP Orchestrator vault"
echo "====================================================="
echo ""
echo "This will:"
echo "  1. Delete incorrectly created items"
echo "  2. Recreate with proper field names (token/credential/etc)"
echo "  3. Standardize types (all Bearer Tokens where applicable)"
echo "  4. Consistent tagging: mcp-orchestrator + service (notion/todoist/etc)"
echo "  5. Set proper dates (created now, no expiry)"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

VAULT="MCP Orchestrator"

# Helper function to create standardized API credential
create_api_credential() {
  local title="$1"
  local token_value="$2"
  local field_name="$3"  # token, credential, personal_access_token, api_key
  local type="${4:-bearer}"  # bearer, api-key, personal-access-token
  local service_tag="$5"  # todoist, notion, github, openai, service-account
  local notes="$6"

  echo "  Creating $title..."

  # Build the item with proper field structure
  op item create \
    --category "API Credential" \
    --vault "$VAULT" \
    --title "$title" \
    --tags "mcp-orchestrator,$service_tag" \
    "$field_name"="$token_value" \
    type="$type" \
    notes="$notes"

  echo "  ✅ $title created with type=$type, field=$field_name"
}

# Step 1: Save existing tokens to temp variables
echo ""
echo "📥 Reading existing tokens..."
SERVICE_ACCOUNT_TOKEN=$(op item get "mcp-orchestrator.service-account-token" --vault "$VAULT" --fields credential 2>/dev/null || echo "")
TODOIST_TOKEN=$(op item get "todoist.api-token" --vault "$VAULT" --fields token 2>/dev/null || echo "")
NOTION_TOKEN=$(op item get "notion.api-key.mcp-orchestrator" --vault "$VAULT" --fields credential 2>/dev/null || echo "")
GITHUB_TOKEN=$(op item get "github.personal-access-token.mcp-orchestrator" --vault "$VAULT" --fields personal_access_token 2>/dev/null || echo "")
OPENAI_KEY=$(op item get "openai.api-key.mcp-orchestrator" --vault "$VAULT" --fields api_key 2>/dev/null || echo "")

# Verify we got the tokens
if [[ -z "$SERVICE_ACCOUNT_TOKEN" ]]; then
  echo "❌ Failed to read Service Account token. Aborting."
  exit 1
fi
if [[ -z "$TODOIST_TOKEN" ]]; then
  echo "❌ Failed to read Todoist token. Aborting."
  exit 1
fi
if [[ -z "$NOTION_TOKEN" ]]; then
  echo "❌ Failed to read Notion token. Aborting."
  exit 1
fi

echo "✅ All tokens read successfully"

# Step 2: Delete existing items
echo ""
echo "🗑️  Deleting old items..."
op item delete "mcp-orchestrator.service-account-token" --vault "$VAULT" || echo "  Already deleted"
op item delete "todoist.api-token" --vault "$VAULT" || echo "  Already deleted"
op item delete "notion.api-key.mcp-orchestrator" --vault "$VAULT" || echo "  Already deleted"
op item delete "github.personal-access-token.mcp-orchestrator" --vault "$VAULT" || echo "  Already deleted"
if [[ -n "$OPENAI_KEY" ]]; then
  op item delete "openai.api-key.mcp-orchestrator" --vault "$VAULT" || echo "  Already deleted"
fi
echo "✅ Old items deleted"

# Step 3: Recreate with proper standards
echo ""
echo "✨ Creating standardized items..."

# Service Account Token
create_api_credential \
  "mcp-orchestrator.service-account-token" \
  "$SERVICE_ACCOUNT_TOKEN" \
  "token" \
  "service-account" \
  "service-account" \
  "1Password Service Account token for MCP Orchestrator. Scope: read_items on 'MCP Orchestrator' vault. Used to resolve op:// references at runtime. Treat as bootstrap credential."

# Todoist API Token
create_api_credential \
  "todoist.api-token" \
  "$TODOIST_TOKEN" \
  "token" \
  "bearer" \
  "todoist" \
  "Todoist API token for MCP Orchestrator bidirectional sync. Premium plan required for Google Calendar integration. Scopes: data:read_write, project:delete. Used by: orchestrator sync engine."

# Notion Integration Key
create_api_credential \
  "notion.api-key.mcp-orchestrator" \
  "$NOTION_TOKEN" \
  "credential" \
  "bearer" \
  "notion" \
  "Notion integration API key for MCP Orchestrator. Grant database access to: Tasks, Research, Completions. Capabilities: Read content, Update content, Insert content. Used by: orchestrator sync engine, Notion MCP server."

# GitHub Personal Access Token
if [[ -n "$GITHUB_TOKEN" ]]; then
  create_api_credential \
    "github.personal-access-token.mcp-orchestrator" \
    "$GITHUB_TOKEN" \
    "personal_access_token" \
    "personal-access-token" \
    "github" \
    "GitHub Personal Access Token for MCP Orchestrator. Scopes: repo (full), workflow (write), read:org, read:user. Used for: webhook signature verification, Copilot Agents API, GitHub MCP server. Fine-grained alternative: repo contents, workflows, metadata, issues, pull requests."
fi

# OpenAI API Key
if [[ -n "$OPENAI_KEY" ]]; then
  create_api_credential \
    "openai.api-key.mcp-orchestrator" \
    "$OPENAI_KEY" \
    "credential" \
    "bearer" \
    "openai" \
    "OpenAI API key for MCP Orchestrator AI features. Used for: task auto-tagging (gpt-4), embeddings (text-embedding-3-small), semantic similarity search. Model: gpt-4 (configurable to gpt-4-turbo, claude-3-5-sonnet). Rate limits: check usage.openai.com."
fi

echo ""
echo "====================================================="
echo "✅ All items fixed!"
echo ""
echo "📋 Standardization applied:"
echo "  ✓ Field names: token (Todoist/SA), credential (Notion/OpenAI), personal_access_token (GitHub)"
echo "  ✓ Types: bearer (Todoist/Notion/OpenAI), service-account (SA), personal-access-token (GitHub)"
echo "  ✓ Tags: All tagged with 'mcp-orchestrator' + service name"
echo "  ✓ Dates: Created now, no expiration"
echo "  ✓ Notes: Comprehensive usage documentation"
echo ""
echo "🔍 Verify with:"
echo "  op item list --vault 'MCP Orchestrator' --format json | jq '.[] | {title, tags}'"
echo ""
echo "🧪 Test resolution:"
echo "  op read 'op://MCP Orchestrator/todoist.api-token/token'"
echo "  op read 'op://MCP Orchestrator/notion.api-key.mcp-orchestrator/credential'"
echo ""
