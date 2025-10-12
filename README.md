# MCP Orchestrator - One Truth Repository

**Single source of truth across all AI-injected tools**

Transform your ADHD-optimized workflow into a seamless orchestration layer connecting Notion, Todoist, GitHub Copilot, and 1Password via the Model Context Protocol (MCP).

## Overview

This orchestrator runs as a background service on your Mac, automatically syncing tasks, knowledge, and context across your AI tools. Capture thoughts via Siri, auto-tag with AI, delegate to Copilot Agents, and maintain a canonical source of truth in Notion—all without context-switching.

### Key Features

- ⚡ **Quick Capture**: Siri → Todoist → Auto-tagged → Notion (< 5 seconds)
- 🤖 **Agent Delegation**: @research/@code tags trigger Copilot Agents automatically
- 🔄 **Bidirectional Sync**: Notion ↔ Todoist ↔ Google Calendar (conflict-free)
- 🏷️ **AI Auto-Tagging**: Smart categorization (@work/@personal/@urgent)
- 📦 **Task Grouping**: AI detects similar tasks, suggests projects
- 🔐 **1Password Integration**: Service Account for secure secret management
- 📱 **Remote Dev**: Code from iPhone/iPad via Codespaces + Tailscale

## Architecture

```
┌─────────────────────────────────────────────────────┐
│           NOTION (Ultimate Source of Truth)          │
│                                                      │
│  Knowledge Base | Tasks/Projects | API Logs         │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│        MCP ORCHESTRATOR (Running on Mac)             │
│                                                      │
│  Core Services:                                      │
│  • Notion Sync Engine                                │
│  • Todoist Bidirectional Sync                        │
│  • 1Password Service Account Integration             │
│  • Raycast Bridge                                    │
│  • GitHub Webhook Receiver                           │
│  • Agent Task Delegator                              │
│                                                      │
│  MCP Servers:                                        │
│  • Notion MCP (read/write)                           │
│  • Todoist MCP (tasks)                               │
│  • 1Password MCP (secrets - read only)               │
│  • Orchestrator MCP (meta-operations)                │
└───┬──────────────┬──────────────┬─────────────┬─────┘
    │              │              │             │
    ▼              ▼              ▼             ▼
Copilot        Raycast        Todoist      1Password
(+Agents)                    (+Google Cal)
```

## Quick Start

### Prerequisites

- macOS (Apple Silicon or Intel)
- Node.js 20+ (LTS)
- Docker Desktop
- 1Password CLI + Service Account
- Todoist Premium (for Google Calendar sync)
- Notion API key
- GitHub Copilot Pro+ (for agents)

### Installation

```bash
# Clone repository
git clone https://github.com/Kingy2709/mcp-orchestrator-one-truth-repository.git
cd mcp-orchestrator-one-truth-repository

# Run setup script (installs dependencies, configures 1Password)
./scripts/setup.sh

# Configure environment (follow prompts for API keys)
./scripts/configure-1password.sh

# Start orchestrator
docker-compose up -d

# Verify health
./scripts/health-check.sh
```

See [docs/SETUP.md](docs/SETUP.md) for detailed installation instructions.

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

- **Model Context Protocol**: https://modelcontextprotocol.io
- **1Password SDKs**: https://developer.1password.com
- **Notion API**: https://developers.notion.com
- **Todoist API**: https://developer.todoist.com
