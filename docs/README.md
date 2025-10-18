# Documentation

Comprehensive documentation for the MCP Orchestrator project using n8n for bidirectional task sync between Todoist and Notion.

## Quick Navigation

### 🚀 Getting Started

- **[Setup Guides](./setup/)** - Complete setup instructions (1Password, n8n, GitHub Copilot)
- **[Quick Start](./setup/README.md#quick-start)** - Recommended order and time estimates

### 📚 Core Documentation

- **[Architecture](../ARCHITECTURE.md)** - System design and n8n workflow details
- **[README](../README.md)** - Project overview and current status
- **[CHANGELOG](../CHANGELOG.md)** - Version history and changes

### 🏗️ Architecture & Decisions

- **[Strategic Value Analysis](./architecture/STRATEGIC-VALUE-ANALYSIS.md)** - n8n vs Zapier vs Motion comparison
- **[Lessons Learned](./architecture/LESSONS-LEARNED.md)** - R&D process improvements
- **[Decision Records](./architecture/decisions/)** - ADR-001 (use n8n), ADR-002 (reject Motion)
- **[MCP Integration Status](./architecture/MCP-INTEGRATION-STATUS.md)** - 40% redundancy post-mortem

### 🔧 Setup & Configuration

- **[1Password](./setup/1password.md)** - Service Account and credential management
- **[n8n Setup](./setup/n8n.md)** - Workflow configuration and deployment
- **[Setup Checklist](./setup/README.md)** - Prerequisites and time estimates

### 🔌 Integrations

- **[GitHub Copilot](./integrations/github-copilot.md)** - MCP servers and agent delegation
- **[Notion](./integrations/NOTION-INTEGRATION.md)** - API integration details
- **[Raycast](./integrations/raycast.md)** - Quick capture scripts
- **[MCP Servers](./integrations/MCP-SERVER-SETUP.md)** - Model Context Protocol configuration

### ⚡ Workflows & Optimizations

- **[ADHD Optimizations](./workflows/adhd-optimizations.md)** - 5-second capture, auto-tagging, agent delegation
- **[iOS Development](./workflows/ios-development.md)** - Siri shortcuts and mobile workflow

### 📖 Best Practices

- **[GitHub Repository Best Practices](./GITHUB-BEST-PRACTICES.md)** - File naming, commits, tags, branches, ADRs
- **[Notion Workspace Architecture](./NOTION-WORKSPACE-ARCHITECTURE.md)** - Database design and organization

---

## Documentation Structure

```
docs/
├── README.md                            # This file
├── GITHUB-BEST-PRACTICES.md             # Repository standards
├── NOTION-WORKSPACE-ARCHITECTURE.md     # Workspace design guide
│
├── setup/                               # Setup guides
│   ├── README.md                        # Setup checklist
│   ├── 1password.md                     # Credential management
│   └── n8n.md                           # Workflow configuration
│
├── architecture/                        # Strategic decisions
│   ├── STRATEGIC-VALUE-ANALYSIS.md      # n8n vs alternatives
│   ├── LESSONS-LEARNED.md               # Process improvements
│   ├── MCP-INTEGRATION-STATUS.md        # Redundancy analysis
│   ├── ORCHESTRATOR-UNIQUENESS-VERIFICATION.md
│   └── decisions/
│       ├── ADR-001-use-n8n-over-custom.md
│       └── ADR-002-reject-motion.md
│
├── integrations/                        # External service integrations
│   ├── github-copilot.md                # MCP & agent setup
│   ├── NOTION-INTEGRATION.md            # API details
│   ├── NOTION-DEVELOPER-REFERENCE.md    # Developer guide
│   ├── MCP-SERVER-SETUP.md              # Protocol configuration
│   └── raycast.md                       # Quick capture scripts
│
└── workflows/                           # Workflow optimizations
    ├── adhd-optimizations.md            # ADHD-friendly features
    └── ios-development.md               # Mobile workflow
```

---

## For New Users

**Start Here:**

1. Read [README.md](../README.md) - Understand project purpose and current status
2. Review [Architecture](../ARCHITECTURE.md) - See how n8n workflow operates
3. Follow [Setup Checklist](./setup/README.md) - Configure 1Password and n8n (60 min)
4. Test sync - Create Todoist task, verify appears in Notion
5. Explore [ADHD Optimizations](./workflows/adhd-optimizations.md) - Tune for your workflow

**Time Investment:** ~90 minutes to fully operational system

---

## For Developers

**Understand Architecture:**

1. [ARCHITECTURE.md](../ARCHITECTURE.md) - n8n workflow design
2. [Strategic Value Analysis](./architecture/STRATEGIC-VALUE-ANALYSIS.md) - Why n8n over custom
3. [ADR-001](./architecture/decisions/ADR-001-use-n8n-over-custom.md) - Decision rationale
4. [GitHub Best Practices](./GITHUB-BEST-PRACTICES.md) - Repository standards

**Extend System:**

1. [GitHub Copilot Integration](./integrations/github-copilot.md) - Add agent delegation
2. [n8n Setup](./setup/n8n.md#workflow-configuration) - Customize workflow nodes
3. [Notion Developer Reference](./integrations/NOTION-DEVELOPER-REFERENCE.md) - API details

---

## For Maintenance

**Regular Tasks:**

- **Weekly**: Review [Sync Errors](./setup/n8n.md#monitoring) database in Notion
- **Monthly**: Check [n8n execution quota](./setup/n8n.md#troubleshooting) (< 2,000/2,500)
- **Quarterly**: [Rotate API tokens](./setup/1password.md#rotation-workflow) in 1Password

**Troubleshooting Guides:**

- [1Password Issues](./setup/1password.md#troubleshooting)
- [n8n Workflow Issues](./setup/n8n.md#troubleshooting)
- [GitHub Copilot Issues](./integrations/github-copilot.md#troubleshooting)

---

## Contributing

**Before Making Changes:**

1. Read [GitHub Best Practices](./GITHUB-BEST-PRACTICES.md) - File naming, commits, branches
2. Check [Lessons Learned](./architecture/LESSONS-LEARNED.md) - Avoid past mistakes
3. Follow [Conventional Commits](./GITHUB-BEST-PRACTICES.md#conventional-commits) - Format commits properly

**Creating ADRs:**

1. Copy [ADR template](./GITHUB-BEST-PRACTICES.md#adr-template)
2. Save to `docs/architecture/decisions/ADR-XXX-short-title.md`
3. Link from [CHANGELOG.md](../CHANGELOG.md)

---

## External Resources

### Official Documentation

- [n8n Documentation](https://docs.n8n.io/)
- [Notion API Reference](https://developers.notion.com/reference)
- [Todoist API Reference](https://developer.todoist.com/rest/v2)
- [GitHub Copilot](https://github.com/features/copilot)
- [Model Context Protocol](https://modelcontextprotocol.io/)

### Community

- [n8n Community Forum](https://community.n8n.io/)
- [Notion Developers Slack](https://developers.notion.com/community)
- [GitHub Issues](https://github.com/Kingy2709/mcp-orchestrator-one-truth-repository/issues)

---

## License

MIT License - See [LICENSE](../LICENSE) for details.

---

## Feedback

Questions or suggestions? [Open an issue](https://github.com/Kingy2709/mcp-orchestrator-one-truth-repository/issues/new)!
