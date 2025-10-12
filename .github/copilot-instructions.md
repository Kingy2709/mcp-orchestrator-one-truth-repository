# MCP Orchestrator Project Instructions

## Project Context
This is a TypeScript/Node.js orchestrator service that provides a single source of truth across AI tools (Notion, Todoist, GitHub Copilot) using the Model Context Protocol (MCP).

## Architecture
- **Main Service**: orchestrator/ - Core TypeScript service running as Mac daemon
- **MCP Servers**: mcp-servers/ - Protocol implementations for Notion, Todoist, 1Password, meta-operations
- **Extensions**: raycast-extensions/ - Quick capture scripts
- **Agents**: agents/ - Copilot agent configurations for task delegation
- **Runtime**: Docker Compose multi-service setup, PM2 process manager

## Development Guidelines

### Code Style
- **TypeScript**: Strict mode enabled, explicit types required
- **Naming**: camelCase for variables/functions, PascalCase for classes/types
- **Imports**: Absolute paths using tsconfig paths
- **Errors**: Custom error classes in utils/errors.ts
- **Logging**: Use winston logger, structured JSON logs

### Commit Standards
- **Convention**: Conventional Commits (feat, fix, refactor, docs, test, chore)
- **Scope**: Component name (orchestrator, mcp-notion, raycast, docs)
- **Examples**:
  - `feat(orchestrator): add bidirectional Notion sync`
  - `fix(mcp-todoist): handle webhook timeout`
  - `docs(setup): add 1Password Service Account steps`

### Testing
- **Framework**: Jest with ts-jest
- **Coverage**: Minimum 70% for new code
- **Location**: `__tests__` folders adjacent to source
- **Naming**: `*.test.ts` pattern

### Security
- **Secrets**: 1Password Service Account only (no hardcoded tokens)
- **Env**: .env.template with ${PLACEHOLDER} comments
- **Validation**: Zod schemas for all config and external data
- **Audit**: Log all external API calls

### ADHD-Optimized Workflows
- **Quick Capture**: Siri → Todoist → Orchestrator (< 5 seconds)
- **Auto-Tagging**: AI rules for @work/@personal/@urgent
- **Backend Only**: Minimize UI interaction, live in Calendar/Raycast
- **Task Grouping**: AI detects similar tasks, suggests projects
- **Agent Delegation**: @research/@code tags trigger Copilot Agents

### Remote Development
- **Codespaces**: Full Docker support in devcontainer
- **Tailscale**: Tunnel to Mac for testing local orchestrator
- **Port Forwarding**: 3000 (orchestrator), 5432 (if Postgres added)

## Key Dependencies
- @notionhq/client - Notion API SDK
- @doist/todoist-api-typescript - Todoist SDK
- @1password/sdk - Service Account integration
- @modelcontextprotocol/sdk - MCP protocol implementation
- express - Webhook server
- winston - Structured logging
- zod - Runtime type validation

## File Structure Conventions
- `src/index.ts` - Service entry point
- `src/config.ts` - Environment loading with Zod validation
- `src/**/*.ts` - Feature modules (sync, webhooks, agents)
- `src/utils/` - Shared utilities (logger, errors)
- `__tests__/` - Test files adjacent to source

## References
- Automation patterns extracted from [ai-meta](https://github.com/Kingy2709/ai-meta)
- MCP Protocol: https://modelcontextprotocol.io
- 1Password Service Accounts: https://developer.1password.com/docs/service-accounts
