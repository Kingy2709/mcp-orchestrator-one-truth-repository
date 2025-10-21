# n8n Setup Guide

> Complete setup instructions for n8n-powered bidirectional sync with AI auto-tagging.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Cloud vs Self-Hosted Decision](#cloud-vs-self-hosted-decision)
3. [Quick Start (n8n Cloud)](#quick-start-n8n-cloud)
4. [Self-Hosted Setup](#self-hosted-setup)
5. [Workflow Configuration](#workflow-configuration)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

**Accounts Required:**

- ✅ [n8n account](https://n8n.io/trial) (14-day free trial)
- ✅ [Notion workspace](https://www.notion.so/) with API integration
- ✅ [Todoist account](https://todoist.com/) (free or premium)
- ✅ [OpenAI API key](https://platform.openai.com/api-keys) or [Claude API key](https://console.anthropic.com/)

**API Keys:**

Store in 1Password (see [1Password setup guide](./1password.md)):

- `NOTION_API_KEY` - From Notion integrations page
- `TODOIST_API_TOKEN` - From Todoist settings → Integrations
- `OPENAI_API_KEY` or `CLAUDE_API_KEY` - For AI auto-tagging
- `GITHUB_PERSONAL_ACCESS_TOKEN` (optional) - For Copilot Agent triggers

---

## Cloud vs Self-Hosted Decision

### Quick Comparison

| Feature | n8n Cloud (Starter €20/mo) | Self-Hosted (Free) |
|---------|---------------------------|-------------------|
| **Setup Time** | 10 minutes | 60-90 minutes |
| **"Build with AI"** | ✅ Yes | ❌ No (manual workflow) |
| **Maintenance** | ✅ Zero (automatic updates) | ❌ You handle updates/backups |
| **Executions/month** | 2,500 | ∞ Unlimited |
| **Always Available** | ✅ Yes (cloud-hosted) | ❌ Only when Mac is on |
| **Mac Sleep Impact** | ✅ None (runs in cloud) | ❌ Sync stops when Mac sleeps |
| **Webhook Reliability** | ✅ 99.9% uptime | ⚠️ Depends on Mac uptime |
| **Mobile Access** | ✅ Yes (web UI) | ❌ Not easily |
| **Data Privacy** | ⚠️ Encrypted on n8n servers | ✅ Never leaves your Mac |
| **Monthly Cost** | €20 (~$22) | $0 (but requires always-on Mac) |
| **Best For** | Most users, beginners | Power users, privacy-focused, high volume |

### System Requirements (Self-Hosted)

**Your Mac can easily handle self-hosted n8n:**

- **CPU:** 1-2 cores (n8n is lightweight, less resource-intensive than VS Code)
- **RAM:** 512 MB - 2 GB (out of your total 8-16GB+)
- **Disk:** 500 MB - 2 GB (includes workflow storage)
- **OS:** macOS 10.15+ ✅ (you're covered)

**The "Always On" Problem:**

Self-hosted n8n only runs when your Mac is on. If Mac sleeps:

- ❌ **Todoist webhooks fail** - Tasks created while Mac sleeps won't sync
- ⚠️ **Notion polling pauses** - Resumes on wake, but delayed
- 🔧 **Solutions:**
  - Prevent Mac sleep (`caffeinate -s` or System Settings)
  - Use dedicated Mac Mini / old laptop as 24/7 server
  - Start with Cloud, switch to self-hosted later if needed

### Expected Usage (1 Person)

| Activity | Daily | Monthly | % of Starter Quota |
|----------|-------|---------|-------------------|
| Todoist tasks created | 10-15 | 300-450 | 12-18% |
| Todoist tasks completed | 8-12 | 240-360 | 10-14% |
| Notion polling (30s interval) | ~2,880 | ~86,400 | N/A (background) |
| AI auto-tagging calls | 10-15 | 300-450 | 12-18% |
| GitHub Agent triggers | 1-3 | 30-90 | 1-4% |
| **Total executions** | **~50-60** | **~1,500** | **~60%** |

**Conclusion:** Most users stay well under the 2,500/month limit.

### Recommendation

**Start with n8n Cloud Starter (€20/mo) if:**

- ✅ You value "always works" reliability (Mac can sleep/restart)
- ✅ You want "Build with AI" (saves 2-3 hours manual setup)
- ✅ You're new to n8n or workflow automation
- ✅ Your Mac isn't always on (laptop users)
- ✅ You expect < 2,000 executions/month
- ✅ €20/mo is acceptable for zero-maintenance solution

**Use Self-Hosted (Free) if:**

- ✅ You have Mac Mini / old laptop running 24/7
- ✅ You're comfortable with Docker Compose troubleshooting
- ✅ You exceed 2,500 executions/month consistently
- ✅ Privacy is critical (data must never leave your Mac)
- ✅ You want to use local LLMs (Ollama) instead of OpenAI/Claude
- ✅ You enjoy tinkering with infrastructure

**Hybrid Approach (Advanced):**

- Use Cloud for critical webhooks (Todoist → Notion)
- Use Self-hosted for batch operations or privacy-sensitive tasks
- Best of both worlds: €20/mo + unlimited local capacity

### Trial Period Strategy

**Week 1-2:** Use n8n Cloud free trial (14 days)

- Test workflow reliability
- Check execution count in dashboard (Settings → Usage)
- Verify < 5 second Siri → Todoist → Notion capture works

**Month 2-6:** Pay €20/mo for Starter

- Optimize workflow, tune AI rules
- Track monthly execution count
- If consistently under 1,500/month → keep Cloud
- If approaching 2,500/month → evaluate self-hosted

**Month 6+:** Decide based on data

- Under 2,000/month? → Keep Cloud (worth €20 for peace of mind)
- Exceeding 2,500/month regularly? → Self-hosted (free unlimited)
- Need advanced features? → Upgrade to Pro (€50/mo, 5,000 executions)

---

## Quick Start (n8n Cloud)

### 1. Sign Up for n8n

1. Go to <https://n8n.io/trial>
2. Click **Start Free Trial** (14 days, no credit card required)
3. Create account with email/password or Google/GitHub OAuth
4. Select **Starter Plan** (€20/mo after trial, includes AI features)

### 2. Generate Workflow with AI

**Use n8n's "Build with AI" feature:**

1. Click **+ Add Workflow** → **Build with AI**
2. Paste this combined prompt:

```
Create a bidirectional sync workflow between Todoist and Notion with AI auto-tagging:

PART 1 - TODOIST TO NOTION:
1. Webhook trigger for Todoist events (item_added, item_updated, item_completed)
2. OpenAI node to analyze task content and suggest tags (@work/@personal, @urgent/@low, @research/@code/@admin)
3. Notion node to create/update database item with:
   - Title: Task content
   - Status: From Todoist status
   - Tags: AI-generated tags
   - Todoist_ID: Unique identifier
   - AI_Confidence: 0-1 score from OpenAI
   - Last_Synced: Current timestamp
4. Todoist node to update task with AI-generated labels
5. Conditional node: If @research or @code tag detected → HTTP Request to GitHub API (workflow_dispatch) to trigger Copilot Agent

PART 2 - NOTION TO TODOIST:
1. Notion trigger polling database every 30 seconds
2. Function node to generate SHA-256 hash of content for deduplication
3. Conditional node: Skip if hash matches previous sync (prevents infinite loop)
4. HTTP Request node to Todoist API (POST /rest/v2/tasks or PATCH /rest/v2/tasks/{id})
5. Conflict resolution: Compare Last_Synced timestamp, most recent change wins
6. Notion node to update Last_Synced timestamp

ERROR HANDLING:
- Add error handler to log failed syncs to Notion "Sync Errors" database
- Retry 3 times with exponential backoff (1s, 2s, 4s delays)
```

3. Click **Generate** - n8n AI will create the complete workflow
4. Review generated nodes and connections

### 3. Connect Credentials

**Notion:**

1. Click Notion node → **Create New Credential**
2. Select **OAuth2** authentication
3. Click **Connect my account** → Authorize n8n access
4. Select workspace and databases to share

**Todoist:**

1. Click Todoist node → **Create New Credential**
2. Select **API Key** authentication
3. Paste `TODOIST_API_TOKEN` from 1Password
4. Click **Save**

**OpenAI/Claude:**

1. Click OpenAI node → **Create New Credential**
2. Select **API Key** authentication
3. Paste `OPENAI_API_KEY` from 1Password
4. Click **Save**

**GitHub (Optional - for Copilot Agent triggers):**

1. Click HTTP Request node → **Create New Credential**
2. Select **Header Auth**
3. Header Name: `Authorization`
4. Header Value: `Bearer YOUR_GITHUB_PAT`
5. Click **Save**

### 4. Configure Webhook

**Get n8n webhook URL:**

1. Click Todoist Webhook Trigger node
2. Copy **Production URL**: `https://yourname.app.n8n.cloud/webhook/todoist-sync`

**Configure in Todoist:**

1. Go to [Todoist Integrations](https://todoist.com/app/settings/integrations)
2. Scroll to **Webhooks** → Click **Manage**
3. Click **Add webhook**
4. URL: Paste n8n webhook URL
5. Events: Select `item:added`, `item:updated`, `item:completed`
6. Click **Save**

### 5. Test Sync

**Test Todoist → Notion:**

1. In Todoist, create task: "Test OAuth integration for GitHub @work @research"
2. Check n8n **Executions** tab (should show successful run < 5 seconds)
3. Check Notion database (should have new item with AI-generated tags)
4. Check Todoist (task should have updated labels from AI)

**Test Notion → Todoist:**

1. In Notion database, update task title or status
2. Wait 30 seconds (polling interval)
3. Check Todoist (task should update to match Notion)

**Expected Results:**

✅ Todoist → Notion sync < 5 seconds (webhook)
✅ Notion → Todoist sync < 30 seconds (polling)
✅ AI tags added with 0.7+ confidence score
✅ No duplicate tasks created (deduplication working)
✅ Copilot Agent triggered if @research/@code tag (optional)

---

## Self-Hosted Setup

> **⚠️ Consider this option only if:**
>
> - You have a Mac/server running 24/7 (not a laptop that sleeps)
> - You're comfortable troubleshooting Docker and networking issues
> - You need unlimited executions (> 2,500/month)
> - Privacy is critical (data must stay on your Mac)
>
> **Most users should start with [n8n Cloud](#quick-start-n8n-cloud)** for reliability.

**Use Docker Compose for self-hosted n8n Community Edition (free, unlimited executions):**

### 1. Install Docker

```bash
# macOS with Homebrew
brew install --cask docker

# Start Docker Desktop
open -a Docker
```

### 2. Create docker-compose.yml

```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
      - WEBHOOK_URL=https://n8n.example.com
      - GENERIC_TIMEZONE=America/Los_Angeles
    volumes:
      - n8n_data:/home/node/.n8n
    restart: unless-stopped

volumes:
  n8n_data:
```

### 3. Start n8n

```bash
# Set password
export N8N_PASSWORD="your-secure-password"

# Start n8n
docker-compose up -d

# View logs
docker-compose logs -f n8n

# Open n8n UI
open http://localhost:5678
```

### 4. Import Workflow

**Since self-hosted doesn't have "Build with AI":**

1. Open n8n UI: <http://localhost:5678>
2. Click **+ Add Workflow** → **Import from URL**
3. URL: `https://n8n.io/workflows/...` (workflow template when available)
4. Or manually create workflow following structure in [Workflow Configuration](#workflow-configuration)

### 5. Keep Mac Awake (Important!)

**Self-hosted requires Mac to stay on for sync to work:**

```bash
# Option 1: Prevent sleep while plugged in (temporary)
caffeinate -s

# Option 2: System Settings (permanent)
# System Settings → Energy → Prevent automatic sleeping when display is off

# Option 3: Scheduled wake (wake Mac at specific times)
sudo pmset repeat wakeorpoweron MTWRFSU 07:00:00
```

**Better solution:** Use dedicated hardware (Mac Mini, old laptop) as 24/7 server.

### 6. Configure Webhook URL

**Self-hosted needs public URL for Todoist webhooks:**

**Option A: Tailscale (Recommended)**

```bash
# Install Tailscale
brew install tailscale
sudo tailscale up

# Get your Tailscale IP
tailscale ip -4
# Example: 100.x.x.x

# Webhook URL: http://100.x.x.x:5678/webhook/todoist-sync
# (Only accessible on your Tailscale network - secure!)
```

**Option B: ngrok (Temporary testing)**

```bash
# Install ngrok
brew install ngrok

# Create tunnel
ngrok http 5678

# Copy HTTPS URL (e.g., https://abc123.ngrok.io)
# Webhook URL: https://abc123.ngrok.io/webhook/todoist-sync
```

**Note:** Todoist webhooks require HTTPS. Use ngrok for testing, Tailscale + reverse proxy (nginx) for production.

---

## Workflow Configuration

### Todoist → Notion Workflow

**Node 1: Webhook Trigger**

- Type: `Webhook`
- Path: `/webhook/todoist-sync`
- HTTP Method: `POST`
- Authentication: `Header Auth` (verify Todoist signature)

**Node 2: OpenAI Node (AI Auto-Tagger)**

- Type: `OpenAI`
- Operation: `Chat`
- Model: `gpt-4` or `gpt-3.5-turbo`
- System Prompt:

  ```
  You are a task categorization AI. Analyze task content and suggest tags.
  Available tags: @work, @personal, @urgent, @low, @research, @code, @admin
  Return JSON: {"tags": ["@work", "@urgent"], "confidence": 0.92, "reasoning": "..."}
  ```

- User Prompt: `{{ $json.event_data.content }}`

**Node 3: Notion Node (Create/Update Database Item)**

- Type: `Notion`
- Operation: `Create Database Page` or `Update Database Page`
- Database ID: Select your Tasks database
- Properties:
  - Title: `{{ $json.event_data.content }}`
  - Status: `{{ $json.event_data.checked ? "Done" : "To Do" }}`
  - Tags: `{{ $node["OpenAI"].json.tags }}`
  - Todoist_ID: `{{ $json.event_data.id }}`
  - AI_Confidence: `{{ $node["OpenAI"].json.confidence }}`
  - Last_Synced: `{{ $now }}`

**Node 4: Todoist Node (Update Task)**

- Type: `HTTP Request`
- Method: `POST`
- URL: `https://api.todoist.com/rest/v2/tasks/{{ $json.event_data.id }}`
- Headers: `Authorization: Bearer {{ $credentials.todoist_api_token }}`
- Body:

  ```json
  {
    "labels": {{ $node["OpenAI"].json.tags }}
  }
  ```

**Node 5: Conditional Node (Trigger Copilot Agent)**

- Type: `IF`
- Condition: `{{ $node["OpenAI"].json.tags.includes("@research") || $node["OpenAI"].json.tags.includes("@code") }}`
- True branch: HTTP Request to GitHub API
  - URL: `https://api.github.com/repos/{owner}/{repo}/dispatches`
  - Method: `POST`
  - Body:

    ```json
    {
      "event_type": "copilot_agent_trigger",
      "client_payload": {
        "agent": "{{ $node["OpenAI"].json.tags.includes("@research") ? "research-agent" : "code-agent" }}",
        "task_id": "{{ $json.event_data.id }}",
        "prompt": "{{ $json.event_data.content }}"
      }
    }
    ```

**Node 6: Error Handler**

- Type: `On Error`
- Action: Create Notion page in "Sync Errors" database
- Retry: 3 attempts with exponential backoff (1s, 2s, 4s)

### Notion → Todoist Workflow

**Node 1: Notion Trigger**

- Type: `Notion Trigger`
- Operation: `Database Page Updated`
- Database ID: Select your Tasks database
- Poll Interval: 30 seconds

**Node 2: Deduplication Function**

- Type: `Function`
- Code:

  ```javascript
  const crypto = require('crypto');
  const content = $input.item.json.properties.Title.title[0].plain_text;
  const hash = crypto.createHash('sha256').update(content).digest('hex');
  return { hash, content, ...$ input.item.json };
  ```

**Node 3: Conditional (Skip if Duplicate)**

- Type: `IF`
- Condition: `{{ $json.hash !== $node["PreviousHash"].json.hash }}`
- False branch: Stop execution (skip sync)

**Node 4: HTTP Request (Todoist API)**

- Type: `HTTP Request`
- Method: `POST` or `PATCH` (based on if Todoist_ID exists)
- URL: `https://api.todoist.com/rest/v2/tasks` or `/tasks/{{ $json.properties.Todoist_ID }}`
- Body:

  ```json
  {
    "content": "{{ $json.properties.Title.title[0].plain_text }}",
    "labels": {{ $json.properties.Tags.multi_select }},
    "priority": {{ $json.properties.Status === "Urgent" ? 1 : 4 }}
  }
  ```

**Node 5: Notion Node (Update Last_Synced)**

- Type: `Notion`
- Operation: `Update Database Page`
- Page ID: `{{ $json.id }}`
- Properties:
  - Last_Synced: `{{ $now }}`

---

## Testing

### Manual Workflow Execution

1. Click **Execute Workflow** button (top right)
2. Manually trigger webhook with test payload:

   ```json
   {
     "event_name": "item:added",
     "event_data": {
       "id": "123456789",
       "content": "Test OAuth integration @work @research",
       "checked": false
     }
   }
   ```

3. View execution results in each node

### Integration Testing

**Test Todoist → Notion:**

1. Siri: "Remind me to research OAuth for GitHub integration"
2. Check n8n executions (< 5 seconds)
3. Check Notion database (new item with @work, @research tags)

**Test Notion → Todoist:**

1. Edit task title in Notion
2. Wait 30 seconds
3. Check Todoist (updated)

**Test AI Confidence:**

1. Create ambiguous task: "Thing tomorrow"
2. Check AI_Confidence score (should be < 0.5)
3. Manually review and correct tags in Notion

---

## Troubleshooting

### Issue: Webhook not triggered

**Symptoms**: Create task in Todoist, no execution in n8n.

**Fix**:

1. Check n8n webhook URL is correct in Todoist settings
2. Verify webhook is **Production** (not Test) in n8n
3. Test webhook manually:

   ```bash
   curl -X POST https://yourname.app.n8n.cloud/webhook/todoist-sync \
     -H "Content-Type: application/json" \
     -d '{"event_name":"item:added","event_data":{"content":"Test"}}'
   ```

### Issue: "Authentication failed" in Notion node

**Symptoms**: Notion node fails with 401 error.

**Fix**:

1. Re-authorize Notion OAuth in n8n credentials
2. Ensure Notion integration has access to correct database
3. Check database ID is correct (copy from Notion URL)

### Issue: Duplicate tasks created

**Symptoms**: Same task appears multiple times in Notion/Todoist.

**Fix**:

1. Check deduplication hash function is working
2. Verify `Todoist_ID` field exists and is populated
3. Add `IF` node to skip sync if `Last_Synced` < 10 seconds ago

### Issue: AI tags low confidence

**Symptoms**: AI_Confidence consistently < 0.6.

**Fix**:

1. Improve system prompt with more examples
2. Use `gpt-4` instead of `gpt-3.5-turbo` (higher accuracy)
3. Add fallback: If confidence < 0.6, assign @personal tag by default

### Issue: Exceeding 2,500 executions/month

**Symptoms**: n8n Starter plan quota warning.

**Fix**:

1. Reduce Notion polling frequency (30s → 60s)
2. Optimize workflow (batch updates, skip unchanged items)
3. Upgrade to Pro plan (€50/mo, 5,000 executions)
4. Self-host Community Edition (unlimited executions, free)

### Issue: Self-hosted n8n stops when Mac sleeps

**Symptoms**: Workflows don't run, webhooks fail while Mac is asleep.

**Fix**:

1. **Prevent Mac sleep** (temporary):

   ```bash
   caffeinate -s  # Keeps Mac awake while plugged in
   ```

2. **System Settings** (permanent):
   - System Settings → Energy → Prevent automatic sleeping when display is off

3. **Scheduled wake** (wake at specific times):

   ```bash
   sudo pmset repeat wakeorpoweron MTWRFSU 07:00:00
   ```

4. **Best solution:** Use dedicated hardware (Mac Mini, old laptop) running 24/7

5. **Or switch to n8n Cloud** - always available, no sleep issues (€20/mo)

---

## Cloud vs Self-Hosted: Final Decision Matrix

| Your Situation | Recommendation | Reason |
|----------------|---------------|---------|
| **Laptop that sleeps often** | n8n Cloud | Self-hosted breaks when Mac sleeps |
| **< 2,000 executions/month** | n8n Cloud | Well within Starter quota |
| **Just starting with n8n** | n8n Cloud | "Build with AI" saves hours |
| **Have 24/7 Mac/server** | Self-hosted | Free unlimited executions |
| **> 2,500 executions/month** | Self-hosted OR Pro | Free (self-hosted) vs €50/mo (Pro) |
| **Privacy-critical tasks** | Self-hosted | Data never leaves your Mac |
| **€20/mo is too expensive** | Self-hosted | But requires maintenance effort |
| **Value time > money** | n8n Cloud | Zero maintenance, always works |

**Bottom line:** Start with n8n Cloud Starter (€20/mo) for 3-6 months. Your time is worth more than debugging Docker at midnight. Switch to self-hosted later if you consistently exceed quota or need more control.

---

## Next Steps

✅ **Set up 1Password integration**: [1password.md](./1password.md)
✅ **Configure GitHub Copilot Agents**: [../integrations/github-copilot.md](../integrations/github-copilot.md)
✅ **Optimize workflow performance**: [ADHD Optimizations](../workflows/adhd-optimizations.md)
✅ **Deploy to production**: [ARCHITECTURE.md](../../ARCHITECTURE.md#deployment)

---

## References

- [n8n Documentation](https://docs.n8n.io/)
- [n8n AI Workflows Guide](https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/ai/)
- [Notion API Reference](https://developers.notion.com/reference)
- [Todoist API Reference](https://developer.todoist.com/rest/v2)
- [OpenAI API Documentation](https://platform.openai.com/docs)
