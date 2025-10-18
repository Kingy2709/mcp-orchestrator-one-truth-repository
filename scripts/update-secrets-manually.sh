#!/usr/bin/env bash
# Helper script to update secrets in MCP Orchestrator vault
# Run this AFTER you've manually copied secrets from your personal 1Password

set -euo pipefail

VAULT="MCP Orchestrator"

echo "🔐 Update MCP Orchestrator Secrets"
echo "===================================="
echo ""
echo "This script will prompt you to paste each secret."
echo "Get the secrets from your personal 1Password app."
echo ""

read -p "Update TODOIST_API_TOKEN? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Paste Todoist API token (from https://todoist.com/prefs/integrations):"
  read -s TODOIST_SECRET
  op item edit "TODOIST_API_TOKEN" --vault "$VAULT" "token[password]=$TODOIST_SECRET"
  echo "✅ Todoist updated"
fi

read -p "Update GITHUB_PERSONAL_ACCESS_TOKEN? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Paste GitHub PAT (from https://github.com/settings/tokens):"
  read -s GITHUB_SECRET
  op item edit "GITHUB_PERSONAL_ACCESS_TOKEN" --vault "$VAULT" "personal_access_token[password]=$GITHUB_SECRET"
  echo "✅ GitHub updated"
fi

read -p "Update NOTION_API_KEY? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Paste Notion API key (from https://www.notion.so/my-integrations):"
  read -s NOTION_SECRET
  op item edit "NOTION_API_KEY" --vault "$VAULT" "credential[password]=$NOTION_SECRET"
  echo "✅ Notion updated"
fi

read -p "Update OPENAI_API_KEY? (y/n) " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Paste OpenAI API key (from https://platform.openai.com/api-keys):"
  read -s OPENAI_SECRET
  op item edit "OPENAI_API_KEY" --vault "$VAULT" "credential[password]=$OPENAI_SECRET"
  echo "✅ OpenAI updated"
fi

echo ""
echo "===================================="
echo "✅ Secrets updated!"
echo ""
echo "Test with: cd orchestrator && npm run dev"
echo "===================================="
