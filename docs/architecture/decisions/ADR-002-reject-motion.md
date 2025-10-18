# ADR-002: Reject Motion in Favor of n8n

**Status:** Accepted  
**Date:** 2025-10-18  
**Deciders:** Kingy2709  
**Tags:** #strategic-decision #cost-analysis #vendor-evaluation

## Context

While researching alternatives to custom orchestrator, we evaluated **Motion** (usemotion.com) as a potential all-in-one replacement for Todoist + Notion + n8n.

### Motion Features (October 2025)

**AI Workplace ($29/mo):**
- AI Tasks (auto-schedules, prioritizes 1K+ parameters)
- AI Calendar (automatic rescheduling when life happens)
- AI Projects, Notes, Docs, Sheets
- NO AI Employees

**AI Employees Starter ($49/mo):**
- All AI Workplace features
- Limited AI Employees (Alfred, Chip, Clide, Suki, Dot, Millie, Spec)
- 10,000 AI credits/month

**Motion's Killer Feature:**
- **Automatic time-blocking:** Tasks auto-scheduled in calendar
- **Dynamic rescheduling:** Moves tasks when meetings added
- **ADHD-optimized:** "Overcome executive dysfunction" (user testimonials)

### Comparison Analysis

| Feature | n8n Starter (€20) | Motion AI Starter ($49) |
|---------|-------------------|-------------------------|
| **Cost** | €20/mo ($22 USD) | $49/mo |
| **Bidirectional Sync** | ✅ Template exists | ✅ Native |
| **AI Auto-tagging** | ✅ OpenAI/Claude nodes | ✅ AI Employees |
| **Auto-scheduling** | ❌ No | ✅ Motion's strength |
| **GitHub Copilot delegation** | ✅ Via webhooks | ❌ Can't integrate |
| **Local LLM** | ✅ Ollama support | ❌ Cloud-only |
| **Self-hosting** | ✅ Open-source | ❌ Vendor lock-in |
| **Notion flexibility** | ✅ Keep Notion | ⚠️ Basic docs only |
| **Multi-agent systems** | ✅ LangChain | ⚠️ Pre-built only |

See [STRATEGIC-VALUE-ANALYSIS.md](../STRATEGIC-VALUE-ANALYSIS.md) for 450+ line deep-dive.

## Decision

**Reject Motion, proceed with n8n Starter (€20/mo).**

### Rationale

**Cost (55% savings):**
- n8n: €20/mo vs Motion: $49/mo
- Annual savings: $324/year

**Control:**
- n8n: Open-source, self-hostable, full code access
- Motion: Proprietary, cloud-only, vendor lock-in
- Can export from n8n, trapped in Motion

**Flexibility:**
- n8n: Works WITH Notion (keep databases, relations, wiki)
- Motion: Replaces Notion (lose "Commands & Patterns" database)
- n8n: GitHub Copilot agent delegation possible
- Motion: Can't trigger external AI agents

**Development Use Case:**
- We're developers (value control > simplicity)
- Need GitHub Copilot @code/@research delegation
- Want local LLM (Ollama) for privacy
- Custom AI layer important (Motion pre-built only)

### What We're Giving Up

**Motion's auto-scheduling:**
- Automatic calendar time-blocking (tasks scheduled for you)
- Dynamic rescheduling (moves tasks when conflicts arise)
- "Happiness Algorithm" (optimizes for accomplishment feeling)
- ADHD testimonials: "overcome executive dysfunction"

**Mitigation:**
- Can add manual time-blocking in Google Calendar
- Todoist has natural language due dates
- n8n can suggest optimal dates with AI node (future feature)

## Consequences

### Positive

- ✅ Save $27/mo ($324/year)
- ✅ Keep full control (open-source, self-hosted option)
- ✅ GitHub Copilot agent delegation (via n8n webhooks)
- ✅ Local LLM support (Ollama via n8n)
- ✅ Keep Notion's flexibility (unlimited databases)
- ✅ Multi-agent systems (LangChain integration)

### Negative

- ❌ No automatic calendar time-blocking
- ❌ No dynamic task rescheduling
- ❌ Manual setup required (3-5 hours vs Motion's 0 setup)
- ❌ Need to build AI features ourselves (vs Motion pre-built)

### Neutral

- Motion's 7-day free trial available (can test later if needs change)
- n8n Community Edition (FREE) available if want to self-host
- Not a permanent decision (can pivot to Motion if auto-scheduling becomes critical)

## Notes

Motion is **excellent** for users who:
- Struggle with WHEN to do tasks (not just capturing)
- Want zero setup (works immediately)
- Don't need GitHub integration
- Value simplicity over control

We chose n8n because:
- We're developers (control > simplicity)
- ADHD workflow already functional (Siri → Todoist works)
- Budget-conscious ($27/mo savings)
- Need GitHub Copilot delegation (unique requirement)

## Related

- [ADR-001: Use n8n Over Custom](./ADR-001-use-n8n-over-custom.md)
- [STRATEGIC-VALUE-ANALYSIS.md](../STRATEGIC-VALUE-ANALYSIS.md)
- Motion research: [Motion Homepage](https://www.usemotion.com/), [Pricing](https://www.usemotion.com/pricing)
