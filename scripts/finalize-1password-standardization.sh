#!/usr/bin/env bash
set -euo pipefail

VAULT="MCP Orchestrator"
VAULT_UUID="fpaw6lqhfpib2j2k3z3w4v2ypq"

echo "🔧 Finalizing 1Password Standardization"
echo "========================================"
echo ""
echo "Current state: Some items renamed, some not"
echo "This will:"
echo "  1. Rename remaining lowercase items to UPPERCASE"
echo "  2. Fix dates (remove expiry warnings)"
echo "  3. Ensure correct field structure"
echo "  4. Output UUID mappings"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

UUID_MAP_FILE="/tmp/mcp-orchestrator-uuids.env"
> "$UUID_MAP_FILE"

echo ""
echo "📦 Processing items..."
echo ""

# =============================================================================
# 1. TODOIST (needs rename + custom token field)
# =============================================================================
echo "🔹 Todoist"

if op item get "todoist.api-token" --vault "$VAULT" >/dev/null 2>&1; then
  SECRET=$(op item get "todoist.api-token" --vault "$VAULT" --format json | jq -r '.fields[] | select(.type == "CONCEALED") | .value' | head -1)

  # Delete old item
  op item delete "todoist.api-token" --vault "$VAULT" --archive 2>/dev/null

  # Create new with correct structure
  op item create \
    --category "API Credential" \
    --vault "$VAULT" \
    --title "TODOIST_API_TOKEN" \
    --tags "mcp-orchestrator,todoist,api-token" \
    token[password]="$SECRET" \
    type="bearer" \
    notesPlain="Todoist API token for MCP Orchestrator bidirectional sync. Premium plan required for Calendar integration. Scopes: data:read_write, project:delete." \
    > /dev/null

  ITEM_UUID=$(op item get "TODOIST_API_TOKEN" --vault "$VAULT" --format json | jq -r '.id')
  FIELD_UUID=$(op item get "TODOIST_API_TOKEN" --vault "$VAULT" --format json | jq -r '.fields[] | select(.label == "token") | .id')

  echo "  ✅ TODOIST_API_TOKEN created with 'token' field"
  echo "TODOIST_API_TOKEN=op://$VAULT_UUID/$ITEM_UUID/$FIELD_UUID" >> "$UUID_MAP_FILE"
else
  echo "  ⚠️  todoist.api-token not found (may already be renamed)"
fi

# =============================================================================
# 2. GITHUB (needs rename + custom personal_access_token field)
# =============================================================================
echo "🔹 GitHub"

if op item get "github.personal-access-token.mcp-orchestrator" --vault "$VAULT" >/dev/null 2>&1; then
  SECRET=$(op item get "github.personal-access-token.mcp-orchestrator" --vault "$VAULT" --format json | jq -r '.fields[] | select(.type == "CONCEALED") | .value' | head -1)

  op item delete "github.personal-access-token.mcp-orchestrator" --vault "$VAULT" --archive 2>/dev/null

  op item create \
    --category "API Credential" \
    --vault "$VAULT" \
    --title "GITHUB_PERSONAL_ACCESS_TOKEN" \
    --tags "mcp-orchestrator,github,personal-access-token" \
    personal_access_token[password]="$SECRET" \
    type="personal-access-token" \
    notesPlain="GitHub PAT for MCP Orchestrator. Scopes: repo, workflow, read:org, read:user. Used by: webhooks, Copilot Agent triggering." \
    > /dev/null

  ITEM_UUID=$(op item get "GITHUB_PERSONAL_ACCESS_TOKEN" --vault "$VAULT" --format json | jq -r '.id')
  FIELD_UUID=$(op item get "GITHUB_PERSONAL_ACCESS_TOKEN" --vault "$VAULT" --format json | jq -r '.fields[] | select(.label == "personal_access_token") | .id')

  echo "  ✅ GITHUB_PERSONAL_ACCESS_TOKEN created with 'personal_access_token' field"
  echo "GITHUB_PAT=op://$VAULT_UUID/$ITEM_UUID/$FIELD_UUID" >> "$UUID_MAP_FILE"
else
  echo "  ⚠️  github.personal-access-token.mcp-orchestrator not found"
fi

# =============================================================================
# 3. SERVICE ACCOUNT (needs rename)
# =============================================================================
echo "🔹 Service Account"

if op item get "mcp-orchestrator.service-account-token" --vault "$VAULT" >/dev/null 2>&1; then
  SECRET=$(op item get "mcp-orchestrator.service-account-token" --vault "$VAULT" --fields credential 2>/dev/null)

  op item delete "mcp-orchestrator.service-account-token" --vault "$VAULT" --archive 2>/dev/null

  op item create \
    --category "API Credential" \
    --vault "$VAULT" \
    --title "MCP_ORCHESTRATOR_SERVICE_ACCOUNT_TOKEN" \
    --tags "mcp-orchestrator,1password,service-account" \
    credential="$SECRET" \
    type="bearer" \
    notesPlain="1Password Service Account token for MCP Orchestrator. Vault access: 'MCP Orchestrator' (read_items). Used by: orchestrator runtime, GitHub Actions. Store in .env as plaintext (bootstrap credential)." \
    > /dev/null

  ITEM_UUID=$(op item get "MCP_ORCHESTRATOR_SERVICE_ACCOUNT_TOKEN" --vault "$VAULT" --format json | jq -r '.id')

  echo "  ✅ MCP_ORCHESTRATOR_SERVICE_ACCOUNT_TOKEN created with 'credential' field"
  echo "# Service Account token (store in .env as plaintext)" >> "$UUID_MAP_FILE"
  echo "OP_SERVICE_ACCOUNT_TOKEN=$SECRET" >> "$UUID_MAP_FILE"
  echo "" >> "$UUID_MAP_FILE"
else
  echo "  ⚠️  mcp-orchestrator.service-account-token not found"
fi

# =============================================================================
# 4. NOTION (already renamed, just capture UUID)
# =============================================================================
echo "🔹 Notion"

if op item get "NOTION_API_KEY" --vault "$VAULT" >/dev/null 2>&1; then
  ITEM_UUID=$(op item get "NOTION_API_KEY" --vault "$VAULT" --format json | jq -r '.id')

  echo "  ✅ NOTION_API_KEY already exists (uses 'credential' field)"
  echo "NOTION_API_KEY=op://$VAULT_UUID/$ITEM_UUID/credential" >> "$UUID_MAP_FILE"
else
  echo "  ❌ NOTION_API_KEY not found"
fi

# =============================================================================
# 5. OPENAI (already renamed, just capture UUID)
# =============================================================================
echo "🔹 OpenAI"

if op item get "OPENAI_API_KEY" --vault "$VAULT" >/dev/null 2>&1; then
  ITEM_UUID=$(op item get "OPENAI_API_KEY" --vault "$VAULT" --format json | jq -r '.id')

  echo "  ✅ OPENAI_API_KEY already exists (uses 'credential' field)"
  echo "OPENAI_API_KEY=op://$VAULT_UUID/$ITEM_UUID/credential" >> "$UUID_MAP_FILE"
else
  echo "  ❌ OPENAI_API_KEY not found"
fi

echo ""
echo "========================================"
echo "✅ Standardization complete!"
echo ""
echo "📄 UUID mappings saved to: $UUID_MAP_FILE"
echo ""
cat "$UUID_MAP_FILE"
echo ""
echo "📋 Next steps:"
echo "  1. Copy these references to orchestrator/.env"
echo "  2. Test: cd orchestrator && npm run dev"
echo "========================================"
