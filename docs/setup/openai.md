# OpenAI API Setup

> Complete guide for OpenAI API integration with n8n workflows, CLI tools, and 1Password secret management.

## Table of Contents

1. [Overview](#overview)
2. [Account Types](#account-types)
3. [Setup Guide](#setup-guide)
4. [Usage Estimates](#usage-estimates)
5. [Storing in 1Password](#storing-in-1password)
6. [Integration](#integration)
7. [Alternatives](#alternatives)
8. [Troubleshooting](#troubleshooting)

---

## Overview

**OpenAI API provides:**

- ✅ **AI Auto-Tagging**: Analyze tasks → generate @work/@personal/@urgent tags
- ✅ **n8n Integration**: OpenAI node built-in (no custom code)
- ✅ **Multiple Models**: GPT-4o, GPT-4o-mini, GPT-3.5-turbo
- ✅ **Pay-as-you-go**: Only pay for what you use

**Your Current Setup:**

- Account: Personal (free tier, prepaid credit)
- Balance: $10 with auto-top-up when < $5
- **Two separate API keys**:
  - **CLI Vault**: `openai.api-key.cli` (UUID: `vu3qf2nd5g6yzhik4l6zt5sy7a`) - Personal development
  - **MCP Orchestrator Vault**: `openai.api-key.mcp-orchestrator` - Production automation

---

## Account Types

### Free Personal Account

**What you have:**

- ✅ ChatGPT web/mobile access (free tier)
- ❌ **No API access by default**
- ⚠️ **Need prepaid credit** to unlock API

**To unlock API:**

1. Go to [OpenAI Settings → Billing](https://platform.openai.com/settings/organization/billing)
2. Add payment method
3. Add prepaid credit (minimum $5, you added $10 ✅)
4. Generate API key at [API Keys](https://platform.openai.com/api-keys)

**Your setup:** ✅ $10 prepaid with auto-top-up at $5

### Service Account (Not Applicable)

**What it is:**

- Organization-level API keys (like 1Password service accounts)
- Owned by project/org, not personal account
- Best for team automation, production apps

**When to use:**

- ❌ **Not for personal use** (you don't have org account)
- ✅ **Only if you create OpenAI organization**
- ✅ **For team projects with multiple developers**

**Your situation:** Personal account is correct ✅

---

## Setup Guide

### Step 1: Add Prepaid Credit (Done ✅)

You've already completed this:

- ✅ Added $10 prepaid credit
- ✅ Set auto-top-up when balance < $5
- ✅ Payment method stored

**To modify:**

1. [OpenAI Billing](https://platform.openai.com/settings/organization/billing/overview)
2. Adjust auto-recharge settings if needed

### Step 2: Create API Key

**If you haven't already:**

1. Go to [API Keys](https://platform.openai.com/api-keys)
2. Click **+ Create new secret key**
3. Select **Owned by: You** (not Service account)
4. Optional: Name it "MCP Orchestrator CLI" or similar
5. Optional: Set project to "Default project"
6. Click **Create secret key**
7. **Copy immediately** (shows only once): `sk-proj-...`

**Your key:** Already created with UUID `vu3qf2nd5g6yzhik4l6zt5sy7a` ✅

### Step 3: Store in 1Password

See [Storing in 1Password](#storing-in-1password) section below.

### Step 4: Configure Integration

See [Integration](#integration) section for n8n, CLI, and MCP setup.

---

## Usage Estimates

### Pricing (October 2025)

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Best For |
|-------|----------------------|------------------------|----------|
| **GPT-4o-mini** | $0.150 | $0.600 | ✅ **Task tagging** (fast, cheap) |
| GPT-4o | $2.50 | $10.00 | Complex reasoning |
| GPT-3.5-turbo | $0.50 | $1.50 | Legacy (use 4o-mini instead) |

**Token estimates:**

- Average task: ~100-200 tokens input, ~50 tokens output
- Tag generation: ~150 tokens total per task

### Monthly Cost Estimate (Your Use Case)

**Scenario: AI auto-tagging for ADHD quick capture**

| Activity | Daily | Monthly | Tokens | Cost/Month |
|----------|-------|---------|--------|------------|
| Tasks created | 10-15 | 300-450 | ~67,500 | **~$0.05** |
| AI confidence checks | 5-10 | 150-300 | ~45,000 | **~$0.03** |
| Research summaries | 1-2 | 30-60 | ~180,000 | **~$0.15** |
| **Total** | **~20** | **~600** | **~292,500** | **~$0.23/mo** |

**With GPT-4o-mini (recommended):** ~$0.20-0.30/month

**Your $10 prepaid lasts:** ~30-40 months (3+ years!)

**Recommendation:** Your auto-top-up at $5 is perfect. You'll rarely need to add more.

### When You'd Exceed $5/Month

| Scenario | Monthly Tasks | Cost |
|----------|--------------|------|
| **Light use (you)** | 300-500 | $0.20-0.30 |
| Moderate use | 1,000-2,000 | $1.00-2.00 |
| Heavy use | 5,000+ | $5.00+ |
| **Power user** (local LLM better) | 10,000+ | $10.00+ |

**Conclusion:** You're well under $5/month. $10 prepaid should last years.

---

## Storing in 1Password

### Create 1Password Items

You need **two separate OpenAI keys** for different purposes:

#### 1. CLI Vault (Personal Development)

**Via 1Password App:**

1. Open 1Password → Select **CLI** vault
2. Click **+** → **API Credential**
3. Fill in:
   - **Title**: `openai.api-key.cli`
   - **Username**: `OPENAI_API_KEY`
   - **Credential**: `sk-proj-...` (your personal API key)
   - **Type**: `bearer`
   - **Tags**: `api-key`, `cli`, `openai`
   - **Notes**:

     ```
     OpenAI personal API key for CLI tools and shell scripts.

     Account: Personal (prepaid credit)
     Balance: $10 with auto-top-up at $5
     Model: GPT-4o-mini (recommended)
     Created: 2025-10-22
     Used by: CLI scripts, terminal, personal experiments
     Integration: Shell (.zshrc), CLI tools
     ```

4. Click **Save**

#### 2. MCP Orchestrator Vault (Production) ✅ Already Created

**You already have this:** `openai.api-key.mcp-orchestrator`

- **Username**: `OPENAI_API_KEY`
- **Type**: Bearer Token
- **Used by**: n8n workflows, auto-tagger agent, task grouper agent
- **Models**: GPT-4 (configurable) or GPT-4o-mini
- **Integration**: MCP Orchestrator, n8n, Docker containers

**Via CLI (Alternative):**

```bash
op item create --category "API Credential" \
  --vault "CLI" \
  --title "openai.api-key.cli" \
  --tags "cli,openai,ai,automation" \
  username="OPENAI_API_KEY" \
  type="bearer" \
  credential="sk-proj-YOUR_KEY_HERE" \
  notesPlain="OpenAI personal API key for CLI and n8n. Model: GPT-4o-mini. Balance: $10 prepaid with auto-top-up at $5."
```

### Get UUIDs for Integration

**CLI Vault (for shell integration):**

```bash
# Get item UUID
op item get "openai.api-key.cli" --vault CLI --format json | jq -r '.id'
# Output: vu3qf2nd5g6yzhik4l6zt5sy7a

# Verify field structure
op item get "vu3qf2nd5g6yzhik4l6zt5sy7a" --format json | jq -r '.fields[] | "\(.label): \(.id)"'
# Expected output:
# username: username
# type: type
# credential: credential  ← Use this label
```

**MCP Orchestrator Vault (for n8n/Docker):**

```bash
# Get vault UUID
op vault list --format json | jq -r '.[] | select(.name=="MCP Orchestrator") | .id'

# Get item UUID
op item get "openai.api-key.mcp-orchestrator" --vault "MCP Orchestrator" --format json | jq -r '.id'

# For .env file reference
echo "OPENAI_API_KEY=op://MCP Orchestrator/openai.api-key.mcp-orchestrator/credential"
```

### Add to .zshrc

**Parallel loading configuration:**

```bash
# =============================================================================
# OpenAI API
# =============================================================================
# Vault: CLI (your-vault-uuid)
# Item: openai.api-key.cli (vu3qf2nd5g6yzhik4l6zt5sy7a)
# Username: OPENAI_API_KEY
# Field: credential (default field, stable UUID)
# Used by: CLI tools, n8n workflows, AI auto-tagging
# Cost: ~$0.20-0.30/month (GPT-4o-mini for task tagging)
op read "op://CLI/vu3qf2nd5g6yzhik4l6zt5sy7a/credential" > "$_OP_TEMP_DIR/openai" 2>/dev/null &

# ... (other secrets loaded in parallel)

wait  # Wait for all parallel reads to complete

export OPENAI_API_KEY=$(cat "$_OP_TEMP_DIR/openai" 2>/dev/null)

# Cleanup
rm -rf "$_OP_TEMP_DIR"
```

**Test:**

```bash
# Reload shell
exec zsh

# Verify loaded
echo $OPENAI_API_KEY | head -c 20
# Expected: sk-proj-Kz...

# Test with OpenAI CLI (if installed)
openai api models.list
```

---

## Integration

### n8n Cloud

**Setup:**

1. In n8n workflow editor, add **OpenAI node**
2. Click **Select credential** → **+ Create New**
3. Name: `OpenAI - MCP Orchestrator`
4. API Key: Copy from 1Password (`openai.api-key.mcp-orchestrator`)
5. Click **Save**

**Why separate from CLI key?**

- ✅ Track production usage separately from personal experiments
- ✅ Rotate production key without affecting CLI tools
- ✅ Clear billing attribution (n8n workflows vs CLI scripts)

**Use in workflow:**

```yaml
OpenAI Node Configuration:
  - Credential: OpenAI - Personal
  - Model: gpt-4o-mini  # Recommended for cost efficiency
  - Resource: Message a Model
  - System Message: |
      You are an AI task tagger. Analyze tasks and suggest tags.
      Available tags: @work, @personal, @urgent, @low, @research, @code, @admin
      Return JSON: {"tags": ["@work", "@urgent"], "confidence": 0.92}
  - User Message: {{ $json.content }}
```

**Cost optimization:**

- ✅ Use **gpt-4o-mini** for task tagging (~$0.15 per 1M tokens)
- ❌ Avoid **gpt-4o** unless you need advanced reasoning (~$2.50 per 1M tokens)

### n8n Self-Hosted

**With 1Password op run:**

**.env file (in orchestrator/ directory):**

```bash
# OpenAI API (for AI auto-tagging)
# Use MCP Orchestrator vault key (not CLI vault)
OPENAI_API_KEY=op://MCP Orchestrator/openai.api-key.mcp-orchestrator/credential
```

**docker-compose.yml:**

```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    env_file: .env
    environment:
      - OP_SERVICE_ACCOUNT_TOKEN=${OP_SERVICE_ACCOUNT_TOKEN}
    command: /bin/sh -c "op run --env-file=.env -- n8n start"
```

**Start:**

```bash
# Use MCP Orchestrator service account (not CLI service account)
export OP_SERVICE_ACCOUNT_TOKEN="ops_ey..."  # From 1password.service-account.mcp-orchestrator
docker-compose up
```

**Why separate service account?**

- ✅ Production service account scoped to MCP Orchestrator vault only
- ✅ CLI service account scoped to CLI vault only
- ✅ Compromised CLI token doesn't expose production secrets

### CLI Tools

**Direct usage:**

```bash
# Example: OpenAI CLI (if installed)
openai api chat.completions.create \
  -m gpt-4o-mini \
  -g system "You are a task tagger" \
  -g user "Research OAuth by Friday" \
  --api-key "$OPENAI_API_KEY"
```

**In shell scripts:**

```bash
#!/usr/bin/env zsh

# Tag a task using OpenAI
tag_task() {
  local task="$1"

  curl https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "{
      \"model\": \"gpt-4o-mini\",
      \"messages\": [
        {\"role\": \"system\", \"content\": \"Suggest tags for this task.\"},
        {\"role\": \"user\", \"content\": \"$task\"}
      ]
    }" | jq -r '.choices[0].message.content'
}

# Usage
tag_task "Research OAuth by Friday"
# Output: @work @research @urgent
```

### GitHub Copilot (Future)

**Not yet supported natively, but you can:**

1. Use OpenAI API in your orchestrator
2. Copilot Chat calls your orchestrator API
3. Orchestrator uses OpenAI for AI features

**Alternative:** GitHub Copilot has built-in AI (no OpenAI API needed for code generation).

---

## Alternatives

### Claude API (Anthropic)

**Note:** On back burner for now (as you mentioned).

**When to consider:**

- ✅ Better at complex reasoning (research summaries)
- ✅ Longer context window (200k tokens vs OpenAI's 128k)
- ✅ Alternative if OpenAI quota exceeded

**Pricing (October 2025):**

| Model | Input | Output | vs GPT-4o-mini |
|-------|-------|--------|----------------|
| Claude 3.5 Sonnet | $3.00/1M | $15.00/1M | 20x more expensive |
| Claude 3 Haiku | $0.25/1M | $1.25/1M | ~2x more expensive |

**Recommendation:** Stick with GPT-4o-mini for task tagging (much cheaper). Consider Claude for research summaries later.

### Local LLMs (Ollama)

**When to consider:**

- ✅ **Self-hosted n8n** (not Cloud)
- ✅ **Heavy usage** (> 10,000 tasks/month)
- ✅ **Privacy critical** (never send data to cloud)
- ✅ **Mac with 16GB+ RAM**

**Setup:**

```bash
# Install Ollama
brew install ollama

# Start Ollama server
ollama serve &

# Download model (one-time, ~4GB)
ollama pull llama3.2

# Test
ollama run llama3.2 "Suggest tags for: Research OAuth by Friday"
```

**n8n integration:**

```yaml
# Use HTTP Request node instead of OpenAI node
HTTP Request Node:
  - Method: POST
  - URL: http://localhost:11434/api/generate
  - Body:
      model: llama3.2
      prompt: "Suggest tags for: {{ $json.content }}"
```

**Pros:**

- ✅ Free (no API costs)
- ✅ Unlimited usage
- ✅ Private (data stays local)

**Cons:**

- ❌ Slower than cloud (5-10s vs 1-2s)
- ❌ Requires self-hosted n8n
- ❌ Quality slightly lower than GPT-4o-mini
- ❌ Mac must be on (same as self-hosted n8n)

**Recommendation for you:** Stick with OpenAI Cloud + n8n Cloud. At $0.20/month, not worth the complexity of local LLMs.

---

## Troubleshooting

### API Key Invalid

**Symptoms:**

```
Error: Invalid API key
```

**Diagnosis:**

```bash
# Test key manually
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"

# Should return list of models
# If error: Check key is correct in 1Password
```

**Fix:**

1. Go to [OpenAI API Keys](https://platform.openai.com/api-keys)
2. Check key status (active vs revoked)
3. If revoked: Generate new key
4. Update in 1Password
5. Reload shell: `exec zsh`

### Insufficient Quota

**Symptoms:**

```
Error: You exceeded your current quota, please check your plan and billing details
```

**Cause:** Prepaid credit exhausted.

**Fix:**

1. Go to [OpenAI Billing](https://platform.openai.com/settings/organization/billing/overview)
2. Check balance (should show remaining credit)
3. If $0: Add more credit (your auto-top-up should prevent this)
4. Verify auto-recharge enabled

**Your setup:** ✅ Auto-top-up at $5 should prevent this

### Rate Limit Exceeded

**Symptoms:**

```
Error: Rate limit reached for gpt-4o-mini
```

**Cause:** Too many requests in short time.

**Limits (free tier with prepaid credit):**

- **Requests per minute:** 500
- **Tokens per minute:** 200,000
- **Requests per day:** 10,000

**Fix:**

1. Add retry logic in n8n (built-in retry node)
2. Reduce frequency (e.g., batch tag 10 tasks at once)
3. Wait 60 seconds and retry
4. If persistent: Upgrade to paid tier ($5/month minimum)

**Your usage:** ~600 tasks/month = ~20/day = well under limits ✅

### n8n OpenAI Node Error

**Symptoms:**

```
NodeOperationError: OpenAI error
```

**Diagnosis:**

1. Check credential configured in n8n
2. Test API key manually (see "API Key Invalid")
3. Check n8n logs (Settings → Log Streaming)

**Common causes:**

- Wrong API key in n8n credentials
- Key revoked in OpenAI
- Quota exceeded
- Model name typo (use `gpt-4o-mini`, not `gpt-4-mini`)

**Fix:**

1. Re-create n8n credential with fresh key from 1Password
2. Test with simple workflow (just OpenAI node)
3. Check OpenAI usage dashboard

### Environment Variable Not Loading

**Symptoms:**

```bash
echo $OPENAI_API_KEY
# (empty)
```

**Diagnosis:**

```bash
# Check if 1Password reads successfully
op read "op://CLI/vu3qf2nd5g6yzhik4l6zt5sy7a/credential"

# Should output: sk-proj-Kz...
```

**Fix:**

```bash
# Verify service account has CLI vault access
# → 1Password web → Service Accounts → Check vaults

# Verify item UUID correct
op item get "openai.api-key.cli" --vault CLI --format json | jq -r '.id'

# Update .zshrc if UUID changed
# Reload shell
exec zsh
```

---

## References

### Official Documentation

- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
- [Pricing](https://openai.com/api/pricing/)
- [Models Overview](https://platform.openai.com/docs/models)
- [Rate Limits](https://platform.openai.com/docs/guides/rate-limits)

### Project-Specific

- Repository: [mcp-orchestrator-one-truth-repository](https://github.com/Kingy2709/mcp-orchestrator-one-truth-repository)
- 1Password Setup: `/docs/setup/1password.md`
- n8n Setup: `/docs/setup/n8n.md`

### Quick Reference

```bash
# Create 1Password item
op item create --category "API Credential" \
  --vault "CLI" \
  --title "openai.api-key.cli" \
  username="OPENAI_API_KEY" \
  credential="sk-proj-YOUR_KEY"

# Read from 1Password
op read "op://CLI/vu3qf2nd5g6yzhik4l6zt5sy7a/credential"

# Test API
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"

# Check usage
# → https://platform.openai.com/usage

# Check balance
# → https://platform.openai.com/settings/organization/billing/overview
```

---

**Document Version:** 1.0
**Last Updated:** October 22, 2025
**Your Setup:** ✅ $10 prepaid | Auto-top-up at $5 | UUID: vu3qf2nd5g6yzhik4l6zt5sy7a | Cost: ~$0.20-0.30/month
