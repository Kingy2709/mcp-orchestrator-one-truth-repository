# MCP Servers

This directory contains Model Context Protocol (MCP) server implementations for each integrated service.

## Available Servers

- **notion/** - Notion API wrapper exposing Notion operations as MCP tools
- **todoist/** - Todoist API wrapper for task management
- **onepassword/** - 1Password Service Account integration (read-only)
- **orchestrator/** - Meta-operations for orchestrator control

## Running Servers

Each server can run independently:

```bash
# Notion MCP server
cd notion
npm install
npm start

# Todoist MCP server
cd todoist
npm install
npm start
```

## MCP Protocol

All servers implement the [Model Context Protocol](https://modelcontextprotocol.io) specification and can be used by any MCP-compatible client (e.g., GitHub Copilot, Claude Desktop).

## Configuration

Servers load configuration from environment variables (managed by 1Password Service Account in production).
