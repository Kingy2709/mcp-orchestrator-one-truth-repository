# Setup Guides

Complete setup instructions for the MCP Orchestrator project.

## Quick Start

**Recommended order:**

1. **[1Password Configuration](./1password.md)** - Set up Service Account for credential management (15 min)
2. **[n8n Workflow Setup](./n8n.md)** - Configure bidirectional sync with AI auto-tagging (30-60 min)
3. **[GitHub Copilot Integration](../integrations/github-copilot.md)** - Connect MCP servers (optional, 15 min)

## Setup Checklist

### Prerequisites

- [ ] Notion workspace with API integration
- [ ] Todoist account (free or premium)
- [ ] 1Password account (for Service Account)
- [ ] OpenAI or Claude API key
- [ ] n8n account (free trial or self-hosted)

### 1Password Setup (Required)

- [ ] Create Service Account
- [ ] Grant access to "Automation" vault
- [ ] Store API credentials (Notion, Todoist, OpenAI)
- [ ] Test credential retrieval

See: [1password.md](./1password.md)

### n8n Setup (Required)

- [ ] Sign up for n8n Cloud or install self-hosted
- [ ] Generate workflow with "Build with AI" prompt
- [ ] Connect credentials (Notion OAuth, Todoist API, OpenAI API)
- [ ] Configure Todoist webhook
- [ ] Test bidirectional sync

See: [n8n.md](./n8n.md)

### GitHub Copilot Integration (Optional)

- [ ] Install official Notion MCP server
- [ ] Configure Copilot with 1Password injection
- [ ] Test MCP server in Copilot Chat
- [ ] Set up Copilot Agent workflows (research-agent, code-agent)

See: [../integrations/github-copilot.md](../integrations/github-copilot.md)

## Time Estimates

| Task | Time | Difficulty |
|------|------|------------|
| 1Password Service Account | 15 min | Easy |
| n8n Cloud Setup | 30 min | Medium |
| n8n Self-Hosted | 60 min | Hard |
| Copilot MCP Integration | 15 min | Easy |
| **Total (Cloud)** | **60 min** | **Medium** |
| **Total (Self-Hosted)** | **90 min** | **Hard** |

## Troubleshooting

Common issues and solutions:

### 1Password

- **"Item not found"** → Service Account needs vault access
- **"Invalid field reference"** → Check field name (`credential` vs `token`)
- See full guide: [1password.md](./1password.md#troubleshooting)

### n8n

- **Webhook not triggered** → Check URL in Todoist settings
- **Notion authentication failed** → Re-authorize OAuth
- **Duplicate tasks** → Check deduplication hash function
- See full guide: [n8n.md](./n8n.md#troubleshooting)

### GitHub Copilot

- **MCP server not found** → Check `~/.copilot/config.json`
- **Authentication error** → Launch VS Code with `op run -- code .`
- See full guide: [../integrations/github-copilot.md](../integrations/github-copilot.md#troubleshooting)

## Next Steps

After setup:

1. **Optimize workflow**: [../workflows/adhd-optimizations.md](../workflows/adhd-optimizations.md)
2. **Review architecture**: [../../ARCHITECTURE.md](../../ARCHITECTURE.md)
3. **Read best practices**: [../GITHUB-BEST-PRACTICES.md](../GITHUB-BEST-PRACTICES.md)

## Support

- **Documentation**: Browse [docs/](../) folder
- **GitHub Issues**: [Create issue](https://github.com/Kingy2709/mcp-orchestrator-one-truth-repository/issues)
- **n8n Community**: [community.n8n.io](https://community.n8n.io/)
- **MCP Protocol**: [modelcontextprotocol.io](https://modelcontextprotocol.io/)
