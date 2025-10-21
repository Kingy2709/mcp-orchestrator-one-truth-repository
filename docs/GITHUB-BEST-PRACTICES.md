# GitHub Repository Best Practices

**Comprehensive guide for setting up and maintaining professional GitHub repositories**

*Last updated: October 18, 2025*

---

## Table of Contents

1. [Repository Structure](#repository-structure)
2. [File Naming Conventions](#file-naming-conventions)
3. [Git Workflow](#git-workflow)
4. [Documentation Standards](#documentation-standards)
5. [Commit Message Format](#commit-message-format)
6. [Branch Strategy](#branch-strategy)
7. [Release Management](#release-management)
8. [GitHub-Specific Features](#github-specific-features)

---

## Repository Structure

### Standard Root Files

| File | Location | Purpose | Required? |
|------|----------|---------|-----------|
| `README.md` | Root | Project overview, quick start | ✅ Always |
| `CHANGELOG.md` | Root | Release history | ✅ Recommended |
| `LICENSE` | Root | Legal license | ✅ Open-source |
| `ARCHITECTURE.md` | Root or `docs/` | System design | ⚠️ Complex projects |
| `CONTRIBUTING.md` | Root | Contribution guidelines | ⚠️ Open-source |
| `.gitignore` | Root | Files to exclude | ✅ Always |
| `.env.template` | Root | Environment variables template | ✅ If using .env |

### Directory Structure (TypeScript/Node.js)

```
my-project/
├── README.md                  ← What/why/how (always updated)
├── CHANGELOG.md               ← Release history
├── LICENSE                    ← Legal
├── ARCHITECTURE.md            ← System design
├── package.json
├── tsconfig.json
├── .gitignore
├── .env.template
│
├── .github/
│   ├── copilot-instructions.md     ← GitHub Copilot config
│   ├── workflows/
│   │   ├── ci.yml                  ← CI/CD pipeline
│   │   └── release.yml             ← Auto-release
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── pull_request_template.md
│
├── docs/
│   ├── setup/
│   │   ├── README.md               ← Installation overview
│   │   ├── local-development.md
│   │   └── deployment.md
│   ├── architecture/
│   │   ├── README.md               ← Current design
│   │   ├── diagrams/
│   │   └── decisions/              ← ADRs
│   │       ├── template.md
│   │       ├── 001-use-typescript.md
│   │       └── 002-database-choice.md
│   ├── integrations/
│   │   ├── api-a.md
│   │   └── api-b.md
│   └── guides/
│       ├── getting-started.md
│       └── troubleshooting.md
│
├── src/                       ← Source code
│   ├── index.ts
│   ├── config.ts
│   ├── utils/
│   ├── services/
│   └── models/
│
├── tests/                     ← OR src/__tests__
│   ├── unit/
│   └── integration/
│
├── scripts/                   ← Setup, deployment scripts
│   ├── setup.sh
│   └── deploy.sh
│
└── githooks/                  ← Custom git hooks
    ├── pre-commit
    └── pre-push
```

---

## File Naming Conventions

### By File Type

| File Type | Convention | Examples |
|-----------|------------|----------|
| **Standard docs** | `ALLCAPS.md` | `README.md`, `CHANGELOG.md`, `LICENSE`, `CONTRIBUTING.md` |
| **GitHub files** | `kebab-case.md` | `copilot-instructions.md`, `pull_request_template.md` |
| **Regular docs** | `kebab-case.md` | `setup-guide.md`, `api-reference.md`, `troubleshooting.md` |
| **TypeScript/JS** | `kebab-case.ts` | `auto-tagger.ts`, `task-delegator.ts`, `user-service.ts` |
| **Python** | `snake_case.py` | `auto_tagger.py`, `task_delegator.py`, `user_service.py` |
| **Shell scripts** | `kebab-case.sh` | `setup.sh`, `health-check.sh`, `deploy-prod.sh` |
| **Config files** | varies | `package.json`, `tsconfig.json`, `.env.template`, `docker-compose.yml` |

### Why ALLCAPS for Standard Docs?

**Historical convention:** Unix tradition (README, LICENSE, COPYRIGHT)

**Visibility:** Stands out in file listings

**Recognition:** Developers worldwide expect these names

### Why kebab-case for GitHub Files?

**GitHub convention:** `.github/workflows/ci.yml`, `.github/copilot-instructions.md`

**URL-friendly:** No spaces, lowercase, works in URLs

**Consistency:** Matches ecosystem (npm, yarn, pnpm use kebab-case)

### Why snake_case for Python?

**PEP 8 style guide:** Official Python convention

**Community standard:** All Python projects use this

---

## Git Workflow

### Basic Workflow (Solo Project)

```bash
# 1. Make changes
vim README.md

# 2. Stage changes
git add README.md
# OR stage all
git add .

# 3. Commit with message
git commit -m "docs: update README with installation steps"

# 4. Push to GitHub
git push origin main

# 5. Tag releases
git tag v0.2.0
git push origin main --tags
```

### Branch Workflow (Team Project)

```bash
# 1. Create feature branch
git checkout -b feature/add-authentication

# 2. Make changes, commit
git add .
git commit -m "feat: add JWT authentication"

# 3. Push branch
git push origin feature/add-authentication

# 4. Open Pull Request on GitHub

# 5. After approval, merge via GitHub UI

# 6. Delete local branch
git checkout main
git pull origin main
git branch -d feature/add-authentication
```

### Commit vs Tag vs Branch

| Concept | Purpose | When to Use |
|---------|---------|-------------|
| **Commit** | Save point | Every change (frequent) |
| **Tag** | Named release marker | Releases (v0.1.0, v1.0.0) |
| **Branch** | Parallel timeline | Features, experiments |

**Commit:**

```bash
git commit -m "fix: resolve login bug"
# Creates snapshot with unique hash: 7ae9c5e1...
```

**Tag:**

```bash
git tag v1.0.0
# Points to commit, human-readable name
```

**Branch:**

```bash
git checkout -b feature/new-feature
# Creates separate timeline for development
```

---

## Documentation Standards

### README.md Template

```markdown
# Project Name

One-sentence description

![Build Status](badge) ![License](badge)

## Overview

Brief explanation of what this does and why it exists.

## Features

- ⚡ Feature 1
- 🔒 Feature 2
- 🚀 Feature 3

## Quick Start

\`\`\`bash
# Installation
npm install

# Configuration
cp .env.template .env

# Run
npm start
\`\`\`

## Documentation

- [Installation Guide](docs/setup/README.md)
- [Architecture](ARCHITECTURE.md)
- [API Reference](docs/api-reference.md)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

[MIT](LICENSE)
```

### CHANGELOG.md Template

Use [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features in development

### Changed
- Changes to existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security patches

## [1.0.0] - 2025-10-18

### Added
- Initial stable release
- Core features implemented

## [0.2.0] - 2025-10-15

### Added
- Beta features

## [0.1.0] - 2025-10-12

### Added
- Project initialization
```

### Architecture Decision Records (ADRs)

**Template: `docs/architecture/decisions/template.md`**

```markdown
# ADR-XXX: [Short Title]

**Status:** [Proposed | Accepted | Deprecated | Superseded]
**Date:** YYYY-MM-DD
**Deciders:** [Names]
**Tags:** #category #topic

## Context

What is the issue we're seeing that is motivating this decision?

## Decision

What is the change we're proposing/making?

## Consequences

### Positive

- ✅ Benefit 1
- ✅ Benefit 2

### Negative

- ❌ Tradeoff 1
- ❌ Tradeoff 2

### Neutral

- Information without positive/negative judgment

## Related

- [ADR-001](./001-previous-decision.md)
- [External resource](https://example.com)
```

**Example: `001-use-typescript.md`**

```markdown
# ADR-001: Use TypeScript for Backend

**Status:** Accepted
**Date:** 2025-10-12
**Deciders:** Engineering team
**Tags:** #language #backend

## Context

Need to choose language for new backend service. Options: JavaScript, TypeScript, Go, Rust.

## Decision

Use TypeScript with strict mode enabled.

## Consequences

### Positive

- ✅ Type safety catches bugs at compile time
- ✅ Better IDE support (autocomplete, refactoring)
- ✅ Team already knows JavaScript

### Negative

- ❌ Compilation step adds complexity
- ❌ Slower iteration vs vanilla JS

## Related

- [TypeScript docs](https://www.typescriptlang.org/)
```

---

## Commit Message Format

### Conventional Commits

**Format:** `<type>(<scope>): <subject>`

**Types:**

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation only
- `style:` Formatting (no code change)
- `refactor:` Code restructure (no behavior change)
- `test:` Add/update tests
- `chore:` Maintenance (deps, config)
- `perf:` Performance improvement
- `ci:` CI/CD changes
- `build:` Build system changes
- `revert:` Revert previous commit

**Examples:**

```bash
# Good commits
git commit -m "feat(auth): add JWT authentication"
git commit -m "fix(api): resolve null pointer in user service"
git commit -m "docs: update README with installation steps"
git commit -m "refactor(sync): simplify bidirectional conflict resolution"
git commit -m "chore(deps): upgrade TypeScript to 5.3.0"

# Bad commits
git commit -m "updates"
git commit -m "fix stuff"
git commit -m "WIP"
```

**Multi-line commits:**

```bash
git commit -m "feat(sync): implement bidirectional Notion-Todoist sync

- Add webhook triggers for real-time updates
- Implement conflict resolution (latest-wins strategy)
- Add deduplication to prevent sync loops
- Log all sync operations for debugging"
```

### Why Conventional Commits?

1. **Auto-generate CHANGELOG:** Tools parse commits → build CHANGELOG
2. **Semantic versioning:** `feat` → minor bump, `fix` → patch bump
3. **Filtering:** `git log --grep="feat"` finds all features
4. **Team communication:** Clear what changed and why

---

## Branch Strategy

### Solo Project (Simple)

**One branch: `main`**

```bash
# All commits go directly to main
git add .
git commit -m "feat: add feature"
git push origin main
```

### Team Project (Git Flow)

**Branches:**

- `main` (production)
- `develop` (integration)
- `feature/*` (new features)
- `hotfix/*` (urgent fixes)

**Workflow:**

```bash
# Start feature
git checkout develop
git checkout -b feature/user-authentication

# Develop feature
git commit -m "feat(auth): add login endpoint"
git commit -m "feat(auth): add JWT middleware"

# Open PR: feature/user-authentication → develop

# After merge, delete branch
git branch -d feature/user-authentication

# Release: develop → main
git checkout main
git merge develop
git tag v1.0.0
git push origin main --tags
```

### GitHub Flow (Recommended for Most Projects)

**Branches:**

- `main` (always deployable)
- `feature/*` (short-lived)

**Workflow:**

```bash
# Feature branch
git checkout -b feature/new-feature

# Develop + push
git push origin feature/new-feature

# Open PR → main
# CI runs tests automatically
# Team reviews
# Merge via GitHub

# Deploy main to production
```

---

## Release Management

### Semantic Versioning

**Format:** `MAJOR.MINOR.PATCH` (e.g., `v1.2.3`)

- **MAJOR:** Breaking changes (v1.0.0 → v2.0.0)
- **MINOR:** New features (backward compatible) (v1.0.0 → v1.1.0)
- **PATCH:** Bug fixes (v1.0.0 → v1.0.1)

**Examples:**

```
v0.1.0 → First release (alpha)
v0.2.0 → Added new feature (beta)
v1.0.0 → First stable release
v1.1.0 → Added feature (minor bump)
v1.1.1 → Fixed bug (patch bump)
v2.0.0 → Breaking API change (major bump)
```

### Tagging Releases

```bash
# Create tag
git tag v1.0.0

# Annotated tag (recommended)
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to GitHub
git push origin v1.0.0

# Push all tags
git push origin --tags

# List tags
git tag
git tag -l "v1.*"

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0
```

### GitHub Releases

1. **Tag commit:** `git tag v1.0.0`
2. **Push tag:** `git push origin v1.0.0`
3. **GitHub UI:** Releases → "Draft a new release"
4. **Select tag:** v1.0.0
5. **Release notes:** Copy from CHANGELOG
6. **Publish release**

**Auto-generate release notes:**

GitHub can auto-generate based on PRs and commits.

---

## GitHub-Specific Features

### .github/ Directory

```
.github/
├── copilot-instructions.md      ← GitHub Copilot config
├── workflows/
│   ├── ci.yml                   ← CI/CD
│   └── release.yml              ← Auto-release
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   └── feature_request.md
├── pull_request_template.md
├── CODEOWNERS                   ← Auto-assign reviewers
└── dependabot.yml               ← Dependency updates
```

### copilot-instructions.md

**Purpose:** Configure GitHub Copilot behavior in your repo

```markdown
# Project Copilot Instructions

## Project Context
This is a TypeScript/Node.js orchestrator for Notion/Todoist sync.

## Code Style
- Use TypeScript strict mode
- Explicit return types
- No `any` types (use `unknown` if necessary)
- camelCase for variables, PascalCase for classes

## Commit Standards
- Use Conventional Commits (feat, fix, docs, etc.)
- Format: `type(scope): subject`

## Security
- Fetch secrets from 1Password Service Account only
- No hardcoded tokens
- Use op:// references in .env

## ADHD Workflow
- Backend-only (no UI)
- < 5 second capture (Siri → Todoist → Notion)
- Auto-tagging with AI
```

### GitHub Actions (CI/CD)

**Example: `.github/workflows/ci.yml`**

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm test
      - run: npm run lint
```

---

## Best Practices Summary

### Do's ✅

- ✅ **Update README** when project changes
- ✅ **Update CHANGELOG** before releases
- ✅ **Use Conventional Commits** for clarity
- ✅ **Tag releases** with semantic versioning
- ✅ **Write ADRs** for major decisions
- ✅ **Keep docs/ organized** (topic-based grouping)
- ✅ **Use .gitignore** (never commit secrets, node_modules)
- ✅ **Push commits** regularly (don't lose work)

### Don'ts ❌

- ❌ **Don't commit secrets** (.env, API keys)
- ❌ **Don't edit .git/ manually** (Git owns this)
- ❌ **Don't use vague commits** ("fix stuff", "updates")
- ❌ **Don't skip CHANGELOG** (future you will forget)
- ❌ **Don't fragment docs** (14 files for 4 topics)
- ❌ **Don't forget to push** (commits are local until pushed)

---

## Git Command Cheat Sheet

```bash
# Setup
git init                          # Initialize repo
git clone <url>                   # Clone existing repo
git remote add origin <url>       # Add remote

# Daily workflow
git status                        # Check changes
git add <file>                    # Stage file
git add .                         # Stage all
git commit -m "message"           # Commit
git push origin main              # Push to GitHub
git pull origin main              # Pull from GitHub

# Branches
git branch                        # List branches
git checkout -b feature/name      # Create + switch
git checkout main                 # Switch branch
git merge feature/name            # Merge into current
git branch -d feature/name        # Delete branch

# History
git log                           # Show commits
git log --oneline                 # Compact view
git log --graph --all             # Visual branches
git log --stat                    # Files changed
git log -p                        # Show diffs
git log --grep="docs"             # Search commits

# Tags
git tag v1.0.0                    # Create tag
git tag -a v1.0.0 -m "message"    # Annotated tag
git push origin v1.0.0            # Push tag
git push --tags                   # Push all tags

# Undo
git reset HEAD <file>             # Unstage file
git checkout -- <file>            # Discard changes
git revert <commit>               # Undo commit (safe)
git reset --hard HEAD~1           # Delete last commit (dangerous)

# Remotes
git remote -v                     # List remotes
git remote add origin <url>       # Add remote
git push origin main              # Push
git pull origin main              # Pull
```

---

## Example from This Repo

**Our structure:**

```
mcp-orchestrator-one-truth-repository/
├── README.md                          ✅ Updated for n8n pivot
├── CHANGELOG.md                       ✅ Tracks strategic decisions
├── ARCHITECTURE.md                    ✅ System design
├── LICENSE                            ✅ MIT license
├── .github/copilot-instructions.md    ✅ Project context
├── docs/
│   ├── setup/                         ⚠️ To be created
│   ├── integrations/                  ⚠️ To be created
│   ├── decisions/                     ✅ Created
│   │   ├── ADR-001-use-n8n.md         ✅ Documented
│   │   └── ADR-002-reject-motion.md   ✅ Documented
│   ├── STRATEGIC-VALUE-ANALYSIS.md    ✅ 450+ lines
│   └── LESSONS-LEARNED.md             ✅ Post-mortem
```

**Our commits:**

```bash
7ae9c5e docs: add comprehensive 1Password guide
b285e82 docs: update .env.template
e6c86bc feat: implement async config
c640fb5 fix: resolve TypeScript errors
1bfc42a feat: initial scaffolding
```

✅ **Good:** Using Conventional Commits, logical grouping

⚠️ **Todo:** Push to GitHub, tag v0.2.0

---

## References

- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Architecture Decision Records](https://adr.github.io/)
