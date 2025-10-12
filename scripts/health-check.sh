#!/usr/bin/env bash
set -euo pipefail

# Health check script for MCP Orchestrator
# Verifies all services are running and responsive

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ORCHESTRATOR_URL="${ORCHESTRATOR_URL:-http://localhost:3000}"

echo "========================================="
echo "MCP Orchestrator Health Check"
echo "========================================="

# Check if orchestrator is running
echo ""
echo "Checking orchestrator..."
if curl -sf "$ORCHESTRATOR_URL/health" > /dev/null; then
    RESPONSE=$(curl -s "$ORCHESTRATOR_URL/health")
    echo "✅ Orchestrator is running"
    echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
else
    echo "❌ Orchestrator is not responding at $ORCHESTRATOR_URL"
    exit 1
fi

# Check Docker containers (if using Docker)
if command -v docker &> /dev/null; then
    echo ""
    echo "Checking Docker containers..."
    cd "$PROJECT_ROOT"
    
    if docker-compose ps | grep -q "Up"; then
        echo "✅ Docker containers running:"
        docker-compose ps
    else
        echo "⚠️  No Docker containers running"
        echo "   Start with: docker-compose up -d"
    fi
fi

# Check environment configuration
echo ""
echo "Checking configuration..."
if [ -f "$PROJECT_ROOT/.env" ]; then
    echo "✅ .env file exists"
    
    # Check for required variables
    REQUIRED_VARS=("NOTION_API_KEY" "TODOIST_API_TOKEN" "OP_SERVICE_ACCOUNT_TOKEN")
    for var in "${REQUIRED_VARS[@]}"; do
        if grep -q "^$var=" "$PROJECT_ROOT/.env" && ! grep -q "^$var=\${" "$PROJECT_ROOT/.env"; then
            echo "  ✅ $var configured"
        else
            echo "  ⚠️  $var not configured"
        fi
    done
else
    echo "❌ .env file not found"
    echo "   Run: cp .env.template .env"
fi

echo ""
echo "========================================="
echo "Health Check Complete"
echo "========================================="
