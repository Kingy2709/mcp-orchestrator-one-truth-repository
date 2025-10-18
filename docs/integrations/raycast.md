# Raycast Developer Reference

Complete guide to Raycast extensions, MCP integration, AI capabilities, and development workflow.

---

## Quick Links

- **MCP Extension**: https://github.com/raycast/extensions/tree/main/extensions/mcp
- **MCP README**: https://github.com/raycast/extensions/blob/main/extensions/mcp/README.md
- **Developer Documentation**: https://developers.raycast.com/
- **Extension Repository**: https://github.com/raycast/extensions
- **Copilot Instructions**: https://github.com/raycast/extensions/blob/main/.github/copilot-instructions.md

---

## Table of Contents

1. [CRITICAL: Raycast DOES Support MCP](#critical-raycast-does-support-mcp)
2. [Raycast MCP Extension](#raycast-mcp-extension)
3. [Extension Architecture](#extension-architecture)
4. [Extension Types](#extension-types)
5. [File Structure](#file-structure)
6. [package.json Manifest](#packagejson-manifest)
7. [Raycast AI Capabilities](#raycast-ai-capabilities)
8. [Development Workflow](#development-workflow)
9. [API Reference](#api-reference)
10. [Best Practices](#best-practices)
11. [Security](#security)
12. [Publishing Extensions](#publishing-extensions)
13. [Comparison with Our Project](#comparison-with-our-project)

---

## CRITICAL: Raycast DOES Support MCP

### I Was Wrong - Raycast Has Full MCP Support! 🎉

**What Raycast Has**:
- ✅ **MCP Extension**: Official extension in `extensions/mcp`
- ✅ **Manage MCP Servers** command (UI for adding/removing servers)
- ✅ **mcp-config.json**: Similar to Claude Desktop config
- ✅ **@mcp prefix**: Use MCP tools in Raycast AI
- ✅ **Local/Development servers**: Write custom MCP servers

### How Raycast MCP Works

```
Raycast AI
│
├─► Type "@mcp" prefix
├─► Raycast MCP Extension kicks in
├─► Loads mcp-config.json
├─► Connects to all configured MCP servers
└─► AI chooses appropriate tool to use
```

**Key Insight**: Raycast MCP extension acts as a bridge between Raycast AI and ANY MCP server (including our custom Notion MCP server!)

---

## Raycast MCP Extension

### What It Does

The Raycast MCP extension (`extensions/mcp`) allows Raycast AI to:
1. Connect to ANY MCP server (filesystem, notion, custom, etc.)
2. Expose MCP tools to Raycast AI
3. Use tools automatically when you type `@mcp` in Quick AI or AI Chat

### Installation & Setup

**Step 1: Install MCP Extension**
```bash
# In Raycast:
# 1. Open "Manage Extensions"
# 2. Search "MCP"
# 3. Click "Install"
```

**Step 2: Add MCP Servers (via UI)**
```
1. Open "Manage MCP Servers" command
2. Press Cmd+N to add new server
3. Paste server JSON configuration
4. Modify fields (API keys, allowed directories, etc.)
5. Submit
```

**Example: Adding Filesystem Server**
```json
{
  "filesystem": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-filesystem",
      "/Users/YOUR_USERNAME/Desktop",
      "/path/to/other/allowed/dir"
    ]
  }
}
```

**Step 3: Add Our Custom Notion MCP Server**
```json
{
  "notion": {
    "command": "node",
    "args": [
      "/Users/YOUR_USERNAME/dev/mcp-orchestrator/mcp-servers/notion/dist/index.js"
    ],
    "env": {
      "NOTION_TOKEN": "ntn_your_token_here"
    }
  }
}
```

### mcp-config.json Location

All MCP servers are stored in a single config file:

**Path**: `~/Library/Application Support/com.raycast.macos/extensions/mcp/mcp-config.json`

**Access**:
- Open "Manage MCP Servers" command
- Action: "Show Config File in Finder"

**Format**:
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx|node",
      "args": ["..."],
      "env": { "API_KEY": "..." }
    }
  }
}
```

### Adding Local/Development Server

**Step 1: Find Servers Folder**
```
1. Open "Manage MCP Servers" command
2. Action: "Open Servers Folder"
3. Location: Same directory as mcp-config.json
```

**Step 2: Create Subfolder**
```bash
cd ~/Library/Application\ Support/com.raycast.macos/extensions/mcp
mkdir my-custom-server
cd my-custom-server
```

**Step 3: Write MCP Server**
Create `index.js` with MCP server code:
```javascript
// index.js
const { Server } = require('@modelcontextprotocol/sdk');

const server = new Server({
  name: 'my-custom-server',
  version: '1.0.0'
});

// ... implement tools

server.connect(process.stdin, process.stdout);
```

**Step 4: Add package.json**
```json
{
  "name": "my-custom-server",
  "version": "1.0.0",
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0"
  }
}
```

**Step 5: Extension Auto-Installs Dependencies**
Raycast MCP extension automatically runs `npm install` on next launch.

**Note**: Only JavaScript is supported for now (TypeScript must be compiled first).

### Using MCP Servers in Raycast AI

**Step 1: Open Raycast AI**
- Quick AI: Cmd+Space → type query
- AI Chat: Cmd+Space → "AI Chat"

**Step 2: Use @mcp Prefix**
```
@mcp Show me files in my Desktop folder

@mcp Create a Notion page for project planning

@mcp Analyze the error in server.log
```

**Step 3: AI Automatically Chooses Tool**
- Raycast AI sees all available MCP servers
- AI selects appropriate tool based on request
- Executes tool and returns results

**No additional setup needed** - just type `@mcp` and ask!

---

## Extension Architecture

### Raycast Extensions Are NOT Just Shell Scripts!

**What I Got Wrong**:
- ❌ "Raycast extensions are shell scripts"
- ❌ "Raycast calls HTTP APIs via curl"
- ❌ "Raycast doesn't have rich UI"

**What Raycast Extensions Actually Are**:
- ✅ Full TypeScript/React applications
- ✅ npm packages with dependencies
- ✅ Rich UI components (List, Form, Detail, Grid, Action Panel)
- ✅ Built-in APIs (AI, Clipboard, Cache, Environment, etc.)
- ✅ Development tools (CLI, VS Code extension, hot reloading)

### Extension Structure

```
my-extension/
├── package.json          # Manifest (commands, tools, dependencies)
├── tsconfig.json         # TypeScript configuration
├── eslint.config.mjs     # ESLint rules
├── .prettierrc           # Prettier formatting
├── assets/
│   └── icon.png          # Extension icon
├── src/
│   ├── index.tsx         # Main command entry point
│   ├── search.tsx        # Search command
│   └── create.tsx        # Create command
└── node_modules/         # Dependencies
```

### Key Difference from Our Current Setup

**Our Current Raycast "Extension"**:
```bash
# raycast-extensions/quick-task.sh
#!/bin/bash
curl -X POST http://localhost:3000/api/capture -d "{\"task\": \"$1\"}"
```

**What It Should Be**:
```typescript
// raycast-extensions/src/quick-capture.tsx
import { Form, ActionPanel, Action, showToast, Toast } from "@raycast/api";
import { useState } from "react";

export default function QuickCapture() {
  const [task, setTask] = useState("");

  async function handleSubmit(values: { task: string }) {
    try {
      await fetch("http://localhost:3000/api/capture", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ task: values.task })
      });

      await showToast({
        style: Toast.Style.Success,
        title: "Task captured!",
        message: values.task
      });
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Failed to capture task",
        message: String(error)
      });
    }
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="Capture Task" onSubmit={handleSubmit} />
        </ActionPanel>
      }
    >
      <Form.TextField
        id="task"
        title="Task"
        placeholder="What do you need to do?"
        value={task}
        onChange={setTask}
      />
    </Form>
  );
}
```

---

## Extension Types

### 1. Regular Commands

**View Commands**: Display UI (List, Detail, Form, Grid)
```typescript
// src/search.tsx
import { List } from "@raycast/api";

export default function SearchCommand() {
  return (
    <List>
      <List.Item title="Item 1" />
      <List.Item title="Item 2" />
    </List>
  );
}
```

**No-View Commands**: Background execution (no UI)
```typescript
// src/sync.ts
export default async function SyncCommand() {
  // Perform sync operation
  await performSync();
}
```

### 2. AI Extensions (Tools)

**AI Tools**: Natural language interactions in Quick AI/AI Chat
```json
{
  "tools": [
    {
      "name": "search_tasks",
      "title": "Search Tasks",
      "description": "Search for tasks across Notion and Todoist",
      "mode": "no-view"
    }
  ],
  "ai": {
    "evals": [
      {
        "input": "Find my overdue tasks",
        "expected": [
          {
            "callsTool": {
              "name": "search_tasks",
              "arguments": {
                "filter": {
                  "includes": "overdue"
                }
              }
            }
          }
        ]
      }
    ]
  }
}
```

### 3. Script Commands

**Shell Scripts**: Simple scripts (our current approach)
```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Quick Task
# @raycast.mode silent

# Documentation:
# @raycast.description Capture a task quickly
# @raycast.author Your Name

echo "Task captured!"
```

**When to use**:
- Simple operations
- No UI needed
- Quick prototypes

**When NOT to use**:
- Need rich UI
- Error handling
- API interactions
- State management

---

## File Structure

### Typical Extension Directory

```
extension/
├── .eslintrc.json        # ESLint configuration
├── .prettierrc           # Prettier formatting rules
├── assets/
│   ├── icon.png          # Extension icon (512x512)
│   ├── command-icon.png  # Command-specific icon
│   └── list-icon.png     # List item icon
├── metadata/             # Required for new extensions
│   ├── screenshot-1.png  # Store listing screenshots
│   └── screenshot-2.png
├── node_modules/         # Dependencies (auto-installed)
├── package-lock.json     # Lock file (npm only, no yarn/pnpm)
├── package.json          # Extension manifest
├── src/
│   ├── index.tsx         # Main command entry point
│   ├── components/       # Reusable UI components
│   ├── utils/            # Utility functions
│   └── types.ts          # TypeScript types
└── tsconfig.json         # TypeScript configuration
```

### Required Files

1. **package.json**: Manifest with extension/command metadata
2. **src/[command-name].tsx**: Entry point for each command
3. **assets/icon.png**: Extension icon (512x512 PNG)
4. **metadata/**: Screenshots (required for new extensions with view commands)

### Optional but Recommended

- **.prettierrc**: Code formatting (Raycast standard)
- **eslint.config.mjs**: Linting rules
- **tsconfig.json**: TypeScript configuration
- **README.md**: Extension documentation
- **CHANGELOG.md**: Version history

---

## package.json Manifest

### Extension Properties

```json
{
  "name": "my-extension",
  "title": "My Extension",
  "description": "Extension description for store listing",
  "icon": "icon.png",
  "author": "your-github-username",
  "platforms": ["macOS", "Windows"],
  "categories": ["Productivity", "Developer Tools"],
  "license": "MIT",
  "keywords": ["notion", "tasks", "sync"],

  "commands": [
    {
      "name": "search",
      "title": "Search Tasks",
      "subtitle": "Notion & Todoist",
      "description": "Search across all your tasks",
      "mode": "view",
      "preferences": [
        {
          "name": "apiToken",
          "type": "password",
          "required": true,
          "title": "API Token",
          "description": "Your Notion API token"
        }
      ]
    }
  ],

  "tools": [
    {
      "name": "create_task",
      "title": "Create Task",
      "description": "Create a new task in Notion or Todoist",
      "mode": "no-view"
    }
  ],

  "ai": {
    "evals": [...]
  },

  "dependencies": {
    "@raycast/api": "^1.70.0",
    "@raycast/utils": "^1.14.0",
    "@notionhq/client": "^2.2.15"
  },

  "devDependencies": {
    "@types/node": "^20.10.6",
    "@types/react": "^18.2.46",
    "typescript": "^5.3.3"
  },

  "scripts": {
    "build": "ray build -e dist",
    "dev": "ray develop",
    "lint": "ray lint",
    "publish": "ray publish"
  }
}
```

### Command Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `name` | string | Yes | Unique command ID (don't change after publishing!) |
| `title` | string | Yes | Display name in Raycast |
| `subtitle` | string | No | Service name (for multi-command extensions) |
| `description` | string | Yes | What the command does |
| `mode` | "view" \| "no-view" \| "menu-bar" | Yes | Command type |
| `icon` | string | No | Command-specific icon |
| `preferences` | array | No | Command-specific preferences |
| `arguments` | array | No | Command arguments |
| `keywords` | array | No | Search keywords |

### Preference Properties

```json
{
  "preferences": [
    {
      "name": "apiToken",
      "type": "password",
      "required": true,
      "title": "API Token",
      "description": "Your service API token",
      "placeholder": "ntn_..."
    },
    {
      "name": "syncInterval",
      "type": "dropdown",
      "required": false,
      "title": "Sync Interval",
      "description": "How often to sync",
      "default": "5",
      "data": [
        { "title": "1 minute", "value": "1" },
        { "title": "5 minutes", "value": "5" },
        { "title": "15 minutes", "value": "15" }
      ]
    }
  ]
}
```

**Preference Types**:
- `textfield`: Text input
- `password`: Password input (stored securely)
- `checkbox`: Boolean toggle
- `dropdown`: Select from options
- `appPicker`: Choose installed app
- `file`: File picker
- `directory`: Directory picker

---

## Raycast AI Capabilities

### Two Ways to Use AI

**1. AI API (in any command)**
```typescript
import { AI } from "@raycast/api";

export default async function Command() {
  const answer = await AI.ask("Suggest 5 jazz songs");
  console.log(answer);
}
```

**2. AI Extensions (Tools)**
```typescript
// Tool is invoked by Raycast AI automatically
export default async function SearchTool({ query }: { query: string }) {
  // Search logic
  return results;
}
```

### AI.ask() API

**Basic Usage**:
```typescript
import { AI, Clipboard } from "@raycast/api";

export default async function Command() {
  const answer = await AI.ask("Translate 'Hello' to Spanish");
  await Clipboard.copy(answer);
}
```

**With Options**:
```typescript
const answer = await AI.ask("Write a haiku about coding", {
  creativity: "high",  // "none" | "low" | "medium" | "high" | "maximum" | 0-2
  model: AI.Model["Anthropic_Claude_3.5_Sonnet"],
  signal: abortController.signal  // For cancellation
});
```

**Streaming Response**:
```typescript
const answer = AI.ask("Explain quantum computing");

answer.on("data", (data) => {
  console.log(data);  // Partial response
});

await answer;  // Wait for completion
```

**Error Handling**:
```typescript
import { AI, showToast, Toast, environment } from "@raycast/api";

export default async function Command() {
  if (!environment.canAccess(AI)) {
    await showToast({
      style: Toast.Style.Failure,
      title: "AI not available",
      message: "Requires Raycast Pro"
    });
    return;
  }

  try {
    const answer = await AI.ask("What is the meaning of life?");
    console.log(answer);
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: "AI request failed",
      message: String(error)
    });
  }
}
```

### AI Models

**Available Models**:
- `AI.Model["OpenAI_GPT3.5-turbo"]` (default)
- `AI.Model["OpenAI_GPT4-turbo"]`
- `AI.Model["OpenAI_GPT4o"]`
- `AI.Model["OpenAI_GPT4o-mini"]`
- `AI.Model["Anthropic_Claude_Haiku"]`
- `AI.Model["Anthropic_Claude_3.5_Sonnet"]`
- `AI.Model["Anthropic_Claude_Opus"]`
- `AI.Model["Perplexity_Sonar_Small"]`
- `AI.Model["Perplexity_Sonar_Large"]`

**If a model isn't available**, Raycast fallback to similar one.

### AI Extensions (Tools)

**Create AI Tool**:
```bash
# Via Manage Extensions command:
# 1. Find your extension
# 2. Action: "Add New Tool" (Opt+Cmd+T)
# 3. Enter name, description, pick template
```

**Tool Entry Point**:
```typescript
// src/create-task.ts (AI Tool)
import { showToast, Toast } from "@raycast/api";

interface Arguments {
  taskName: string;
  dueDate?: string;
  priority?: "low" | "medium" | "high";
}

export default async function CreateTask(props: { arguments: Arguments }) {
  const { taskName, dueDate, priority } = props.arguments;

  try {
    // Create task via API
    await createTask({ taskName, dueDate, priority });

    await showToast({
      style: Toast.Style.Success,
      title: "Task created",
      message: taskName
    });
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: "Failed to create task",
      message: String(error)
    });
  }
}
```

**AI Evals (Testing)**:
```json
{
  "ai": {
    "evals": [
      {
        "input": "Create a task called 'Review PR' with high priority",
        "expected": [
          {
            "callsTool": {
              "name": "create_task",
              "arguments": {
                "taskName": {
                  "includes": "Review PR"
                },
                "priority": {
                  "equals": "high"
                }
              }
            }
          }
        ]
      },
      {
        "input": "Add task to buy groceries tomorrow",
        "expected": [
          {
            "callsTool": {
              "name": "create_task",
              "arguments": {
                "taskName": {
                  "includes": "groceries"
                },
                "dueDate": {
                  "exists": true
                }
              }
            }
          }
        ]
      }
    ]
  }
}
```

**Run Evals**:
```bash
npx ray develop  # Evals run automatically during development
```

---

## Development Workflow

### Setup

**1. Install Raycast**
```bash
# Download from https://raycast.com/
```

**2. Create Extension**
```
1. Open Raycast: Cmd+Space
2. Search "Create Extension"
3. Fill in details:
   - Name: "MCP Orchestrator"
   - Description: "Notion & Todoist sync with MCP"
   - Author: your-github-username
   - Template: "Detail" or "List"
   - Location: ~/dev/raycast-extensions/
4. Press Cmd+Enter to create
```

**3. Install Dependencies**
```bash
cd ~/dev/raycast-extensions/mcp-orchestrator
npm install
```

**4. Start Development**
```bash
npm run dev
# or
npx ray develop
```

### Development Mode Features

**Auto-Reload on Save**:
- Edit `src/*.tsx` files
- Save (Cmd+S)
- Command automatically reloads in Raycast

**Hot Reloading**:
- Changes apply instantly
- No need to restart Raycast

**Error Overlays**:
- Detailed stack traces
- Source file locations
- Error messages in Raycast UI

**Log Messages**:
- `console.log()` appears in terminal
- Helps with debugging

**Status Indicator**:
- Build errors shown in navigation title
- Green checkmark = OK
- Red X = Build error

### CLI Commands

**Development**:
```bash
npx ray develop
# Starts dev mode with hot reloading
```

**Build**:
```bash
npx ray build -e dist
# Creates production build in dist/
```

**Lint**:
```bash
npx ray lint
# Runs ESLint on src/
```

**Publish**:
```bash
npx ray publish
# Publishes to Raycast Store (after review)
```

**Help**:
```bash
npx ray help
# Shows all available commands
```

### VS Code Integration

**Install Extension**:
```
1. Open VS Code
2. Search "Raycast" in extensions
3. Install "Raycast Extension Development"
```

**Features**:
- Syntax highlighting for package.json
- IntelliSense for Raycast API
- Snippets for common patterns
- Debugger integration

---

## API Reference

### Core APIs

**AI** - Interact with AI models
```typescript
import { AI } from "@raycast/api";
await AI.ask("prompt", { creativity: "high" });
```

**Clipboard** - Copy/paste/read clipboard
```typescript
import { Clipboard } from "@raycast/api";
await Clipboard.copy("text");
const text = await Clipboard.readText();
await Clipboard.paste("text");
await Clipboard.clear();
```

**Cache** - Store data locally
```typescript
import { Cache } from "@raycast/api";
const cache = new Cache();
cache.set("key", JSON.stringify(data));
const data = JSON.parse(cache.get("key") || "{}");
cache.remove("key");
cache.clear();
```

**Environment** - Access runtime info
```typescript
import { environment } from "@raycast/api";
console.log(environment.raycastVersion);
console.log(environment.commandName);
console.log(environment.assetsPath);
console.log(environment.isDevelopment);
const canUseAI = environment.canAccess(AI);
```

**Command** - Launch other commands
```typescript
import { launchCommand, LaunchType } from "@raycast/api";
await launchCommand({
  name: "search",
  type: LaunchType.UserInitiated,
  context: { query: "test" }
});
```

### UI Components

**List** - Display list of items
```typescript
import { List } from "@raycast/api";

export default function Command() {
  return (
    <List>
      <List.Item
        title="Item 1"
        subtitle="Description"
        accessories={[{ text: "Badge" }]}
        actions={
          <ActionPanel>
            <Action.CopyToClipboard content="text" />
          </ActionPanel>
        }
      />
    </List>
  );
}
```

**Detail** - Display markdown content
```typescript
import { Detail } from "@raycast/api";

export default function Command() {
  return <Detail markdown="# Hello World\n\nContent here..." />;
}
```

**Form** - Input forms
```typescript
import { Form, ActionPanel, Action } from "@raycast/api";

export default function Command() {
  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm onSubmit={(values) => console.log(values)} />
        </ActionPanel>
      }
    >
      <Form.TextField id="name" title="Name" />
      <Form.Dropdown id="priority" title="Priority">
        <Form.Dropdown.Item value="low" title="Low" />
        <Form.Dropdown.Item value="high" title="High" />
      </Form.Dropdown>
    </Form>
  );
}
```

**Grid** - Display items in grid
```typescript
import { Grid } from "@raycast/api";

export default function Command() {
  return (
    <Grid columns={4}>
      <Grid.Item
        content={{ source: "icon.png" }}
        title="Item 1"
      />
    </Grid>
  );
}
```

### Actions

**Common Actions**:
```typescript
import { ActionPanel, Action } from "@raycast/api";

<ActionPanel>
  <Action.CopyToClipboard content="text" />
  <Action.Paste content="text" />
  <Action.OpenInBrowser url="https://example.com" />
  <Action.OpenWith path="/path/to/file" />
  <Action.ShowInFinder path="/path" />
  <Action.SubmitForm onSubmit={(values) => {}} />
  <Action.Push title="Next" target={<NextComponent />} />
  <Action.Pop />
</ActionPanel>
```

### Utilities (@raycast/utils)

**useAI** - Hook for AI in React components
```typescript
import { useAI } from "@raycast/utils";

const { data, isLoading, error, revalidate } = useAI("prompt", {
  creativity: "medium"
});
```

**useFetch** - Fetch data with caching
```typescript
import { useFetch } from "@raycast/utils";

const { data, isLoading, error, revalidate } = useFetch(url, {
  headers: { "Authorization": "Bearer token" }
});
```

**useForm** - Form validation
```typescript
import { useForm, FormValidation } from "@raycast/utils";

const { handleSubmit, itemProps } = useForm({
  onSubmit(values) {
    console.log(values);
  },
  validation: {
    name: FormValidation.Required,
    email: (value) => {
      if (!value?.includes("@")) {
        return "Invalid email";
      }
    }
  }
});
```

---

## Best Practices

### Error Handling

**Always handle expected errors**:
```typescript
try {
  const data = await fetchData();
} catch (error) {
  await showToast({
    style: Toast.Style.Failure,
    title: "Failed to fetch",
    message: String(error)
  });
}
```

**Or use showFailureToast**:
```typescript
import { showFailureToast } from "@raycast/utils";

try {
  await operation();
} catch (error) {
  await showFailureToast(error);
}
```

### Loading States

**Use isLoading prop**:
```typescript
const [items, setItems] = useState<Item[]>();

useEffect(() => {
  fetchItems().then(setItems);
}, []);

return (
  <List isLoading={items === undefined}>
    {items?.map((item) => (
      <List.Item key={item.id} title={item.title} />
    ))}
  </List>
);
```

### Runtime Dependencies

**Check for required apps**:
```typescript
import { getApplications } from "@raycast/api";

const apps = await getApplications();
const notionInstalled = apps.some((app) => app.bundleId === "notion.id");

if (!notionInstalled) {
  await showToast({
    style: Toast.Style.Failure,
    title: "Notion not installed",
    message: "Please install Notion app"
  });
  return;
}
```

### Form Validation

**Validate on blur**:
```typescript
const { handleSubmit, itemProps } = useForm({
  onSubmit(values) {
    // Submit
  },
  validation: {
    name: FormValidation.Required,
    password: (value) => {
      if (value && value.length < 8) {
        return "Password must be at least 8 characters";
      }
    }
  }
});
```

### launchCommand Safety

**Always wrap in try-catch**:
```typescript
try {
  await launchCommand({
    name: "search",
    type: LaunchType.UserInitiated
  });
} catch (error) {
  console.error("Failed to launch:", error);
}
```

---

## Security

### Extension Security Model

**Publishing Process**:
1. All extensions are open source
2. Code reviewed by Raycast team + community
3. CI validates manifest, assets, builds
4. Archived and uploaded to Raycast Store
5. Signed and verified

**Runtime**:
- Extensions run in Node.js child process
- Each extension gets own v8 isolate
- RPC protocol exposes only defined APIs
- Limited heap memory per extension

**Permissions**:
- Extensions NOT sandboxed (same as other macOS apps)
- Accessing special directories requires macOS permissions
- User prompted via System Preferences

**Data Storage**:
- Password preferences → encrypted database
- Local Storage API → encrypted database
- Keychain → system Keychain
- Only extension can access its own data

**Automatic Updates**:
- Raycast auto-updates (security feature)
- Extensions auto-update (minimize outdated versions)
- Hotfixes ship quickly

### Best Practices

**1. Use Password Preferences for Secrets**
```json
{
  "preferences": [
    {
      "name": "apiToken",
      "type": "password",
      "required": true,
      "title": "API Token"
    }
  ]
}
```

**2. Don't Hardcode Secrets**
```typescript
// ❌ BAD
const API_KEY = "ntn_abc123";

// ✅ GOOD
import { getPreferenceValues } from "@raycast/api";
const { apiToken } = getPreferenceValues<{ apiToken: string }>();
```

**3. Use HTTPS Only**
```typescript
// ❌ BAD
fetch("http://api.example.com");

// ✅ GOOD
fetch("https://api.example.com");
```

**4. Validate User Input**
```typescript
const { name } = values;
if (!name || name.trim().length === 0) {
  throw new Error("Name is required");
}
```

---

## Publishing Extensions

### Preparation

**1. Add Metadata (for new extensions with view commands)**
```
metadata/
├── screenshot-1.png  # 1280x800 or 2560x1600
├── screenshot-2.png
└── ...
```

**2. Update CHANGELOG.md**
```markdown
# Changelog

## [New Feature] - {PR_MERGE_DATE}
- Added search functionality
- Fixed memory leak

## [Initial Release] - {PR_MERGE_DATE}
- First version
```

**Note**: Use `{PR_MERGE_DATE}` template (replaced automatically)

**3. Ensure Tests Pass**
```bash
npx ray lint   # No errors
npx ray build  # Successful build
```

**4. README.md**
```markdown
# Extension Name

Description of what your extension does.

## Features

- Feature 1
- Feature 2

## Setup

1. Install extension
2. Configure API token in preferences

## Usage

...
```

### Publishing Process

**Public Extension (Open Source)**:
```bash
# 1. Push to GitHub (fork raycast/extensions)
git checkout -b my-extension
git add .
git commit -m "feat: add My Extension"
git push origin my-extension

# 2. Create Pull Request
# - PR to raycast/extensions:main
# - Fill in PR template
# - Wait for review

# 3. After merge
# - Extension auto-published to store
# - Available to all Raycast users
```

**Private Extension (Organization)**:
```bash
npx ray publish
# Publishes to your organization's private store
# Only available to organization members
```

### Review Guidelines

**Checklist**:
- ✅ CHANGELOG.md has `{PR_MERGE_DATE}` format
- ✅ Command names unchanged (don't break user data)
- ✅ Metadata folder with screenshots (if view commands)
- ✅ `launchCommand` wrapped in try-catch
- ✅ Lists/Grids use `isLoading`
- ✅ Error handling for `getSelectedText()`
- ✅ Documentation titles match package.json
- ✅ Multiple commands have subtitles
- ✅ Tools have AI evals
- ✅ Only `package-lock.json` (no yarn/pnpm)
- ✅ Official npm registry only

**Common Issues**:
- Missing {PR_MERGE_DATE} in CHANGELOG
- Changed command names (breaks user settings)
- Missing metadata screenshots
- Unhandled errors
- No loading states
- No subtitles for multi-command extensions

---

## Comparison with Our Project

### What We Have vs What We Should Have

**Current State**:
```
raycast-extensions/
└── quick-task.sh      # Basic shell script
                       # Calls orchestrator HTTP API
                       # No UI, no error handling
```

**What We Need**:
```
raycast-extensions/
├── package.json       # Extension manifest
├── tsconfig.json      # TypeScript config
├── assets/
│   └── icon.png       # Extension icon
├── src/
│   ├── quick-capture.tsx    # Form UI for task capture
│   ├── search-tasks.tsx     # List UI for searching
│   ├── view-task.tsx        # Detail UI for task details
│   ├── create-task.ts       # AI tool for creating tasks
│   └── search-tool.ts       # AI tool for searching
└── node_modules/
```

### Raycast MCP Integration Strategy

**Option 1: Use Raycast MCP Extension** ✅ RECOMMENDED
```
1. Install Raycast MCP extension
2. Add our Notion MCP server to mcp-config.json:
   {
     "notion": {
       "command": "node",
       "args": ["~/dev/mcp-orchestrator/mcp-servers/notion/dist/index.js"],
       "env": { "NOTION_TOKEN": "ntn_..." }
     }
   }
3. Use @mcp in Raycast AI:
   "@mcp Search my Notion tasks"
   "@mcp Create page for project planning"
```

**Option 2: Create Raycast Extension with Notion Integration**
```typescript
// raycast-extensions/src/search-tasks.tsx
import { List } from "@raycast/api";
import { Client } from "@notionhq/client";

export default function SearchTasks() {
  const [items, setItems] = useState<Page[]>();

  useEffect(() => {
    const notion = new Client({ auth: process.env.NOTION_TOKEN });
    notion.databases.query({ database_id: "..." }).then(setItems);
  }, []);

  return (
    <List isLoading={items === undefined}>
      {items?.map((item) => (
        <List.Item key={item.id} title={item.properties.Name} />
      ))}
    </List>
  );
}
```

**Option 3: Hybrid Approach** ✅ BEST
```
1. Use Raycast MCP extension for AI interactions (@mcp prefix)
2. Create proper Raycast extension for UI commands (search, create, view)
3. Both can coexist and complement each other
```

### What This Repo Should Include

**Missing Components**:

**1. VS Code MCP Configuration**
```json
// .vscode/settings.json (not in repo yet!)
{
  "github.copilot.chat.mcpServers": {
    "notion": {
      "command": "node",
      "args": ["${workspaceFolder}/mcp-servers/notion/dist/index.js"],
      "env": {
        "NOTION_TOKEN": "ntn_from_1password"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "${workspaceFolder}"
      ]
    }
  }
}
```

**2. MCP Server Deployment Scripts**
```bash
# scripts/deploy-mcp-servers.sh (not in repo yet!)
#!/bin/bash

# Build Notion MCP server
cd mcp-servers/notion
npm install
npm run build

# Install File MCP server globally
npm install -g @modelcontextprotocol/server-filesystem

# Setup PM2 for persistent operation
pm2 start ~/dev/mcp-orchestrator/mcp-servers/notion/dist/index.js --name mcp-notion
pm2 start mcp-server-filesystem -- --port 3001 ~/dev
pm2 save
```

**3. Proper Raycast Extension**
```
raycast-extensions/
├── package.json       # With commands, tools, AI evals
├── src/
│   ├── quick-capture.tsx     # Form command
│   ├── search-tasks.tsx      # List command
│   ├── create-task-tool.ts   # AI tool
│   └── search-tool.ts        # AI tool
└── assets/
    └── icon.png
```

**4. MCP Testing Suite**
```typescript
// tests/mcp-servers/notion.test.ts (not in repo yet!)
import { Client } from '@modelcontextprotocol/sdk/client';

describe('Notion MCP Server', () => {
  it('should search pages', async () => {
    const result = await client.callTool('search_pages', { query: 'test' });
    expect(result).toBeDefined();
  });
});
```

### Next Steps for This Repo

**Immediate**:
1. ❌ Create `.vscode/settings.json` with MCP server configuration
2. ❌ Add MCP server deployment scripts
3. ❌ Convert shell script to proper Raycast extension
4. ❌ Document Raycast MCP integration in README

**Short-term**:
5. ❌ Build proper Raycast extension (TypeScript/React)
6. ❌ Add AI tools to Raycast extension
7. ❌ Test MCP servers with VS Code Copilot
8. ❌ Test MCP servers with Raycast MCP extension

**Medium-term**:
9. ❌ Publish Raycast extension to store
10. ❌ Add comprehensive MCP testing
11. ❌ Document complete workflow (Orchestrator + MCP + Raycast)

---

## Additional Resources

### Official Documentation

- **Raycast Developers**: https://developers.raycast.com/
- **API Reference**: https://developers.raycast.com/api-reference
- **Extension Store**: https://www.raycast.com/store
- **GitHub Repository**: https://github.com/raycast/extensions

### Community

- **Slack**: https://www.raycast.com/community
- **Twitter**: https://twitter.com/raycastapp
- **Discord**: (link in Slack)

### Tools

- **ray.so**: Code screenshot tool
- **Icon Maker**: https://ray.so/icon
- **Extension Icon Template**: https://www.figma.com/community/file/1030764827259035122

---

**Last Updated**: October 17, 2025
**Critical Correction**: Raycast DOES support MCP (via extensions/mcp) - previous documentation was incorrect!
