# 1Password Setup Guide - Shell Plugins & Service Account

## Overview

This guide sets up 1Password with **Shell Plugins** for CLI tool authentication and **Service Account** for unattended orchestrator access.

## Strategy

- **Shell Plugins**: For interactive CLI tools (GitHub CLI, Todoist CLI, etc.)
- **Service Account**: For unattended services (orchestrator running 24/7)
- **Vault**: "Automation" (dedicated vault for all automation secrets)

---

## Part 1: Service Account Setup

### 1. Create Service Account

Already done! Your Service Account:
- Name: `1password.service-account-auth-token.github-actions.automation`
- UUID: `ldldfxg5rot5r6prbnqzc4lamm`
- Token: `ops_ey...` (stored in `.env`)

### 2. Grant Vault Access

```bash
# Verify Service Account has read access to "Automation" vault
# Done via: https://my.1password.com/developer-tools/infrastructure-secrets/service-accounts
```

---

## Part 2: Shell Plugins for CLI Tools

### Why Shell Plugins?

1. **Auto-creates items with correct field names** (no manual configuration)
2. **Temporary injection** (credentials never touch disk)
3. **Audit trail** (every CLI access logged in 1Password)
4. **Per-tool standards** (Todoist expects `token`, GitHub expects `personal_access_token`, etc.)

### Supported Plugins

See full list: https://developer.1password.com/docs/cli/shell-plugins

---

## Part 3: Setup Each Tool

### Todoist CLI

**Current status**: ✅ Already configured correctly!

```bash
# Verify configuration
op plugin inspect todoist

# Should show:
# CREDENTIAL TYPE      ITEM                 VAULT
# Todoist API Token    todoist.api-token    Automation
```

**If not configured, run:**
```bash
op plugin init todoist
# Follow prompts to:
# 1. Select "Import into 1Password..."
# 2. Paste your Todoist API token from: https://todoist.com/prefs/integrations
# 3. Save to "Automation" vault
# 4. Item will be auto-named: todoist.api-token
```

---

### GitHub CLI

**Issue found**: You have `github.ssh-key.cli.automation` but Homebrew needs a **Personal Access Token**, not SSH key.

**Fix:**
```bash
# 1. Authenticate GitHub CLI (creates PAT automatically)
gh auth login
# Select:
# - GitHub.com
# - HTTPS (not SSH)
# - Login with web browser
# This creates a PAT and stores in 1Password via plugin

# 2. Initialize plugin
op plugin init gh
# This will find the PAT created above

# 3. For Homebrew specifically
op plugin init brew
# This uses your GitHub PAT for Homebrew API access
```

**Item naming after `op plugin init gh`:**
- Auto-created as: `github.personal-access-token.<username>`
- Vault: Automation
- Field name: `personal_access_token` (not `credential`)

---

### Notion CLI (if exists)

**Current setup**: You have `notion.api-token` with field `credential`

**Problem**: If Notion has a shell plugin, it might expect `api_key` field instead.

**Check if plugin exists:**
```bash
op plugin init notion
# If it exists, follow prompts
# If not, manual setup is fine
```

**For manual items (when no plugin exists):**
```bash
# Create API Credentials item
op item create \
  --category "API Credential" \
  --vault "Automation" \
  --title "notion.api-key" \
  credential="secret_abc123..."

# Or rename existing:
op item edit "notion.api-token" credential[label]="api_key"
```

---

## Part 4: Standardized Naming Convention

Use this pattern for **all** automation secrets:

```
Format: <service>.<credential-type>.<context>

Examples:
✅ todoist.api-token                      (Shell plugin - auto-named)
✅ github.personal-access-token.kingy2709 (Shell plugin - auto-named)
✅ notion.api-key                         (Manual - use plugin field name)
✅ openai.api-key                         (Manual)
✅ claude.api-key                         (Manual)
✅ 1password.service-account-auth-token.github-actions.automation (Service Account)

❌ Todoist (too generic)
❌ My Notion Token (spaces, unclear)
❌ api-key (which service?)
```

---

## Part 5: 1Password References in .env

### For Service Account (Unattended Access)

The orchestrator uses **Service Account** to resolve `op://` references at runtime:

```bash
# .env
OP_SERVICE_ACCOUNT_TOKEN=ops_ey...  # Real token (required for bootstrap)

# All other secrets use op:// references
TODOIST_API_TOKEN=op://Automation/todoist.api-token/token
NOTION_API_KEY=op://Automation/notion.api-key/credential
GITHUB_PAT=op://Automation/github.personal-access-token.kingy2709/personal_access_token
```

**Format**: `op://[vault]/[item-name]/[field-name]`

### For Shell Plugins (Interactive CLI)

No `.env` needed! The shell plugin auto-injects credentials:

```bash
# Just run the command, credentials injected automatically
todoist list
gh repo list
```

---

## Part 6: Migration Checklist

### Step 1: Audit Current Items

```bash
# List all items in Automation vault
op item list --vault "Automation" --format json

# Inspect each item
op item get "todoist.api-token" --format json
op item get "notion.api-token" --format json
op item get "github.ssh-key.cli.automation" --format json
```

### Step 2: Initialize Shell Plugins

```bash
# Todoist (already done!)
op plugin inspect todoist  # Verify ✅

# GitHub CLI
gh auth login  # Creates PAT automatically
op plugin init gh

# Homebrew (uses GitHub PAT)
op plugin init brew

# Check for others
op plugin list  # See all available plugins
```

### Step 3: Update Field Names (if needed)

**For Notion (if no plugin exists):**
```bash
# Check current fields
op item get "notion.api-token" --fields label=credential

# If orchestrator expects "credential" field, you're good!
# If you need "api_key" field:
op item edit "notion.api-token" \
  --delete-field credential \
  credential[label]=api_key[value]="secret_..."
```

**For GitHub (if you have SSH key instead of PAT):**
```bash
# Create new PAT via gh CLI
gh auth login  # This creates the PAT

# Or manually: https://github.com/settings/tokens
# Scopes needed: repo, workflow, read:org, read:user

# Then:
op plugin init gh  # Imports the PAT
```

### Step 4: Update .env References

```bash
# Edit .env
code .env
```

Update to use correct item names and field names:

```bash
# Before (generic placeholders)
TODOIST_API_TOKEN=${TODOIST_API_TOKEN}

# After (1Password references with correct field names)
TODOIST_API_TOKEN=op://Automation/todoist.api-token/token
NOTION_API_KEY=op://Automation/notion.api-key/credential
GITHUB_PAT=op://Automation/github.personal-access-token.kingy2709/personal_access_token
```

### Step 5: Test Resolution

```bash
# Test Service Account can resolve secrets
OP_SERVICE_ACCOUNT_TOKEN="ops_ey..." op read "op://Automation/todoist.api-token/token"

# Should output your Todoist token (not an error)
```

### Step 6: Test Orchestrator

```bash
cd orchestrator
npm run dev

# Should see:
# ✅ Starting MCP Orchestrator...
# ✅ Webhook server listening on port 3000
# ✅ Notion sync started
# ✅ Todoist sync started

# NOT:
# ❌ 401 Unauthorized
```

---

## Part 7: Troubleshooting

### Error: "API token is invalid"

**Cause**: Wrong field name or item name in `op://` reference

**Fix**:
```bash
# 1. Check item exists
op item get "todoist.api-token" --vault "Automation"

# 2. Check field name
op item get "todoist.api-token" --fields label

# 3. Update .env with correct names
TODOIST_API_TOKEN=op://Automation/todoist.api-token/<correct-field-name>
```

### Error: "Item not found"

**Cause**: Item name in `.env` doesn't match 1Password

**Fix**:
```bash
# List all items
op item list --vault "Automation"

# Copy exact name (case-sensitive!)
# Update .env
```

### Error: "Service Account cannot access vault"

**Cause**: Service Account lacks permission

**Fix**:
1. Go to: https://my.1password.com/developer-tools/infrastructure-secrets/service-accounts
2. Select your Service Account
3. Grant "Read" access to "Automation" vault
4. Save changes

---

## Part 8: Security Best Practices

### DO ✅

- Use **Shell Plugins** for interactive CLI tools (auto-configures field names)
- Use **Service Account** for unattended services (orchestrator)
- Store Service Account token in `.env` (only secret stored plaintext)
- Use `op://` references for all other secrets in `.env`
- Keep "Automation" vault separate from personal items
- Rotate Service Account token every 90 days
- Use specific PATs (not your main GitHub account token)

### DON'T ❌

- Store API tokens in plaintext in `.env` (except Service Account token)
- Use SSH keys as API tokens (different purposes!)
- Mix personal and automation secrets in same vault
- Share Service Account tokens (1 per service)
- Commit `.env` to git (already in `.gitignore`)
- Use 1Password Environments for unattended services (use Service Account instead)

---

## Quick Reference

### Shell Plugin Commands

```bash
# List available plugins
op plugin list

# Initialize a plugin
op plugin init <plugin-name>

# Inspect current configuration
op plugin inspect <plugin-name>

# Run command with injected credentials
<cli-tool> <command>  # e.g., todoist list
```

### Service Account Commands

```bash
# Test secret resolution
op read "op://Automation/item-name/field-name"

# With Service Account token
OP_SERVICE_ACCOUNT_TOKEN="ops_ey..." op read "op://..."

# List vaults accessible to Service Account
OP_SERVICE_ACCOUNT_TOKEN="ops_ey..." op vault list
```

### 1Password Reference Format

```
op://[vault]/[item-name]/[field-name]

Examples:
op://Automation/todoist.api-token/token
op://Automation/notion.api-key/credential
op://Automation/github.personal-access-token.kingy2709/personal_access_token
```

---

## Resources

- **Shell Plugins**: https://developer.1password.com/docs/cli/shell-plugins
- **Service Accounts**: https://developer.1password.com/docs/service-accounts
- **Todoist Plugin**: https://developer.1password.com/docs/cli/shell-plugins/todoist
- **GitHub CLI Plugin**: https://developer.1password.com/docs/cli/shell-plugins/github
- **Secret References**: https://developer.1password.com/docs/cli/secret-references

---

## Summary

**Your breakthrough discovery**: `op plugin init` auto-creates items with **correct field names** that each CLI tool expects, eliminating the manual configuration hell!

**Next steps**:
1. Run `gh auth login` to create GitHub PAT (replaces SSH key for API access)
2. Run `op plugin init gh` and `op plugin init brew`
3. Update `.env` with correct `op://` references (see Part 6)
4. Test orchestrator: `cd orchestrator && npm run dev`

Let me know when you're ready to update the `.env` file! 🚀
