#!/usr/bin/env bash

# Quick Task - Raycast Extension
# Captures task to Todoist via Raycast quick command

# Required parameters: @raycast.mode silent
# Required parameters: @raycast.schemaVersion 1
# Required parameters: @raycast.title Quick Task
# Required parameters: @raycast.description Add task to Todoist quickly
# Required parameters: @raycast.author Kingy2709
# Required parameters: @raycast.authorURL https://github.com/Kingy2709
# Required parameters: @raycast.icon ✅
# Required parameters: @raycast.argument1 {"type": "text", "placeholder": "Task content"}
# Optional parameters: @raycast.argument2 {"type": "text", "placeholder": "Priority (1-4)", "optional": true}

set -euo pipefail

TASK_CONTENT="$1"
PRIORITY="${2:-4}"

# Load Todoist token from environment
TODOIST_TOKEN="${TODOIST_API_TOKEN:-}"

if [ -z "$TODOIST_TOKEN" ]; then
    echo "❌ TODOIST_API_TOKEN not set in environment"
    exit 1
fi

# Create task via Todoist API
RESPONSE=$(curl -sf -X POST "https://api.todoist.com/rest/v2/tasks" \
    -H "Authorization: Bearer $TODOIST_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"content\":\"$TASK_CONTENT\",\"priority\":$PRIORITY}")

if [ $? -eq 0 ]; then
    TASK_ID=$(echo "$RESPONSE" | jq -r '.id')
    echo "✅ Task created: $TASK_CONTENT (ID: $TASK_ID)"
else
    echo "❌ Failed to create task"
    exit 1
fi
