# ADR-001: Use n8n Instead of Custom Orchestrator

**Status:** Accepted
**Date:** 2025-10-18
**Deciders:** Kingy2709
**Tags:** #architecture #strategic-pivot #sync-engine

## Context

We built ~80% of a custom TypeScript orchestrator service for bidirectional Notion ↔ Todoist sync with the following components:

- `orchestrator/src/sync/bidirectional.ts` (conflict resolution)
- `orchestrator/src/sync/notion.ts` (Notion sync engine)
- `orchestrator/src/sync/todoist.ts` (Todoist sync engine)
- `orchestrator/src/webhooks/server.ts` (Express webhook receiver)
- `orchestrator/src/agents/auto-tagger.ts` (basic AI tagging)
- Docker Compose setup, 1Password integration, Raycast extension

**Discovery (Oct 13-15, 2025):**

1. Official MCP servers exist (`makenotion/notion-mcp-server`, community Todoist MCP)
2. **40% of custom code is redundant**
3. n8n has "Realtime Notion Todoist 2-way Sync" template (workflow #2772)
4. Research into paid alternatives (n8n, Zapier, Motion) revealed n8n provides same functionality

**Time investment analysis:**

- **Finish custom orchestrator:** 20-40 hours (testing, debugging, edge cases)
- **Use n8n template:** 3-5 hours (configure, test, deploy)
- **Build unique AI features on n8n:** 10-20 hours (Copilot delegation, local LLM)

See [STRATEGIC-VALUE-ANALYSIS.md](../STRATEGIC-VALUE-ANALYSIS.md) for comprehensive comparison.

## Decision

**Use n8n Starter plan (€20/month) for bidirectional Notion ↔ Todoist sync** instead of finishing custom orchestrator.

### Rationale

**Cost:**

- n8n Starter: €20/mo ($22 USD)
- Motion (rejected alternative): $49/mo
- Zapier Pro: $20/mo + hidden AI costs
- **Savings:** €20/mo vs $49/mo Motion (59% cheaper)

**Time:**

- Save 20-40 hours of development time
- n8n template provides immediate working solution
- Can invest saved time building unique AI features

**Features (ALL included in n8n Starter):**

- ✅ 2,500 workflow executions/month (unlimited steps)
- ✅ Multi-agent systems
