# 1Password Configuration - Complete Guide

> **Single Source of Truth**: Comprehensive 1Password integration for CLI automation, n8n workflows, MCP servers, and CI/CD pipelines.

**Last Updated**: October 22, 2025  
**Version**: 2.0 (Merged from 1password.md + 1password-uuid-reference-guide.md)

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture: Two-Vault Strategy](#architecture-two-vault-strategy)
3. [Service Account Setup](#service-account-setup)
4. [Credential Naming Standards](#credential-naming-standards)
5. [Field Structure & UUID Behavior](#field-structure--uuid-behavior)
6. [CLI Integration (Personal Development)](#cli-integration-personal-development)
7. [MCP Orchestrator Integration (Production)](#mcp-orchestrator-integration-production)
8. [n8n Integration](#n8n-integration)
9. [GitHub Copilot MCP Integration](#github-copilot-mcp-integration)
10. [GitHub Actions (CI/CD)](#github-actions-cicd)
11. [Best Practices](#best-practices)
12. [Troubleshooting](#troubleshooting)
13. [References](#references)

---

## Overview

### Strategy

This project uses **two separate 1Password vaults** with **two separate service accounts** for clear separation between personal development and production automation:

| Aspect | CLI Vault | MCP Orchestrator Vault |
|--------|-----------|------------------------|
| **Purpose** | Personal development, shell tools | Production automation, n8n |
| **Service Account** | `1password.service-account.cli` | `1password.service-account.mcp-orchestrator` |
| **Used By** | .zshrc, CLI tools, experiments | Docker, n8n, CI/CD, webhooks |
| **Secrets** | Personal API keys, Homebrew tokens | Production API keys for orchestrator |
| **Security** | Scoped to CLI vault only | Scoped to MCP Orchestrator vault only |

**Key Benefits:**

✅ **Separation of concerns**: Personal experiments don't affect production  
✅ **Security**: Compromised CLI token doesn't expose production secrets  
✅ **Auditing**: Clear distinction between personal and automated usage  
✅ **Rotation**: Rotate production keys without touching dev environment  
✅ **Billing**: Track OpenAI/API usage separately (dev vs production)

### Why 1Password?

✅ Centralized secret management across all tools  
✅ Audit trail (every access logged with timestamp)  
✅ No secrets in code or environment files  
✅ Service Accounts for automation (no human login required)  
✅ CLI, SDK, and shell integration  
✅ **Field label resolution** (survives renames, no custom UUID tracking needed)  
✅ Parallel secret loading (6x faster shell startup: 2s vs 12s)

---

## Architecture: Two-Vault Strategy

### Complete Vault Structure

```
1Password Account: Matthew King
│
├── Personal/                          → Personal accounts, passwords
│   └── Banking, social media, etc.
│
├── Clinic/                            → Work-related credentials
│   └── EMR, practice management, etc.
│
├── CLI/                               → Personal development tools ⭐
│   ├── Service Account: 1password.service-account.cli
│   ├── Scope: CLI vault only (read-only)
│   │
│   └── Secrets:
│       ├── openai.api-key.cli (UUID: vu3qf2nd5g6yzhik4l6zt5sy7a)
│       ├── github.personal-access-token.cli
│       ├── github.personal-access-token.homebrew
│       ├── notion.api-key.cli
│       ├── todoist.api-token.cli
│       ├── huggingface.access-token.cli
│       └── 1password.service-account.cli (bootstrap token)
│
└── MCP Orchestrator/                  → Production automation ⭐
    ├── Service Account: 1password.service-account.mcp-orchestrator
    ├── Scope: MCP Orchestrator vault only (read-only)
    │
    └── Secrets:
        ├── openai.api-key.mcp-orchestrator
        ├── github.personal-access-token.mcp-orchestrator
        ├── todoist.api-token.mcp-orchestrator
        ├── notion.api-key.mcp-orchestrator
        └── 1password.service-account.mcp-orchestrator (bootstrap token)
```

### Vault Purpose Matrix

| Vault | Service Account | Scopes | Used By | Security Model |
|-------|----------------|--------|---------|----------------|
| **CLI** | `1password.service-account.cli` | Read CLI vault only | .zshrc, terminal, CLI tools | Personal dev, low blast radius |
| **MCP Orchestrator** | `1password.service-account.mcp-orchestrator` | Read MCP Orchestrator vault only | n8n, Docker, CI/CD | Production, isolated from personal |
| **Personal** | None | N/A | 1Password app only | Manual access, no automation |
| **Clinic** | None | N/A | 1Password app only | Manual access, no automation |

**Why two vaults?**

1. **Security**: Compromised CLI service account can't access production secrets
2. **Clarity**: Easy to audit what each service account can access
3. **Performance**: Smaller vaults = faster secret loading
4. **Rotation**: Rotate production keys without affecting dev environment
5. **Billing**: Track API usage separately (OpenAI CLI experiments vs production)

---

## Service Account Setup

### Overview: Two Service Accounts

You need **two separate service accounts**, each scoped to its respective vault:

| Service Account | Vault Access | Used By | Token Location |
|----------------|--------------|---------|----------------|
| `1password.service-account.cli` | CLI vault (read-only) | .zshrc, CLI tools | `~/.zshrc` (export) |
| `1password.service-account.mcp-orchestrator` | MCP Orchestrator vault (read-only) | Docker, n8n, CI/CD | `.env` file, GitHub Secrets |

### 1. Create CLI Service Account

**For personal development tools:**

1. Go to [1Password Developer Tools → Service Accounts](https://my.1password.com/developer-tools/infrastructure-secrets/service-accounts)
2. Click **Create Service Account**
3. Name: `cli-personal-access`
4. Description: "Personal CLI tools, shell integration, development"
5. Click **Create**
6. **Copy the token immediately** (shows only once): `ops_ey...`
7. Grant vault access:
   - Vault: **CLI**
   - Permission: **Read items**
8. Click **Save**

**Store the service account token itself in 1Password (bootstrap):**

```bash
op item create --category "API Credential" \
  --vault "CLI" \
  --title "1password.service-account.cli" \
  --tags "1password,service-account,cli,bootstrap" \
  username="OP_SERVICE_ACCOUNT_TOKEN" \
  type="internal" \
  credential="ops_eyJzaWduSW5BZGRy..." \
  notesPlain="CLI vault service account. Scope: CLI vault read-only. Expires: 90 days. Used by: .zshrc, terminal, CLI tools."
```

**Add to .zshrc:**

```bash
# ~/.zshrc
# 1Password CLI Service Account (eliminates Touch ID prompts)
export OP_SERVICE_ACCOUNT_TOKEN="ops_eyJzaWduSW5BZGRy..."
```

### 2. Create MCP Orchestrator Service Account

**For production automation:**

1. Go to [1Password Service Accounts](https://my.1password.com/developer-tools/infrastructure-secrets/service-accounts)
2. Click **Create Service Account**
3. Name: `mcp-orchestrator-service-account`
4. Description: "MCP Orchestrator production: n8n, Docker, CI/CD"
5. Click **Create**
6. **Copy the token immediately**: `ops_ey...`
7. Grant vault access:
   - Vault: **MCP Orchestrator**
   - Permission: **Read items**
8. Click **Save**

**Store in 1Password (MCP Orchestrator vault):**

```bash
op item create --category "API Credential" \
  --vault "MCP Orchestrator" \
  --title "1password.service-account.mcp-orchestrator" \
  --tags "1password,service-account,mcp-orchestrator,production" \
  username="OP_SERVICE_ACCOUNT_TOKEN" \
  type="internal" \
  credential="ops_ey..." \
  notesPlain="MCP Orchestrator vault service account. Scope: MCP Orchestrator vault read-only. Used by: n8n, Docker, CI/CD, production automation."
```

**Add to project `.env`:**

```bash
# orchestrator/.env (NOT committed to git)
OP_SERVICE_ACCOUNT_TOKEN=ops_ey...
```

### Security Considerations

✅ **Use separate service accounts** for different purposes (CLI vs MCP vs CI/CD)  
✅ **Scope service accounts** to minimum vault access (read-only when possible)  
✅ **Rotate tokens quarterly** (set 90-day calendar reminder)  
✅ **Never grant write access** unless absolutely necessary  
✅ **Store service account token in 1Password** for backup/recovery

❌ **Never share service account tokens** across teams  
❌ **Never commit service account tokens** to git  
❌ **Never use personal account** for automation (use service accounts)

---

## Credential Naming Standards

### Item Title Format

**Pattern:** `{service}.{service-term}.{integration}[--differentiator]`

**Rules:**

1. All lowercase
2. Use dots (`.`) to separate hierarchy levels
3. Use hyphens (`-`) within multi-word terms
4. `{service}` = Provider name (github, notion, todoist, openai, etc.)
5. `{service-term}` = What the service calls it (personal-access-token, api-key, api-token, etc.)
6. `{integration}` = Where it's used (cli, mcp-orchestrator, homebrew, vscode, etc.)
7. Add `--differentiator` only when two items would otherwise be identical

**Why use service's official terminology?**

✅ Matches official documentation (GitHub calls it "Personal Access Token")  
✅ Clear when looking at service settings  
✅ Reduces confusion when support documentation refers to specific terms  
✅ AI/human readable - clear what each token is for without reading notes

### Examples by Vault

#### CLI Vault (Personal Development)

| Item Title | Service | Term | Integration | UUID Example |
|------------|---------|------|-------------|--------------|
| `github.personal-access-token.cli` | GitHub | Personal Access Token | CLI | ptwmp3w65ptopt2bd45bcgylyu |
| `github.personal-access-token.homebrew` | GitHub | Personal Access Token | Homebrew | (different UUID) |
| `notion.api-key.cli` | Notion | API Key | CLI | std66i4yjcvyksnyzca27232ra |
| `todoist.api-token.cli` | Todoist | API Token | CLI | iftp7qhe4zso2n27dd5a4hvvgq |
| `openai.api-key.cli` | OpenAI | API Key | CLI | **vu3qf2nd5g6yzhik4l6zt5sy7a** |
| `huggingface.access-token.cli` | HuggingFace | Access Token | CLI | 7hxgtp22fopjfk4ubjnybafj7y |

#### MCP Orchestrator Vault (Production)

| Item Title | Service | Term | Integration | Notes |
|------------|---------|------|-------------|-------|
| `openai.api-key.mcp-orchestrator` | OpenAI | API Key | MCP Orchestrator | Production key (separate from CLI) |
| `github.personal-access-token.mcp-orchestrator` | GitHub | Personal Access Token | MCP Orchestrator | Separate scopes from CLI |
| `todoist.api-token.mcp-orchestrator` | Todoist | API Token | MCP Orchestrator | Production webhook integration |
| `notion.api-key.mcp-orchestrator` | Notion | API Key | MCP Orchestrator | Production database access |

### Field Configuration

Every 1Password item should have these fields configured:

#### Username Field
- **Purpose**: Environment variable name reference
- **Format**: `UPPERCASE_SNAKE_CASE`
- **Examples**:
  - `GITHUB_TOKEN`
  - `NOTION_API_KEY`
  - `TODOIST_API_TOKEN`
  - `OPENAI_API_KEY`

**Why:** Provides clear indication of what environment variable name to use when exporting.

#### Credential Field
- **Always use this field for the actual secret**
- UUID: `credential` (for UI-created items) or custom UUID (for CLI-created items)
- **Best Practice**: Reference by label `credential` (works regardless of UUID)

#### Type Field
- `bearer` → Bearer Token authentication (most REST APIs)
- `internal` → Custom/internal authentication (1Password service accounts)
- (empty) → Not applicable

#### Notes Field

**Should document:**

```
[Brief description]

Scopes: [list of permissions/scopes]
Created: YYYY-MM-DD
Expires: YYYY-MM-DD (if applicable)
Used by: [list of integrations]
Database IDs: [for Notion integrations]
```

**Example:**

```
GitHub Personal Access Token for CLI operations via Copilot and Homebrew.

Scopes: repo, workflow, read:org, read:packages
Created: 2025-10-19
Expires: 2026-04-19
Used by: GitHub Copilot CLI, Homebrew package manager
Integration: CLI tools, git operations
```

### Service Terminology Reference

Different services use different terminology for their authentication tokens. We use their official terms to match documentation:

| Service | Official Term | Our Title Format | Why This Term? |
|---------|--------------|------------------|----------------|
| GitHub | **Personal Access Token** | `github.personal-access-token.{integration}` | GitHub's official documentation calls it "PAT" |
| Notion | **API Key** | `notion.api-key.{integration}` | Notion Settings shows "API Key" |
| Todoist | **API Token** | `todoist.api-token.{integration}` | Todoist Settings uses "API Token" |
| OpenAI | **API Key** | `openai.api-key.{integration}` | OpenAI Platform calls it "API Key" |
| HuggingFace | **Access Token** | `huggingface.access-token.{integration}` | HF Settings labels it "Access Token" |
| 1Password | **Service Account** | `1password.service-account.{integration}` | 1Password Developer Docs use "Service Account" |

**Note:** Technically they're all just authentication strings, but using the service's official terminology makes it clearer when referencing their documentation or settings pages.

---

## Field Structure & UUID Behavior

### Understanding Field IDs

Every 1Password item has fields with:
- **Label** (human-readable): `credential`, `username`, `type`, etc.
- **ID** (UUID): Programmatic identifier

**Standard Fields** (created by 1Password UI):

```bash
credential → UUID: "credential"
username → UUID: "username"
type → UUID: "type"
notesPlain → UUID: "notesPlain"
password → UUID: "password"
```

**Custom Fields** (created manually or via CLI):

```bash
token → UUID: nssd6mcjhbwuratlyvudt4s2fi (random)
custom_field → UUID: abc123xyz... (random)
```

### The Magic of Label Resolution ⭐

**Critical Discovery:** 1Password CLI resolves labels **regardless of UUID type!**

```bash
# Example: Todoist item has custom UUID for credential field
op item get "todoist.api-token.cli" --format json | jq -r '.fields[] | "\(.label): \(.id)"'

# Output:
# username: username
# type: type
# credential: nssd6mcjhbwuratlyvudt4s2fi  ← Custom UUID!

# But this still works! 🎉
op read "op://CLI/todoist.api-token.cli/credential"
# → Returns token successfully
```

**Implication:**

✅ **Always use field labels** (`/credential`, `/username`)  
❌ **Never hardcode custom UUIDs** (`/nssd6mcjhbwuratly...`)  
✅ **Works even if field has custom UUID**

### Field UUID Behavior: Standard vs Custom

#### Standard Fields (Stable UUIDs)

1Password assigns stable, predictable UUIDs to default fields:

| Item Type | Default Secret Field | Field ID |
|-----------|---------------------|----------|
| API Credential | `credential` | `credential` |
| Password | `password` | `password` |
| Login | `password` | `password` |
| Database | `password` | `password` |

**Other default fields:**

| Field Name | Field ID | Notes |
|------------|----------|-------|
| `username` | `username` | Default for Login/API Credential |
| `notesPlain` | `notesPlain` | Always stable |
| `type` | `type` | For API Credential bearer/internal |
| `validFrom` | `validFrom` | Date field |
| `expires` | `expires` | Date field |

**Key insight:** Default fields created by 1Password (via UI or CLI) **always** get the same UUID = field name.

#### Custom Fields (Random UUIDs)

When you add a custom field, 1Password generates a random UUID:

```bash
# Todoist SDK expects field named "token" (not "credential")
# 1Password generates random UUID for this custom field

Field: token
UUID: mpg3mqh5utml6vhq2xhlbhxyfq  # Random, unique to this item

# GitHub CLI expects field named "personal_access_token"
Field: personal_access_token
UUID: xllolzxte5yrxubm3drcyzutuu  # Random, unique to this item
```

**Rule:** Even custom fields work with label resolution! Use `/token`, not `/mpg3mqh5utml6vhq2xhlbhxyfq`.

### Adding `credential` Field to Existing Items

**Critical Discovery:** If you create an item with custom fields first, then add the `credential` field later, it **still gets the stable UUID** `"credential"`!

```bash
# Test case: Item created with only custom 'token' field
op item create --category "API Credential" --title "test" token="value"

# Initially has:
{
  "label": "credential",
  "id": "credential"  # ← Auto-created, stable UUID!
}

# Adding credential value later:
op item edit "test" credential="secret"

# Still has stable UUID:
{
  "label": "credential",
  "id": "credential"  # ← Still stable UUID "credential"!
}
```

**Conclusion:** Default fields maintain their stable UUIDs regardless of:

- ✅ Creation order (custom fields first, default fields later)
- ✅ Creation method (UI vs CLI)
- ✅ When values are populated

**Always use field labels** for stability and readability.

### When to Use Field Labels (Always!)

| Scenario | Reference Format | Example |
|----------|-----------------|---------|
| Default `credential` field | Use label | `op://.../item-id/credential` |
| Default `password` field | Use label | `op://.../item-id/password` |
| Default `username` field | Use label | `op://.../item-id/username` |
| Custom field (e.g., `token`) | Use label | `op://.../item-id/token` |

**Never use UUIDs directly**—always use field labels for maximum stability.

---

## CLI Integration (Personal Development)

### Performance-Optimized Configuration

**Goal:** Load all secrets in ~2 seconds (vs 12 seconds sequential)

**Method:** Parallel background loading with temp files

### Complete .zshrc Configuration

```bash
# =============================================================================
# History Security Settings
# =============================================================================
setopt HIST_IGNORE_SPACE  # Commands with leading space not saved to history

# =============================================================================
# 1Password CLI Service Account
# =============================================================================
# Service Account: 1password.service-account.cli
# Vault: CLI (read-only)
# Purpose: Eliminates Touch ID prompts for CLI tools
export OP_SERVICE_ACCOUNT_TOKEN="ops_eyJzaWduSW5BZGRy..."

# =============================================================================
# Load Secrets in PARALLEL (6x faster: 2s vs 12s)
# =============================================================================
_OP_TEMP_DIR=$(mktemp -d)

# Start all reads simultaneously in background (&)
op read "op://CLI/github.personal-access-token.cli/credential" > "$_OP_TEMP_DIR/github" 2>/dev/null &
op read "op://CLI/notion.api-key.cli/credential" > "$_OP_TEMP_DIR/notion" 2>/dev/null &
op read "op://CLI/todoist.api-token.cli/credential" > "$_OP_TEMP_DIR/todoist" 2>/dev/null &
op read "op://CLI/openai.api-key.cli/credential" > "$_OP_TEMP_DIR/openai" 2>/dev/null &
op read "op://CLI/huggingface.access-token.cli/credential" > "$_OP_TEMP_DIR/huggingface" 2>/dev/null &
op read "op://CLI/github.personal-access-token.homebrew/credential" > "$_OP_TEMP_DIR/homebrew" 2>/dev/null &

# Wait for all to complete (blocks until slowest finishes)
wait

# Export from temp files to environment
export GITHUB_TOKEN=$(cat "$_OP_TEMP_DIR/github" 2>/dev/null)
export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN"
export NOTION_API_KEY=$(cat "$_OP_TEMP_DIR/notion" 2>/dev/null)
export TODOIST_API_TOKEN=$(cat "$_OP_TEMP_DIR/todoist" 2>/dev/null)
export OPENAI_API_KEY=$(cat "$_OP_TEMP_DIR/openai" 2>/dev/null)
export HUGGINGFACE_TOKEN=$(cat "$_OP_TEMP_DIR/huggingface" 2>/dev/null)
export HOMEBREW_GITHUB_API_TOKEN=$(cat "$_OP_TEMP_DIR/homebrew" 2>/dev/null)

# Cleanup
rm -rf "$_OP_TEMP_DIR"
unset _OP_TEMP_DIR

# =============================================================================
# Utility Alias
# =============================================================================
alias check-secrets='echo "🔐 Loaded Secrets:" && \
  echo "  GitHub:      ${GITHUB_TOKEN:0:10}..." && \
  echo "  Notion:      ${NOTION_API_KEY:0:10}..." && \
  echo "  Todoist:     ${TODOIST_API_TOKEN:0:10}..." && \
  echo "  OpenAI:      ${OPENAI_API_KEY:0:10}..." && \
  echo "  HuggingFace: ${HUGGINGFACE_TOKEN:0:10}..." && \
  echo "  Homebrew:    ${HOMEBREW_GITHUB_API_TOKEN:0:10}..."'
```

### Performance Comparison

| Method | Load Time | Complexity | Touch ID Prompts |
|--------|-----------|------------|------------------|
| Sequential `op read` | ~12 seconds | Low | Yes (if no service account) |
| **Parallel `op read` (recommended)** | **~2 seconds** | Medium | **No (with service account)** |
| `op inject` | ~8 seconds | Medium | Yes (if no service account) |
| Shell plugins | Variable (slow) | High (invasive) | Yes |

**Why parallel is fastest:**

- All secrets fetched simultaneously
- Only wait for slowest (not sum of all)
- Service account = no Touch ID latency
- Temp files = no subshell overhead

### Understanding Startup Output

```bash
Last login: Sun Oct 19 14:31:13 on ttys123
[1] 64159   # Job 1 (GitHub), PID 64159
[2] 64160   # Job 2 (Notion), PID 64160
[3] 64161   # Job 3 (Todoist), PID 64161
[4] 64162   # Job 4 (OpenAI), PID 64162
[5] 64163   # Job 5 (HuggingFace), PID 64163
[6] 64164   # Job 6 (Homebrew), PID 64164

[4]    done       op read ...  # Job 4 finished successfully
[5]  - done       op read ...  # Job 5 finished (- = current job marker)
[3]  - done       op read ...  # Job 3 finished
[1]    done       op read ...  # Job 1 finished
[2]  - done       op read ...  # Job 2 finished
[6]  + done       op read ...  # Job 6 finished (+ = most recent)
```

**Status codes:**

- `done` → Exit code 0 (success)
- `exit 1` → Failed (wrong UUID, permission denied, etc.)

**Job markers:**

- `-` → Current job
- `+` → Most recently completed job
- (none) → Older completed job

### Avoiding Shell Plugins

**1Password provides shell plugins, but don't use them:**

```bash
# ~/.config/op/plugins.sh
alias brew="op plugin run -- brew"    # ❌ Don't use
alias aws="op plugin run -- aws"      # ❌ Don't use
```

**Problems:**

1. Adds latency to every command
2. Unexpected prompts for credential structure
3. Forces specific field names (e.g., `token` instead of `credential`)
4. Less transparent than environment variables

**Better approach:** Export environment variables in `.zshrc`, disable plugins:

```bash
# ~/.config/op/plugins.sh
# alias brew="op plugin run -- brew"  # Disabled: Using HOMEBREW_GITHUB_API_TOKEN instead
```

---

## MCP Orchestrator Integration (Production)

### Environment Configuration

**File: `orchestrator/.env`** (NOT committed to git)

```bash
# =============================================================================
# 1Password Service Account (REQUIRED - Bootstrap Secret)
# =============================================================================
# Service Account: 1password.service-account.mcp-orchestrator
# Vault: MCP Orchestrator (read-only)
# Purpose: Production automation (n8n, Docker, CI/CD)
# NOTE: This is SEPARATE from CLI service account (different vault access)
OP_SERVICE_ACCOUNT_TOKEN=ops_eyJzaWduSW5BZGRy...

# =============================================================================
# Notion API
# =============================================================================
# 1Password item: notion.api-key.mcp-orchestrator (in MCP Orchestrator vault)
NOTION_API_KEY=op://MCP Orchestrator/notion.api-key.mcp-orchestrator/credential
NOTION_TASKS_DATABASE_ID=
NOTION_RESEARCH_DATABASE_ID=

# =============================================================================
# Todoist API
# =============================================================================
# 1Password item: todoist.api-token.mcp-orchestrator (in MCP Orchestrator vault)
TODOIST_API_TOKEN=op://MCP Orchestrator/todoist.api-token.mcp-orchestrator/credential
TODOIST_WEBHOOK_SECRET=

# =============================================================================
# GitHub
# =============================================================================
# 1Password item: github.personal-access-token.mcp-orchestrator (in MCP Orchestrator vault)
GITHUB_PAT=op://MCP Orchestrator/github.personal-access-token.mcp-orchestrator/credential

# =============================================================================
# OpenAI API (for AI auto-tagging)
# =============================================================================
# 1Password item: openai.api-key.mcp-orchestrator (in MCP Orchestrator vault)
# NOTE: This is SEPARATE from openai.api-key.cli (personal CLI use)
OPENAI_API_KEY=op://MCP Orchestrator/openai.api-key.mcp-orchestrator/credential

# =============================================================================
# Orchestrator Settings
# =============================================================================
NODE_ENV=production
LOG_LEVEL=info
PORT=3000
```

### Docker Compose Integration

**File: `orchestrator/docker-compose.yml`**

```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      # Service account token passed from host
      - OP_SERVICE_ACCOUNT_TOKEN=${OP_SERVICE_ACCOUNT_TOKEN}
    env_file:
      - .env
    command: /bin/sh -c "op run --env-file=.env -- n8n start"
    volumes:
      - n8n_data:/home/node/.n8n
    restart: unless-stopped

volumes:
  n8n_data:
```

**Start:**

```bash
# Set MCP Orchestrator service account token
export OP_SERVICE_ACCOUNT_TOKEN="ops_ey..."  # From 1password.service-account.mcp-orchestrator

# Start services (secrets injected at runtime via op run)
docker-compose up -d

# Verify secrets loaded
docker-compose logs n8n | grep "Starting n8n"
```

**Benefits:**

- ✅ Secrets never in Docker environment (resolved at runtime)
- ✅ Update 1Password → restart container → new secrets loaded
- ✅ No secrets in git (`.env` has references only)
- ✅ Service account scoped to MCP Orchestrator vault only

---

## n8n Integration

### n8n Cloud (Recommended for this project)

**Note:** 1Password Service Account integration not natively supported in n8n Cloud.

**Setup:**

1. Navigate to: **Settings → Credentials → Add Credential**
2. Select type: "Notion API", "Todoist API", "OpenAI API"
3. Manually copy-paste from 1Password (MCP Orchestrator vault)
4. Name credential to match 1Password item:
   - `NOTION_API_KEY` → Paste from `notion.api-key.mcp-orchestrator`
   - `TODOIST_API_TOKEN` → Paste from `todoist.api-token.mcp-orchestrator`
   - `OPENAI_API_KEY` → Paste from `openai.api-key.mcp-orchestrator`

**Rotation workflow:**

1. Generate new token in service provider
2. Update in 1Password (MCP Orchestrator vault)
3. Update in n8n Credentials panel
4. Test affected workflows
5. Revoke old token

### n8n Self-Hosted

Use `op run` for automatic secret injection (see [MCP Orchestrator Integration](#mcp-orchestrator-integration-production) section above).

---

## GitHub Copilot MCP Integration

### Current Status: GitHub Copilot CLI

**You are currently using:** GitHub Copilot CLI directly in iTerm2.

**Access method:**

- Command: `copilot` in iTerm2
- Secrets loaded: Via `.zshrc` environment variables (CLI vault)
- MCP servers: GitHub MCP (built-in)

### Future: Connecting Copilot CLI to Your MCP Orchestrator

**Goal:** Give GitHub Copilot CLI access to Notion/Todoist via your MCP Orchestrator.

**Current state:**

- ❌ GitHub Copilot CLI doesn't natively support custom MCP servers
- ✅ Your orchestrator has MCP servers (Notion, Todoist, etc.)
- ❌ No direct bridge between Copilot CLI and your orchestrator

**Potential solutions:**

#### Option A: Use orchestrator for data, Copilot for code

```bash
# Manually fetch data from orchestrator
curl http://localhost:3000/api/notion/tasks

# Use Copilot for code generation/analysis
copilot "analyze this JSON and suggest..."
```

#### Option B: Custom CLI wrapper (future)

```bash
# Wrapper script that calls orchestrator APIs
copilot-mcp "search notion for tasks"
# → Calls orchestrator API → Returns results → Passes to Copilot
```

#### Option C: Claude Desktop as MCP hub

```bash
# Install Notion MCP in Claude Desktop
npm install -g @makenotion/notion-mcp-server

# Configure Claude Desktop config
# ~/.config/claude/config.json or Claude Desktop settings
```

**Note:** For now, your best integration is:

1. GitHub Copilot CLI for code/git/general AI tasks (current setup ✅)
2. Notion AI or Raycast for Notion-specific queries
3. Future: REST API bridge between Copilot CLI and your orchestrator

### MCP Server Configuration (for Claude Desktop)

**If using Claude Desktop:**

```json
// ~/Library/Application Support/Claude/claude_desktop_config.json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@makenotion/notion-mcp-server"],
      "env": {
        "NOTION_API_KEY": "op://CLI/notion.api-key.cli/credential"
      }
    }
  }
}
```

**Launch Claude Desktop with 1Password:**

```bash
# Set CLI service account
export OP_SERVICE_ACCOUNT_TOKEN="ops_ey..."  # From CLI vault

# Launch Claude with op run (injects secrets)
op run -- "/Applications/Claude.app/Contents/MacOS/Claude"
```

---

## GitHub Actions (CI/CD)

### 1. Add Service Account Token to GitHub Secrets

1. Go to repository settings: **Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Name: `OP_SERVICE_ACCOUNT_TOKEN`
4. Value: Your **MCP Orchestrator** Service Account token
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
          # MCP Orchestrator vault secrets
          NOTION_API_KEY: op://MCP Orchestrator/notion.api-key.mcp-orchestrator/credential
          TODOIST_API_TOKEN: op://MCP Orchestrator/todoist.api-token.mcp-orchestrator/credential
          OPENAI_API_KEY: op://MCP Orchestrator/openai.api-key.mcp-orchestrator/credential

      - name: Run integration tests
        run: npm run test:integration
        # Tests can access $NOTION_API_KEY, $TODOIST_API_TOKEN, $OPENAI_API_KEY from environment
```

### Benefits

✅ Secrets never stored in GitHub (only Service Account token)  
✅ Rotate API keys in 1Password, CI/CD picks up automatically  
✅ Audit trail in 1Password shows GitHub Actions access  
✅ Works across multiple repositories (share Service Account)  
✅ Separate from CLI development secrets

---

## Best Practices

### Security

✅ **Use separate service accounts** for different purposes (CLI vs MCP vs CI/CD)  
✅ **Scope service accounts** to minimum vault access (read-only when possible)  
✅ **Rotate tokens quarterly** (set 90-day calendar reminder)  
✅ **Use parallel loading** for performance without sacrificing security  
✅ **Enable history security** (`setopt HIST_IGNORE_SPACE` in .zshrc)  
✅ **Never log secrets** in application output or CI/CD logs  
✅ **Audit access logs** monthly (1Password → Activity)

❌ **Never commit `.env`** with plaintext secrets (use `op://` references only)  
❌ **Never grant write access** unless absolutely necessary  
❌ **Never share service account tokens** across teams  
❌ **Never use personal account** for automation (use service accounts)

### Vault Organization

**Recommended structure:**

```
Personal/                          → Personal accounts, passwords
├── Banking, social media, etc.

Clinic/                            → Work-related credentials
├── EMR, practice management, etc.

CLI/                               → Personal development tools
├── Service Account: 1password.service-account.cli
├── github.personal-access-token.cli
├── github.personal-access-token.homebrew
├── notion.api-key.cli
├── todoist.api-token.cli
├── openai.api-key.cli (UUID: vu3qf2nd5g6yzhik4l6zt5sy7a)
└── huggingface.access-token.cli

MCP Orchestrator/                  → Production automation
├── Service Account: 1password.service-account.mcp-orchestrator
├── notion.api-key.mcp-orchestrator
├── todoist.api-token.mcp-orchestrator
├── github.personal-access-token.mcp-orchestrator
└── openai.api-key.mcp-orchestrator
```

**Benefits:**

- Clear separation of concerns
- Easier to audit
- Reduced blast radius
- Service accounts scoped to specific vaults

### Naming Standards

✅ **Item titles:** All lowercase, dot-separated (`service.type.integration`)  
✅ **Username field:** Uppercase environment variable name (`NOTION_API_KEY`)  
✅ **Type field:** `bearer` or `internal` (lowercase)  
✅ **Notes:** Structured documentation (scopes, dates, usage)  
✅ **Field references:** Use labels (`/credential`), not custom UUIDs

❌ **Avoid:** Mixed case, underscores in titles, vague names  
❌ **Avoid:** Tracking custom field UUIDs (use labels instead)

### Secret References

**Always use full reference syntax:**

```
op://VAULT/ITEM/FIELD
op://CLI/github.personal-access-token.cli/credential
└─┬──┘ └──────────┬──────────┘ └────┬────┘
  │              │                   │
Vault         Item                 Field
(name)        (title)              (label)
```

**Best practice:**

- Vault: Use name (readable, stable)
- Item: Use title (readable, descriptive)
- Field: **Always use label** (`credential`, `username`, etc.)

### History Security

**Prevent secrets in shell history:**

```bash
# In .zshrc
setopt HIST_IGNORE_SPACE

# Usage
 echo $GITHUB_TOKEN    # ← Leading space = not saved
echo "safe command"    # ← No space = saved

# Verify
history | grep TOKEN   # Should return nothing
```

**Clean exposed secrets:**

```bash
# 1. Clear iTerm2 scrollback
Cmd+K

# 2. Remove from history file
sed -i.bak '/secret_string/d' ~/.zsh_history

# 3. Verify
grep -n 'secret_string' ~/.zsh_history  # Should return nothing

# 4. Rotate secret in service provider + 1Password
```

### Rotation Workflow

**Quarterly token rotation (recommended):**

1. **Week before expiry:**
   - Calendar reminder triggers
   - Review current token scopes/permissions

2. **Generate new token:**
   - Service provider → Settings → Generate new
   - Copy to clipboard (don't save yet)

3. **Update 1Password:**
   ```bash
   # CLI method
   op item edit "github.personal-access-token.cli" \
     --vault CLI \
     credential="ghp_NEW_TOKEN"
   
   # Or via 1Password app UI
   ```

4. **Test:**
   ```bash
   # For CLI vault: Reload shell
   exec zsh
   
   # Verify new token loaded
   check-secrets
   
   # Test functionality
   gh auth status  # GitHub CLI
   
   # For MCP Orchestrator vault: Restart services
   docker-compose restart
   ```

5. **Revoke old token:**
   - Service provider → Revoke previous token
   - Add note in 1Password: "Rotated YYYY-MM-DD"

**No code changes needed!** All integrations read from 1Password at runtime.

---

## Troubleshooting

### Slow Shell Startup (>5 seconds)

**Symptoms:**

- Shell takes 10-12 seconds to load
- Multiple `op read` commands running sequentially

**Diagnosis:**

```bash
# Time shell startup
time zsh -i -c exit
# Should be ~2 seconds; if >5s, check .zshrc
```

**Fix:**

Ensure using **parallel loading** (not sequential):

```bash
# ❌ SLOW (sequential)
export GITHUB_TOKEN=$(op read "op://CLI/github.personal-access-token.cli/credential")
export NOTION_API_KEY=$(op read "op://CLI/notion.api-key.cli/credential")
# ... (12 seconds total)

# ✅ FAST (parallel)
op read "op://CLI/github.personal-access-token.cli/credential" > "$_OP_TEMP_DIR/github" &
op read "op://CLI/notion.api-key.cli/credential" > "$_OP_TEMP_DIR/notion" &
wait  # (2 seconds total)
```

---

### Secret Not Loading (exit 1 during startup)

**Symptoms:**

```bash
[3]  - exit 1     op read  > "$_OP_TEMP_DIR/todoist" 2>/dev/null
```

**Diagnosis:**

```bash
# Run failing command manually (with leading space to avoid history)
 op read "op://CLI/todoist.api-token.cli/credential"

# Common errors:
# "item not found" → Wrong item title or vault name
# "field not found" → Field name typo
# "unauthorized" → Service account lacks vault access
```

**Fix:**

```bash
# Verify vault exists
op vault list | grep CLI

# Verify item exists
op item list --vault CLI | grep todoist

# Check item structure
op item get "todoist.api-token.cli" --vault CLI --format json | jq -r '.fields[] | "\(.label): \(.id)"'

# Update .zshrc with correct vault/item/field names
```

---

### Plugin Prompt During Command

**Symptoms:**

```bash
brew install something
# → 1Password prompt: "Select field to rename to 'token'"
```

**Cause:** 1Password shell plugin trying to auto-configure.

**Fix:**

```bash
# 1. Disable plugin in ~/.config/op/plugins.sh
# alias brew="op plugin run -- brew"  # Comment this out

# 2. Use environment variable instead (already in .zshrc)
export HOMEBREW_GITHUB_API_TOKEN=$(cat "$_OP_TEMP_DIR/homebrew")

# 3. Reload shell
exec zsh

# 4. Test
brew --version  # Should not prompt
```

---

### Missing Environment Variables

**Symptoms:**

```bash
check-secrets
# GitHub:      ghp_abc...
# Notion:      ...  ← Empty!
```

**Diagnosis:**

```bash
# Check if secret loads manually
 op read "op://CLI/notion.api-key.cli/credential"

# Check environment
 echo $NOTION_API_KEY | wc -c  # Should be ~40-50 characters
```

**Common causes:**

1. Wrong vault name in reference
2. Wrong item title in reference
3. Typo in field name (`credentials` vs `credential`)
4. Service account doesn't have vault access
5. Item doesn't exist

**Fix:**

```bash
# Verify item exists
op item get "notion.api-key.cli" --vault CLI

# Check service account vault access
# → Go to 1Password web → Service Accounts → Check vaults

# Update .zshrc with correct reference
```

---

### 1Password CLI Not Found

**Symptoms:**

```bash
zsh: command not found: op
```

**Fix:**

```bash
# Install 1Password CLI
brew install --cask 1password-cli

# Verify
op --version
```

---

### Touch ID Prompts (Despite Service Account)

**Symptoms:**

- Touch ID prompt appears on shell startup
- Service account token set but not working

**Diagnosis:**

```bash
# Check if service account token set
 echo $OP_SERVICE_ACCOUNT_TOKEN | head -c 20

# Should output: ops_eyJzaWduSW5BZGRy...
```

**Fix:**

```bash
# Add to ~/.zshrc (if not already)
export OP_SERVICE_ACCOUNT_TOKEN="ops_eyJz..."

# Reload shell
exec zsh

# Should load without Touch ID prompt
```

---

### Service Account Permission Denied

**Symptoms:**

```bash
op read "op://CLI/github.personal-access-token.cli/credential"
# Error: unauthorized
```

**Fix:**

1. Go to [1Password Service Accounts](https://my.1password.com/developer-tools/infrastructure-secrets/service-accounts)
2. Select your service account (e.g., `cli-personal-access`)
3. Click **Vaults**
4. Ensure **CLI** vault has **Read** permission
5. Click **Save**
6. Reload shell: `exec zsh`

---

### Field Structure Mismatch

**Symptoms:**

```bash
op read "op://CLI/todoist.api-token.cli/token"
# Error: field not found
```

**Diagnosis:**

```bash
# Check actual field structure
op item get "todoist.api-token.cli" --vault CLI --format json | jq -r '.fields[] | "\(.label): \(.id)"'

# Output:
# username: username
# type: type
# credential: credential  ← Use "credential", not "token"
```

**Fix:**

```bash
# Use correct field label
op read "op://CLI/todoist.api-token.cli/credential"  # ✅ Correct
```

**Note:** Always use field **label** (not UUID) for stability.

---

### Wrong Vault for Production Secrets

**Symptoms:**

- n8n/Docker can't access secrets
- Secrets work in CLI but not in production

**Cause:** Using CLI vault secrets instead of MCP Orchestrator vault.

**Fix:**

```bash
# Check .env file references
cat orchestrator/.env | grep "op://"

# Should reference MCP Orchestrator vault:
NOTION_API_KEY=op://MCP Orchestrator/notion.api-key.mcp-orchestrator/credential

# NOT:
NOTION_API_KEY=op://CLI/notion.api-key.cli/credential  # ❌ Wrong vault!

# Ensure MCP Orchestrator service account set
echo $OP_SERVICE_ACCOUNT_TOKEN  # Should be MCP service account, not CLI
```

---

## References

### Official Documentation

- [1Password CLI Reference](https://developer.1password.com/docs/cli/)
- [Service Accounts Guide](https://developer.1password.com/docs/service-accounts/)
- [Secret References](https://developer.1password.com/docs/cli/secret-references/)
- [Shell Plugins](https://developer.1password.com/docs/cli/shell-plugins/)
- [GitHub Actions Integration](https://developer.1password.com/docs/ci-cd/github-actions/)

### Project-Specific Docs

- Repository: [mcp-orchestrator-one-truth-repository](https://github.com/Kingy2709/mcp-orchestrator-one-truth-repository)
- Setup Guide: [/docs/setup/README.md](/docs/setup/README.md)
- OpenAI Setup: [/docs/setup/openai.md](/docs/setup/openai.md)
- n8n Setup: [/docs/setup/n8n.md](/docs/setup/n8n.md)
- Notion Integration: [/docs/integrations/NOTION-INTEGRATION.md](/docs/integrations/NOTION-INTEGRATION.md)

### Quick Reference Commands

```bash
# List vaults
op vault list

# List items in vault
op item list --vault CLI
op item list --vault "MCP Orchestrator"

# Get item details (with field UUIDs)
op item get "github.personal-access-token.cli" --vault CLI --format json | jq

# Read secret
op read "op://CLI/github.personal-access-token.cli/credential"

# Create new item
op item create --category="API Credential" \
  --vault="CLI" \
  --title="service.api-key.integration" \
  credential="secret_here"

# Edit item
op item edit "github.personal-access-token.cli" \
  --vault CLI \
  credential="new_token_here"

# Check loaded secrets (CLI)
check-secrets

# Performance test
time zsh -i -c exit  # Should be ~2 seconds
```

---

## Appendix: Complete Example Setup

### CLI Vault Items

```
CLI Vault (Personal Development)
├── 1password.service-account.cli
│   ├── credential: ops_eyJz...
│   ├── username: OP_SERVICE_ACCOUNT_TOKEN
│   ├── type: internal
│   └── notes: CLI vault service account. Scope: CLI vault read-only. Expires: 90 days.
│
├── github.personal-access-token.cli
│   ├── credential: ghp_abc123...
│   ├── username: GITHUB_TOKEN
│   ├── type: bearer
│   └── notes: GitHub PAT for Copilot CLI. Scopes: repo, workflow, read:org.
│
├── github.personal-access-token.homebrew
│   ├── credential: ghp_xyz789...
│   ├── username: HOMEBREW_GITHUB_API_TOKEN
│   ├── type: bearer
│   └── notes: GitHub PAT for Homebrew. Scopes: public_repo.
│
├── notion.api-key.cli
│   ├── credential: ntn_543491...
│   ├── username: NOTION_API_KEY
│   ├── type: bearer
│   └── notes: Notion integration for CLI. Access: Tasks DB, Research DB.
│
├── todoist.api-token.cli
│   ├── credential: ac2617a0f2...
│   ├── username: TODOIST_API_TOKEN
│   ├── type: bearer
│   └── notes: Todoist API token for CLI automation.
│
├── openai.api-key.cli
│   ├── credential: sk-proj-Kz...
│   ├── username: OPENAI_API_KEY
│   ├── type: bearer
│   ├── UUID: vu3qf2nd5g6yzhik4l6zt5sy7a
│   └── notes: OpenAI personal API key for CLI tools. Balance: $10 prepaid.
│
└── huggingface.access-token.cli
    ├── credential: hf_FeSLjUo...
    ├── username: HUGGINGFACE_TOKEN
    ├── type: bearer
    └── notes: HuggingFace access token for model downloads.
```

### MCP Orchestrator Vault Items

```
MCP Orchestrator Vault (Production Automation)
├── 1password.service-account.mcp-orchestrator
│   ├── credential: ops_ey...
│   ├── username: OP_SERVICE_ACCOUNT_TOKEN
│   ├── type: internal
│   └── notes: MCP Orchestrator vault service account. Scope: MCP Orchestrator vault read-only.
│
├── openai.api-key.mcp-orchestrator
│   ├── credential: sk-proj-...
│   ├── username: OPENAI_API_KEY
│   ├── type: bearer
│   └── notes: OpenAI API key for MCP Orchestrator AI features. Models: GPT-4 or GPT-4o-mini.
│
├── github.personal-access-token.mcp-orchestrator
│   ├── credential: ghp_...
│   ├── username: GITHUB_TOKEN
│   ├── type: bearer
│   └── notes: GitHub PAT for production automation. Scopes: repo, workflow.
│
├── todoist.api-token.mcp-orchestrator
│   ├── credential: ...
│   ├── username: TODOIST_API_TOKEN
│   ├── type: bearer
│   └── notes: Todoist API token for production webhook integration.
│
└── notion.api-key.mcp-orchestrator
    ├── credential: ntn_...
    ├── username: NOTION_API_KEY
    ├── type: bearer
    └── notes: Notion integration for production database access.
```

### .zshrc Configuration (CLI)

```bash
# 1Password CLI Service Account
export OP_SERVICE_ACCOUNT_TOKEN="ops_eyJz..."

# Parallel secret loading (see CLI Integration section)
_OP_TEMP_DIR=$(mktemp -d)
op read "op://CLI/github.personal-access-token.cli/credential" > "$_OP_TEMP_DIR/github" &
# ... (other secrets)
wait
export GITHUB_TOKEN=$(cat "$_OP_TEMP_DIR/github")
# ... (other exports)
rm -rf "$_OP_TEMP_DIR"
```

### .env Configuration (MCP Orchestrator)

```bash
# MCP Orchestrator service account
OP_SERVICE_ACCOUNT_TOKEN=ops_ey...

# Production secrets (MCP Orchestrator vault)
NOTION_API_KEY=op://MCP Orchestrator/notion.api-key.mcp-orchestrator/credential
TODOIST_API_TOKEN=op://MCP Orchestrator/todoist.api-token.mcp-orchestrator/credential
GITHUB_PAT=op://MCP Orchestrator/github.personal-access-token.mcp-orchestrator/credential
OPENAI_API_KEY=op://MCP Orchestrator/openai.api-key.mcp-orchestrator/credential
```

### Performance Metrics

| Metric | Value | Notes |
|--------|-------|-------|
| **Shell startup (parallel)** | ~2 seconds | 6 parallel secret loads |
| **Shell startup (sequential)** | ~12 seconds | Baseline comparison |
| **Speedup** | 6x faster | Parallel vs sequential |
| **Touch ID prompts (CLI)** | 0 | Service account enabled |
| **Touch ID prompts (MCP)** | 0 | Service account enabled |
| **Secrets ready** | Immediately | On shell start or container launch |

---

**Document Version:** 2.0 (Merged SSOT)  
**Last Updated:** October 22, 2025  
**Performance:** ✅ Optimized | 2s startup | Parallel loading | Zero Touch ID prompts | Two-vault architecture
