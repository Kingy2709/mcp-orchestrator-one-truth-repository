# MCP Orchestrator - One Truth Repository

**ADHD-optimized task management with n8n-powered bidirectional sync**

Transform your workflow into a seamless automation connecting Notion, Todoist, and AI—maintaining a single source of truth without context-switching.

## 🚨 Current Status (October 2025)

**Strategic Pivot:** This project initially aimed to build a custom TypeScript orchestrator but **pivoted to n8n Starter (€20/mo)** after discovering:

1. ✅ **Official MCP servers exist** (`makenotion/notion-mcp-server`, community Todoist MCP)
2. ✅ **n8n template** provides bidirectional sync in 3-5 hours vs 40+ hours custom development
3. ✅ **All AI features included** (multi-agent, LangChain, local LLM) at €20/mo vs Motion $49/mo

**Decision rationale:** See [STRATEGIC-VALUE-ANALYSIS.md](docs/STRATEGIC-VALUE-ANALYSIS.md) for comprehensive comparison (n8n vs Zapier vs Motion).

**Architecture Decision Records:**

- [ADR-001: Use n8n Over Custom Orchestrator](docs/decisions/ADR-001-use-n8n-over-custom.md)
- [ADR-002: Reject Motion](docs/decisions/ADR-002-reject-motion.md)

## 🎯 Game-Changing Discoveries (October 2025)

### Raycast as a Natural Orchestrator

**Raycast now offers native orchestration capabilities** that significantly simplify the workflow automation landscape:

1. **GitHub Copilot Extension (OAuth)**: Raycast's GitHub Copilot extension uses OAuth authentication and allows you to:
   - View existing GitHub Copilot Agent tasks within repositories
   - Create new Copilot Agent tasks directly from Raycast
   - Access all Copilot features without leaving your quick-launcher interface

2. **Notion & Todoist Extensions (OAuth)**: Raycast also includes native extensions for both Notion and Todoist using OAuth, making it:
   - A fully-fledged orchestrator out-of-the-box
   - Zero custom development required for basic task capture and management
   - Seamless integration with existing workflows

**Implication**: For many users, **Raycast alone** may provide sufficient orchestration capabilities without requiring n8n or custom development, especially for quick capture and task management workflows.

### GitHub Copilot CLI's Full MCP Integration

Previous assumptions about GitHub Copilot CLI's limitations have been **corrected through further research**. GitHub Copilot CLI now offers:

#### Native MCP Server Support

GitHub Copilot CLI comes with the **GitHub MCP server pre-configured** and supports adding custom MCP servers:

**Adding MCP Servers:**
```bash
# Use the slash command in Copilot CLI
/mcp add
# Fill in the server details using Tab to navigate fields
# Press Ctrl+S to save
```

**Configuration Storage:**
- MCP servers are stored in `mcp-config.json`
- Default location: `~/.config/` (customizable via `XDG_CONFIG_HOME`)
- JSON structure follows the standard MCP protocol specification

**Usage Monitoring:**
```bash
# View context and usage statistics
/usage
# Shows:
# - Premium requests used in session
# - Session duration
# - Lines of code edited
# - Token usage breakdown per model
# - Warnings when context approaches token limits
```

**Key Capabilities:**

1. **Pre-configured GitHub MCP Server**: Interact with GitHub resources directly from CLI (merge PRs, view issues, etc.)
2. **Extensible via Custom MCP Servers**: Add any MCP server (Notion, Todoist, 1Password, etc.) to extend functionality
3. **Tool Auto-Approval**: Configure tools to run without manual approval for seamless automation
4. **Full Feature Parity**: All GitHub Copilot features available in CLI, including Coding Agent with MCP support

**Documentation References:**

- [Use Copilot CLI](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)
- [Allowing Tools Without Manual Approval](https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli#allowing-tools-to-be-used-without-manual-approval)
- [MCP and Coding Agent](https://docs.github.com/en/copilot/concepts/agents/coding-agent/mcp-and-coding-agent)

**Implication**: GitHub Copilot CLI can serve as a **command-line orchestrator** with full MCP protocol support, eliminating the need for custom server implementations in many scenarios. Combined with Raycast's GUI extensions, this creates a powerful two-tier orchestration system (CLI + GUI).

---

## Overview

This repository documents an **ADHD-optimized workflow** using n8n for automated bidirectional sync between Notion and Todoist. Capture thoughts via Siri, auto-tag with AI, sync to Notion, and maintain a canonical source of truth—all in < 5 seconds.

**Recent Discovery**: Raycast's native GitHub Copilot, Notion, and Todoist extensions (all using OAuth) combined with GitHub Copilot CLI's full MCP server support may provide sufficient orchestration capabilities for many users without requiring n8n or custom development. See the "Game-Changing Discoveries" section above for details.

### Key Features

- ⚡ **Quick Capture**: Siri → Todoist → AI Auto-tagged → Notion (< 5 seconds)
- 🤖 **AI Auto-Tagging**: Smart categorization (@work/@personal/@urgent/@code/@research)
- 🔄 **Bidirectional Sync**: Notion ↔ Todoist via n8n webhooks (real-time, conflict-free)
- 🧠 **Multi-Agent AI**: OpenAI/Claude nodes for intelligent task processing
- 🔐 **1Password Integration**: Service Account for secure secret management (no hardcoded tokens)
- 📱 **ADHD-Optimized**: Backend-only workflow, minimal context-switching, < 5s capture

## Current Architecture (n8n-Based)

```
┌─────────────────────────────────────────────────────┐
│           NOTION (Ultimate Source of Truth)          │
│                                                      │
│  📋 To Do Database                                   │
│  • Title, Due Date, Priority, Status                 │
│  • Auto_Tags (AI-generated)                          │
│  • Todoist_ID (deduplication)                        │
│  • Last_Synced (conflict resolution)                 │
└──────────────────────┬──────────────────────────────┘
                       ↑
                       │ (bidirectional sync)
                       ↓
┌─────────────────────────────────────────────────────┐
│              n8n WORKFLOW (€20/mo Starter)           │
│                                                      │
│  Triggers:                                           │
│  • Todoist Webhook (real-time)                       │
│  • Notion Database Trigger                           │
│  • Schedule (every 5 min - catch-all)                │
│                                                      │
│  AI Processing:                                      │
│  • OpenAI/Claude node (auto-tagging)                 │
│  • Confidence scoring (>70% = auto-apply)            │
│  • Project suggestion (keyword-based)                │
│                                                      │
│  Sync Logic:                                         │
│  • IF node (direction detection)                     │
│  • Switch node (conflict resolution)                 │
│  • Set node (metadata storage)                       │
│  • Error logging (Sync Errors database)              │
└───┬──────────────┬──────────────┬─────────────┬─────┘
    ↓              ↓              ↓             ↓
  Todoist      Webhooks      Email         Notion
 (Inbox)      (GitHub)    (Errors)    (Sync Errors)
```

**Why n8n?**

- ✅ €20/mo (vs Motion $49/mo, Zapier $20+ hidden costs)
- ✅ All AI features included (multi-agent, LangChain, local LLM)
- ✅ 2,500 executions/month (unlimited steps per execution)
- ✅ Template exists (3-5 hours setup vs 40+ hours custom)
- ✅ Self-hostable (open-source, no vendor lock-in)

See [STRATEGIC-VALUE-ANALYSIS.md](docs/STRATEGIC-VALUE-ANALYSIS.md) for full comparison.

## Quick Start

### Prerequisites

**Option 1: Raycast + GitHub Copilot CLI (Simplest)**

- Raycast app installed
- GitHub Copilot subscription
- Raycast extensions: GitHub Copilot, Notion, Todoist (all use OAuth)
- GitHub Copilot CLI (`gh copilot` command)

**Option 2: n8n Workflow Automation (Advanced)**

- n8n account (Starter plan: €20/mo, or self-host Community Edition for FREE)
- Notion account + API integration
- Todoist account (free tier works)
- 1Password (optional, for secret management)

### Setup

**Option 1: Raycast + Copilot CLI (< 30 minutes)**

1. Install Raycast extensions:
   - GitHub Copilot extension (OAuth)
   - Notion extension (OAuth)
   - Todoist extension (OAuth)

2. Install GitHub CLI and Copilot extension:
   ```bash
   # Install GitHub CLI
   brew install gh
   
   # Install Copilot CLI extension
   gh extension install github/gh-copilot
   
   # Authenticate
   gh auth login
   ```

3. Add MCP servers to Copilot CLI:
   ```bash
   # Launch Copilot CLI
   gh copilot
   
   # Add Notion MCP server
   /mcp add
   # Configure: makenotion/notion-mcp-server
   
   # Add other MCP servers as needed
   /mcp add
   ```

4. Start using:
   - Quick capture via Raycast → Todoist
   - Manage tasks via Raycast → Notion
   - Automate via GitHub Copilot CLI with MCP servers

**Option 2: n8n Cloud (3-5 hours)**

1. Sign up at [n8n.io](https://n8n.io/pricing/) (7-day free trial)
2. Click "Build with AI" in workflow editor
3. Paste combined n8n prompt (see below)
4. Configure credentials (Notion OAuth, Todoist API)
5. Test sync

**Option 3: Self-Host n8n Community (FREE)**

```bash
# Docker
docker run -it --rm --name n8n -p 5678:5678 -v ~/.n8n:/home/node/.n8n n8nio/n8n

# Access at http://localhost:5678
# Follow same setup as Option A
```

**Combined n8n AI Prompt:** See [docs/n8n-prompt.md](docs/n8n-prompt.md) for the complete prompt (bidirectional sync + AI auto-tagging + conflict resolution + error handling).

**Notion Database Setup:**

1. Create "To Do" database in Notion with properties:
   - Title (text)
   - Due Date (date)
   - Priority (select: High/Medium/Low)
   - Status (select: To Do/In Progress/Done)
   - Tags (multi-select)
   - Auto_Tags (multi-select) - AI-generated
   - Todoist_ID (text) - for deduplication
   - Last_Synced (date) - conflict resolution

2. Share database with n8n Notion integration

3. Configure Todoist webhook in n8n (copy webhook URL from n8n node)

See [docs/SETUP.md](docs/SETUP.md) for detailed instructions.

## Workflow Examples

### Voice Capture → Auto-Everything

```
1. Siri: "Add to Todoist: Research OAuth by Friday priority 2"
2. Todoist creates task with natural language parsing
3. Webhook → MCP Orchestrator
4. Orchestrator:
   - Auto-tags: @research, @work
   - Confirms priority: 2
   - Syncs to Google Calendar
   - Saves to Notion for context
5. Available in Copilot for future OAuth questions
```

### Task Delegation to Agents

```
1. Task created: "Research OAuth 2.0 implementations @research"
2. Orchestrator detects @research tag
3. Triggers Copilot Agent:
   - Searches GitHub repositories
   - Reads documentation
   - Creates summary in Notion
   - Updates Todoist task with findings
4. Notification: "Research complete, review in Notion"
```

### Recurring Task with Logging

```
1. Complete: "Clean coffee machine" (4-week recurring)
2. Orchestrator logs to Notion:
   - Completion date
   - Streak count
   - Time taken
3. Todoist auto-creates next occurrence (4 weeks)
4. Notion tracks consistency patterns
```

## Repository Structure

```
mcp-orchestrator-one-truth-repository/
├── orchestrator/              # Core TypeScript service
│   ├── src/
│   │   ├── sync/             # Notion/Todoist sync engines
│   │   ├── webhooks/         # Event receivers
│   │   ├── agents/           # AI task delegation
│   │   └── secrets/          # 1Password integration
│   └── Dockerfile
│
├── mcp-servers/               # MCP protocol implementations
│   ├── notion/               # Notion MCP server
│   ├── todoist/              # Todoist MCP server
│   ├── onepassword/          # 1Password MCP server (read-only)
│   └── orchestrator/         # Meta-operations MCP server
│
├── raycast-extensions/        # Quick capture scripts
│   ├── quick-task.sh         # Siri → Todoist
│   ├── save-to-notion.sh     # Clipboard → Notion
│   └── search-everything.sh  # Unified search
│
├── agents/                    # Copilot Agent configurations
│   ├── research-agent.yml    # GitHub + docs research
│   ├── code-agent.yml        # Implementation tasks
│   └── summary-agent.yml     # Content synthesis
│
├── scripts/                   # Automation utilities
│   ├── setup.sh              # One-shot environment setup
│   ├── configure-1password.sh # Service Account wizard
│   └── health-check.sh       # System diagnostics
│
└── docs/                      # Comprehensive guides
    ├── SETUP.md              # Installation walkthrough
    ├── ADHD-OPTIMIZATIONS.md # Workflow patterns
    ├── TODOIST-INTEGRATION.md # Webhook configuration
    └── AGENTS-GUIDE.md       # Copilot Agent usage
```

## Documentation

- **[SETUP.md](docs/SETUP.md)** - Detailed installation and configuration
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design and data flows
- **[ADHD-OPTIMIZATIONS.md](docs/ADHD-OPTIMIZATIONS.md)** - Workflow best practices
- **[TODOIST-INTEGRATION.md](docs/TODOIST-INTEGRATION.md)** - Webhook setup guide
- **[1PASSWORD-ENVIRONMENTS.md](docs/1PASSWORD-ENVIRONMENTS.md)** - Service Account usage
- **[MCP-PROTOCOL.md](docs/MCP-PROTOCOL.md)** - Server implementation guide
- **[AGENTS-GUIDE.md](docs/AGENTS-GUIDE.md)** - Copilot Agent configuration
- **[REMOTE-DEV.md](docs/REMOTE-DEV.md)** - Codespaces + Tailscale setup
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## Development

### Running Locally

```bash
# Start orchestrator in development mode
cd orchestrator
npm run dev

# Run MCP servers
cd mcp-servers/notion
npm start
```

### Running in Docker

```bash
# Build and start all services
docker-compose up --build

# View logs
docker-compose logs -f orchestrator

# Stop services
docker-compose down
```

### Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

### Remote Development

See [docs/REMOTE-DEV.md](docs/REMOTE-DEV.md) for Codespaces setup.

## Contributing

This is a personal workflow automation project, but feel free to fork and adapt for your needs!

### Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(orchestrator): add bidirectional sync
fix(mcp-todoist): handle timeout errors
docs(setup): add 1Password steps
chore(deps): upgrade @notionhq/client
```

### Versioning

Semantic Versioning with VERSION file. Use `scripts/bump_version.sh` to increment.

## Meta

This project uses automation patterns from [ai-meta](https://github.com/Kingy2709/ai-meta) as a foundation for validation, versioning, and CI workflows.

## License

MIT © 2025 Kingy2709

## Acknowledgments

- **Model Context Protocol**: <https://modelcontextprotocol.io>
- **1Password SDKs**: <https://developer.1password.com>
- **Notion API**: <https://developers.notion.com>
- **Todoist API**: <https://developer.todoist.com>
