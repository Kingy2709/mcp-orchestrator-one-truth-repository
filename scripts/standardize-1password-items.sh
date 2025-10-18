#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# 1Password Item Standardization Script
# =============================================================================
# Purpose: Standardize all MCP Orchestrator items with:
#   - Uppercase naming (TODOIST_API_TOKEN vs todoist.api-token)
#   - Consistent tagging (mcp-orchestrator, service, type)
#   - Proper field structure (standard credential + custom fields when needed)
#
# Strategy:
#   1. Read secret from existing item
#   2. Delete old item
#   3. Create new item with standardized structure
#   4. Capture UUIDs for .env references
# =============================================================================

VAULT="MCP Orchestrator"
VAULT_UUID="fpaw6lqhfpib2j2k3z3w4v2ypq"

echo "🔧 Standardizing 1Password Items"
echo "================================="
echo ""
echo "This will:"
echo "  1. Rename items to UPPERCASE format (TODOIST_API_TOKEN)"
echo "  2. Update tags to: mcp-orchestrator, service, type"
echo "  3. Ensure standard 'credential' field + custom fields when needed"
echo "  4. Output UUID mappings for .env file"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Temporary file for UUID mappings
UUID_MAP_FILE="/tmp/mcp-orchestrator-uuids.env"
> "$UUID_MAP_FILE"

echo ""
echo "📦 Processing items..."
echo ""

# =============================================================================
# 1. TODOIST
# =============================================================================
echo "🔹 Todoist API Token"

# Read existing secret (try different possible field locations)
TODOIST_SECRET=$(op item get "todoist.api-token" --vault "$VAULT" --fields credential 2>/dev/null || \
                 op item get "todoist.api-token" --vault "$VAULT" --format json | jq -r '.fields[] | select(.label == "token") | .value' 2>/dev/null || \
                 echo "")

if [[ -z "$TODOIST_SECRET" || "$TODOIST_SECRET" == "null" ]]; then
  echo "  ❌ Could not read Todoist secret. Skipping."
else
  # Delete old item
  op item delete "todoist.api-token" --vault "$VAULT" --archive 2>/dev/null || true

  # Create new item with standard structure (dates will be set to now automatically)
  op item create \
    --category "API Credential" \
    --vault "$VAULT" \
    --title "TODOIST_API_TOKEN" \
    --tags "mcp-orchestrator,todoist,api-token" \
    credential="$TODOIST_SECRET" \
    type="bearer" \
    notesPlain="Todoist API token for MCP Orchestrator bidirectional sync. Premium plan for Calendar integration. Scopes: data:read_write, project:delete. Used by: orchestrator sync engine." \
    > /dev/null

  # Add custom "token" field for Todoist SDK compatibility
  op item edit "TODOIST_API_TOKEN" --vault "$VAULT" \
    token[password]="$TODOIST_SECRET" \
    > /dev/null

  # Delete expiration dates (remove "expired" warning)
  op item edit "TODOIST_API_TOKEN" --vault "$VAULT" \
    "expires[delete]" \
    "validFrom[delete]" \
    > /dev/null  # Capture UUIDs
  TODOIST_ITEM_UUID=$(op item get "TODOIST_API_TOKEN" --vault "$VAULT" --format json | jq -r '.id')
  TODOIST_FIELD_UUID=$(op item get "TODOIST_API_TOKEN" --vault "$VAULT" --format json | jq -r '.fields[] | select(.label == "token") | .id')

  echo "  ✅ TODOIST_API_TOKEN created"
  echo "TODOIST_API_TOKEN=op://$VAULT_UUID/$TODOIST_ITEM_UUID/$TODOIST_FIELD_UUID" >> "$UUID_MAP_FILE"
fi

# =============================================================================
# 2. NOTION
# =============================================================================
echo "🔹 Notion API Key"

NOTION_SECRET=$(op item get "notion.api-key.mcp-orchestrator" --vault "$VAULT" --fields credential 2>/dev/null || echo "")

if [[ -z "$NOTION_SECRET" || "$NOTION_SECRET" == "null" ]]; then
  echo "  ❌ Could not read Notion secret. Skipping."
else
  op item delete "notion.api-key.mcp-orchestrator" --vault "$VAULT" --archive 2>/dev/null || true

  op item create \
    --category "API Credential" \
    --vault "$VAULT" \
    --title "NOTION_API_KEY" \
    --tags "mcp-orchestrator,notion,api-key" \
    credential="$NOTION_SECRET" \
    type="api-key" \
    notesPlain="Notion integration API key for MCP Orchestrator. Grant access to: Tasks database, Research database, Completions database. Used by: orchestrator sync engine, Notion MCP server." \
    > /dev/null

  # Clear expiration date
  op item edit "NOTION_API_KEY" --vault "$VAULT" \
    "expires[delete]" \
    "validFrom[delete]" \
    > /dev/null

  # Notion SDK works with standard "credential" field, no custom field needed  NOTION_ITEM_UUID=$(op item get "NOTION_API_KEY" --vault "$VAULT" --format json | jq -r '.id')

  echo "  ✅ NOTION_API_KEY created (uses standard credential field)"
  echo "NOTION_API_KEY=op://$VAULT_UUID/$NOTION_ITEM_UUID/credential" >> "$UUID_MAP_FILE"
fi

# =============================================================================
# 3. GITHUB
# =============================================================================
echo "🔹 GitHub Personal Access Token"

GITHUB_SECRET=$(op item get "github.personal-access-token.mcp-orchestrator" --vault "$VAULT" --fields credential 2>/dev/null || \
                op item get "github.personal-access-token.mcp-orchestrator" --vault "$VAULT" --format json | jq -r '.fields[] | select(.label == "personal_access_token") | .value' 2>/dev/null || \
                echo "")

if [[ -z "$GITHUB_SECRET" || "$GITHUB_SECRET" == "null" ]]; then
  echo "  ❌ Could not read GitHub secret. Skipping."
else
  op item delete "github.personal-access-token.mcp-orchestrator" --vault "$VAULT" --archive 2>/dev/null || true

  op item create \
    --category "API Credential" \
    --vault "$VAULT" \
    --title "GITHUB_PERSONAL_ACCESS_TOKEN" \
    --tags "mcp-orchestrator,github,personal-access-token" \
    credential="$GITHUB_SECRET" \
    type="personal-access-token" \
    notesPlain="GitHub PAT for MCP Orchestrator. Scopes: repo (full control), workflow (update workflows), read:org (read org data), read:user (read user data). Used by: orchestrator webhooks, Copilot Agent triggering." \
    > /dev/null

  # Add custom "personal_access_token" field for GitHub CLI compatibility
  op item edit "GITHUB_PERSONAL_ACCESS_TOKEN" --vault "$VAULT" \
    personal_access_token[password]="$GITHUB_SECRET" \
    > /dev/null

  # Clear expiration date
  op item edit "GITHUB_PERSONAL_ACCESS_TOKEN" --vault "$VAULT" \
    "expires[delete]" \
    "validFrom[delete]" \
    > /dev/null  GITHUB_ITEM_UUID=$(op item get "GITHUB_PERSONAL_ACCESS_TOKEN" --vault "$VAULT" --format json | jq -r '.id')
  GITHUB_FIELD_UUID=$(op item get "GITHUB_PERSONAL_ACCESS_TOKEN" --vault "$VAULT" --format json | jq -r '.fields[] | select(.label == "personal_access_token") | .id')

  echo "  ✅ GITHUB_PERSONAL_ACCESS_TOKEN created"
  echo "GITHUB_PAT=op://$VAULT_UUID/$GITHUB_ITEM_UUID/$GITHUB_FIELD_UUID" >> "$UUID_MAP_FILE"
fi

# =============================================================================
# 4. OPENAI
# =============================================================================
echo "🔹 OpenAI API Key"

OPENAI_SECRET=$(op item get "openai.api-key.mcp-orchestrator" --vault "$VAULT" --fields credential 2>/dev/null || echo "")

if [[ -z "$OPENAI_SECRET" || "$OPENAI_SECRET" == "null" ]]; then
  echo "  ❌ Could not read OpenAI secret. Skipping."
else
  op item delete "openai.api-key.mcp-orchestrator" --vault "$VAULT" --archive 2>/dev/null || true

  op item create \
    --category "API Credential" \
    --vault "$VAULT" \
    --title "OPENAI_API_KEY" \
    --tags "mcp-orchestrator,openai,api-key" \
    credential="$OPENAI_SECRET" \
    type="api-key" \
    notesPlain="OpenAI API key for MCP Orchestrator AI features: task auto-tagging, embeddings-based similarity search, natural language task parsing. Model: gpt-4 (configurable). Used by: auto-tagger agent, task-grouper agent." \
    > /dev/null

  # Clear expiration date
  op item edit "OPENAI_API_KEY" --vault "$VAULT" \
    "expires[delete]" \
    "validFrom[delete]" \
    > /dev/null

  # OpenAI SDK works with standard "credential" field, no custom field needed  OPENAI_ITEM_UUID=$(op item get "OPENAI_API_KEY" --vault "$VAULT" --format json | jq -r '.id')

  echo "  ✅ OPENAI_API_KEY created (uses standard credential field)"
  echo "OPENAI_API_KEY=op://$VAULT_UUID/$OPENAI_ITEM_UUID/credential" >> "$UUID_MAP_FILE"
fi

# =============================================================================
# 5. SERVICE ACCOUNT TOKEN
# =============================================================================
echo "🔹 Service Account Token"

SA_SECRET=$(op item get "mcp-orchestrator.service-account-token" --vault "$VAULT" --fields credential 2>/dev/null || echo "")

if [[ -z "$SA_SECRET" || "$SA_SECRET" == "null" ]]; then
  echo "  ❌ Could not read Service Account token. Skipping."
else
  op item delete "mcp-orchestrator.service-account-token" --vault "$VAULT" --archive 2>/dev/null || true

  op item create \
    --category "API Credential" \
    --vault "$VAULT" \
    --title "MCP_ORCHESTRATOR_SERVICE_ACCOUNT_TOKEN" \
    --tags "mcp-orchestrator,1password,service-account" \
    credential="$SA_SECRET" \
    type="bearer" \
    notesPlain="1Password Service Account token for MCP Orchestrator. Vault access: 'MCP Orchestrator' (read_items only). Used by: orchestrator runtime, GitHub Actions CI/CD. This is the ONLY secret stored in plaintext in .env (bootstrap credential)." \
    > /dev/null

  # Clear expiration date
  op item edit "MCP_ORCHESTRATOR_SERVICE_ACCOUNT_TOKEN" --vault "$VAULT" \
    "expires[delete]" \
    "validFrom[delete]" \
    > /dev/null

  SA_ITEM_UUID=$(op item get "MCP_ORCHESTRATOR_SERVICE_ACCOUNT_TOKEN" --vault "$VAULT" --format json | jq -r '.id')

  echo "  ✅ MCP_ORCHESTRATOR_SERVICE_ACCOUNT_TOKEN created (uses standard credential field)"
  echo "# Service Account token (store in .env as plaintext - bootstrap credential)" >> "$UUID_MAP_FILE"
  echo "OP_SERVICE_ACCOUNT_TOKEN=$SA_SECRET" >> "$UUID_MAP_FILE"
  echo "" >> "$UUID_MAP_FILE"
fi

echo ""
echo "================================="
echo "✅ Standardization complete!"
echo ""
echo "📄 UUID Mappings saved to: $UUID_MAP_FILE"
echo ""
echo "📋 Next steps:"
echo "  1. Review the UUID mappings:"
echo "     cat $UUID_MAP_FILE"
echo ""
echo "  2. Update orchestrator/.env with these references"
echo ""
echo "  3. Test secret resolution:"
echo "     export OP_SERVICE_ACCOUNT_TOKEN=<your-token>"
echo "     op read 'op://fpaw6lqhfpib2j2k3z3w4v2ypq/.../...'"
echo ""
echo "  4. Restart orchestrator:"
echo "     cd orchestrator && npm run dev"
echo ""

# Display the mappings
echo "================================="
echo "📝 UUID Reference Mappings:"
echo "================================="
cat "$UUID_MAP_FILE"
echo "================================="
