#!/usr/bin/env bash
set -euo pipefail

# Setup script for MCP Orchestrator
# Installs dependencies, configures environment, and verifies setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================="
echo "MCP Orchestrator Setup"
echo "========================================="

# Check prerequisites
echo ""
echo "Checking prerequisites..."

# Check Node.js version
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 20+ first."
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "❌ Node.js 20+ required. Current version: $(node -v)"
    exit 1
fi
echo "✅ Node.js $(node -v)"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker not found. Docker is optional but recommended."
else
    echo "✅ Docker $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
fi

# Check 1Password CLI
if ! command -v op &> /dev/null; then
    echo "⚠️  1Password CLI not found. Install from: https://developer.1password.com/docs/cli"
else
    echo "✅ 1Password CLI $(op --version)"
fi

# Install orchestrator dependencies
echo ""
echo "Installing orchestrator dependencies..."
cd "$PROJECT_ROOT/orchestrator"
npm install

# Install MCP server dependencies
echo ""
echo "Installing MCP server dependencies..."
for server in "$PROJECT_ROOT"/mcp-servers/*; do
    if [ -d "$server" ] && [ -f "$server/package.json" ]; then
        echo "  - Installing $(basename "$server")..."
        cd "$server"
        npm install
    fi
done

# Configure environment
echo ""
echo "Configuring environment..."
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    cp "$PROJECT_ROOT/.env.template" "$PROJECT_ROOT/.env"
    echo "✅ Created .env from template"
    echo "⚠️  Please configure .env with your API keys before running"
else
    echo "✅ .env already exists"
fi

# Create logs directory
mkdir -p "$PROJECT_ROOT/logs"
echo "✅ Created logs directory"

# Install pre-commit hook (if git repo)
if [ -d "$PROJECT_ROOT/.git" ]; then
    echo ""
    echo "Installing git hooks..."
    if [ -f "$PROJECT_ROOT/githooks/pre-commit" ]; then
        cp "$PROJECT_ROOT/githooks/pre-commit" "$PROJECT_ROOT/.git/hooks/pre-commit"
        chmod +x "$PROJECT_ROOT/.git/hooks/pre-commit"
        echo "✅ Pre-commit hook installed"
    fi
fi

# Run health check
echo ""
echo "Running health check..."
cd "$PROJECT_ROOT/orchestrator"
npm run build

echo ""
echo "========================================="
echo "Setup Complete! ✅"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Configure .env with your API keys"
echo "2. Run: ./scripts/configure-1password.sh (recommended)"
echo "3. Start orchestrator: docker-compose up -d"
echo "4. Verify health: ./scripts/health-check.sh"
echo ""
echo "See docs/SETUP.md for detailed instructions"
