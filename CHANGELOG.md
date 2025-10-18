# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- **BREAKING:** Pivoted from custom orchestrator to n8n-based bidirectional sync
- Strategic decision: Use n8n Starter (€20/mo) instead of finishing custom orchestrator (see ADR-001)
- Strategic decision: Rejected Motion ($49/mo) in favor of n8n (see ADR-002)
- Updated architecture to reflect n8n workflow instead of custom service

### Added

- **docs/MCP-INTEGRATION-STATUS.md** - Post-mortem documenting 40% code redundancy (official MCP servers exist)
- **docs/STRATEGIC-VALUE-ANALYSIS.md** - Comprehensive analysis: n8n vs Zapier vs Motion (450+ lines)
- **docs/LESSONS-LEARNED.md** - R&D process improvements (20-minute research checklist)
- **docs/decisions/ADR-001-use-n8n-over-custom.md** - Decision rationale for n8n pivot
- **docs/decisions/ADR-002-reject-motion.md** - Decision rationale for rejecting Motion
- **docs/GITHUB-BEST-PRACTICES.md** - Repository structure and Git workflow guide
- Combined n8n AI prompt for bidirectional sync + ADHD auto-tagging
- Topic-based documentation structure (setup/, integrations/, workflows/, decisions/)

### Deprecated

- Custom Notion MCP server (official `makenotion/notion-mcp-server` exists and is superior)
- Custom orchestrator sync engine (n8n provides same functionality in 3-5 hours vs 40+ hours)

### Fixed

- Updated README.md to reflect current n8n-based architecture
- Consolidated 14 fragmented docs into organized topic-based structure
- Updated ARCHITECTURE.md with n8n workflow diagrams

## [0.1.0] - 2025-10-12

### Added

- Project initialization
- README with architecture overview
- ARCHITECTURE.md with detailed system design
- Basic directory structure
- Development environment configuration

[Unreleased]: https://github.com/Kingy2709/mcp-orchestrator-one-truth-repository/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Kingy2709/mcp-orchestrator-one-truth-repository/tree/v0.1.0
