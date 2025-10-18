# Lessons Learned: R&D Phase Requirements

**Date**: 17 October 2025
**Incident**: Built custom MCP servers without verifying official ones didn't exist
**Impact**: 40% of development effort redundant
**Root Cause**: "All of that could have been solved with a simple websearch"

---

## 📖 The Incident

### What Happened

We built a custom Notion MCP server (`mcp-servers/notion/`) with full TypeScript implementation, tools, and documentation. **12+ hours of development.**

We then discovered:

- Official Notion MCP server exists: `makenotion/notion-mcp-server`
- Community Todoist MCP server exists: `abhiz123/todoist-mcp-server`
- Official Raycast MCP extension exists (we initially said it didn't)

**All of this was discoverable with a 5-minute websearch.**

### User's Assessment
>
> "Well that's shit. Next time we need to implement a much better R&D phase... All of that could have been solved with a simple websearch."

**Direct. Accurate. Harsh reality.**

---

## 🎯 Core Principle: RESEARCH FIRST, BUILD SECOND

```
┌─────────────────────────────────────────────┐
│                                             │
│  ALWAYS ASK: "Does this already exist?"     │
│                                             │
│  Before writing ANY custom implementation   │
│                                             │
└─────────────────────────────────────────────┘
```

### The 5-Minute Rule

**Before writing any custom integration, spend 5 minutes searching**:

```bash
# These searches would have saved 16-24 hours:
"[service] mcp server"              # e.g., "notion mcp server"
"[service] model context protocol"  # e.g., "todoist model context protocol"
"[tool] mcp integration"           # e.g., "raycast mcp"
"mcp servers list"                  # Central registry
```

---

## ✅ Mandatory R&D Checklist

### Phase 1: Research (BEFORE ANY CODE)

#### Step 1: Official Sources (5 minutes)

```
[ ] Search: github.com/modelcontextprotocol/servers
    ├── Check "🎖️ Official Integrations" section
    ├── Check "🌎 Community Servers" section
    └── Check for vendor organization (e.g., makenotion, @doist)

[ ] Search: npmjs.com
    ├── "@[vendor]/[service]-mcp-server" (official pattern)
    ├── "[service]-mcp-server" (community pattern)
    └── "@modelcontextprotocol/*" (reference implementations)

[ ] Search: GitHub Topics
    ├── topic:mcp-server language:typescript
    ├── topic:model-context-protocol
    └── "[service] mcp" in repository search
```

#### Step 2: Vendor Documentation (5 minutes)

```
[ ] Check vendor's official docs:
    ├── Does Notion have MCP docs? (search "notion mcp")
    ├── Does Todoist have MCP docs? (search "todoist mcp")
    └── Check developer portals, API docs, integrations pages

[ ] Check vendor GitHub organizations:
    ├── github.com/makenotion
    ├── github.com/doist
    └── Search repositories for "mcp"
```

#### Step 3: Community Resources (5 minutes)

```
[ ] Reddit:
    ├── r/ClaudeAI (MCP discussions)
    ├── r/LocalLLaMA (MCP servers)
    └── Search: "mcp server [service]"

[ ] GitHub Discussions:
    ├── modelcontextprotocol/specification/discussions
    └── Search for service mentions

[ ] Discord/Slack:
    ├── MCP community servers
    └── Service-specific communities
```

#### Step 4: Alternative Integrations (5 minutes)

```
[ ] Zapier/Make.com: Does integration exist?
[ ] n8n: Community nodes available?
[ ] IFTTT: Applets available?
[ ] API wrappers: Existing SDKs we can wrap?
```

**Total Time: ~20 minutes**
**Potential Savings: Hours to days of redundant development**

---

### Phase 2: Documentation (BEFORE ANY CODE)

Create `RESEARCH-FINDINGS.md`:

```markdown
# Research Findings: [Service] Integration

## Official Solutions
- [ ] Official MCP server: [Yes/No]
  - Repository: [link]
  - Maintained by: [vendor/community]
  - Last updated: [date]
  - Stars/activity: [metrics]

- [ ] Community MCP servers: [count]
  - Option 1: [name] - [pros/cons]
  - Option 2: [name] - [pros/cons]

## Alternative Approaches
- [ ] Direct SDK integration
- [ ] API wrapper
- [ ] Third-party service

## Decision
**Chosen approach**: [Selected option]

**Reasoning**:
- [Why this approach over alternatives]
- [Unique value we're adding]
- [Trade-offs accepted]

**Verification**: No existing solution provides [specific unique value]
```

---

### Phase 3: Validation (BEFORE ANY CODE)

#### Get User Approval

```markdown
## Integration Proposal: [Service]

**Goal**: [What we want to achieve]

**Research Summary**:
- ✅ Official server exists: [Yes/No]
- ✅ Community servers: [count]
- ✅ Unique value: [What we add that doesn't exist]

**Recommendation**: [Build custom / Use existing / Hybrid]

**Estimated Effort**:
- Use existing: [X hours]
- Build custom: [Y hours]
- Savings: [Y-X hours]

**Request**: Approval to proceed with [recommendation]
```

#### Verify Assumptions

```
[ ] User confirmed goal is correct
[ ] User approved chosen approach
[ ] User acknowledged trade-offs
[ ] User verified budget (time/cost)
```

---

## 🚫 Anti-Patterns (DON'T DO THIS)

### ❌ "I'll just build it, it'll be faster"

**Wrong**: Assumes building is faster than searching
**Reality**: 5-minute search vs 12-hour build
**Result**: Wasted 11.92 hours

### ❌ "Official implementations are probably incomplete"

**Wrong**: Assumes official = incomplete
**Reality**: Official implementations are usually most complete
**Result**: Build inferior version of existing tool

### ❌ "I want to learn by building it"

**Wrong**: Learning goal confused with project goal
**Reality**: Learning projects should be explicit about that goal
**Result**: Project delays for educational detours

### ❌ "We have unique requirements"

**Wrong**: Assumes uniqueness without verification
**Reality**: Most requirements are common
**Result**: Duplicate work for imagined uniqueness

### ❌ "I'll research after I've proven the concept"

**Wrong**: Build first, research later
**Reality**: Proven concept may duplicate existing solution
**Result**: Sunk cost fallacy ("but I already built it...")

---

## ✅ Correct Patterns (DO THIS)

### ✅ "What exists? Let me search first"

**Right**: Research before any implementation
**Process**: 20-minute checklist
**Result**: Informed decision with evidence

### ✅ "Official first, community second, custom last"

**Right**: Prefer existing solutions in priority order
**Process**:

1. Official implementation
2. Well-maintained community implementation
3. Custom implementation ONLY if gaps identified
**Result**: Leverage existing work

### ✅ "Document why custom is needed"

**Right**: Justify custom implementation explicitly
**Process**: Create RESEARCH-FINDINGS.md with reasoning
**Result**: Verifiable decision-making

### ✅ "Unique value must be explicit"

**Right**: State what doesn't exist elsewhere
**Process**: "No existing solution provides [X]"
**Result**: Clear value proposition

### ✅ "Get user approval before building"

**Right**: User confirms approach before coding
**Process**: Present research, recommendation, trade-offs
**Result**: Aligned expectations

---

## 🔄 This Project's Timeline (What Actually Happened)

### Week 1-2: Build Phase (NO R&D) ❌

```
Day 1-3:  Scaffold orchestrator ✅ (unique value)
Day 4-7:  Build custom Notion MCP ❌ (redundant)
Day 8-10: Plan custom Todoist MCP ❌ (redundant)
Day 11:   User: "Does Raycast support MCP?"
Day 12:   Agent: "No" ❌ (WRONG)
Day 13:   User: *provides 14 Raycast doc URLs*
Day 14:   Agent: "Oh, it does" ✅ (corrected)
```

### Week 3: Reality Check ⚠️

```
User: "So do I even need this repo? I'm lost."
Agent: *researches official MCP servers*
Agent: "40% of this is redundant"
User: "Well that's shit"
User: "All of that could have been solved with a simple websearch"
```

### What Should Have Happened 🎯

```
Day 1: Research MCP servers (20 minutes)
       ├── Find official Notion MCP ✅
       ├── Find community Todoist MCP ✅
       ├── Find Raycast MCP extension ✅
       └── Verify orchestrator is unique ✅

Day 1: Document findings (30 minutes)
       └── RESEARCH-FINDINGS.md

Day 1: Get user approval (10 minutes)
       └── User: "Great, build orchestrator only"

Day 2-3: Build orchestrator ✅
Day 4: Configure official MCP servers ✅
Day 5: Test integration ✅
Day 6: Ship ✅

Result: 6 days instead of 14 days
Savings: 8 days of redundant work
```

---

## 📋 R&D Phase Template

Use this for ALL future integrations:

### 1. Research Brief (30 minutes)

```markdown
# [Service] Integration Research

**Date**: [today]
**Goal**: [what we want to achieve]

## Official Solutions
- [ ] Official MCP server: ...
- [ ] SDK available: ...
- [ ] API documentation: ...

## Community Solutions
- [ ] Community MCP servers: ...
- [ ] Third-party wrappers: ...
- [ ] Open-source projects: ...

## Gap Analysis
**What exists**: [list all solutions found]
**What's missing**: [specific gaps]
**Unique value we add**: [what doesn't exist elsewhere]

## Recommendation
- [ ] Use official solution
- [ ] Use community solution
- [ ] Build custom (justified by [gap])

**Next Step**: [Get user approval / Start building / More research]
```

### 2. Decision Document (15 minutes)

```markdown
# Decision: [Service] Integration

**Status**: ✅ APPROVED / ⚠️ PENDING / ❌ REJECTED

## Context
[Why we need this integration]

## Research Summary
- Official: [found/not found]
- Community: [X options found]
- Custom needed: [yes/no]

## Decision
**Approach**: [selected option]

**Justification**:
1. [Reason 1]
2. [Reason 2]
3. [Reason 3]

**Alternatives Considered**:
- [Alternative 1]: Rejected because [reason]
- [Alternative 2]: Rejected because [reason]

**User Approval**: [Yes/No/Pending]
**Date**: [approval date]
```

### 3. Implementation Checklist (reference)

```markdown
# [Service] Integration Implementation

## Pre-Implementation
- [ ] Research completed
- [ ] Decision documented
- [ ] User approval received
- [ ] No existing solution (verified)

## Implementation
- [ ] Code written
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Integration tested

## Post-Implementation
- [ ] Value delivered matches proposal
- [ ] No redundancy with existing tools
- [ ] User satisfied with result
```

---

## 🎓 Key Takeaways

### 1. **Websearch First, Always**
>
> "All of that could have been solved with a simple websearch"

- 5 minutes of searching can save days of building
- Official repositories are the first place to check
- Community has likely solved common problems

### 2. **Official > Community > Custom**

Priority order for integrations:

1. **Official implementation** (e.g., `makenotion/notion-mcp-server`)
2. **Well-maintained community** (e.g., `abhiz123/todoist-mcp-server`)
3. **Custom implementation** (ONLY if gaps verified)

### 3. **Document Why Custom is Needed**

If building custom:

- Explicitly state what existing solutions don't provide
- Document alternatives considered
- Get user approval before starting

### 4. **Best Practice Remains Best Practice**
>
> "IT's best practice? THAT was the whole point - best practice. Always..."

- Security (1Password): ✅ Correct decision
- Documentation: ✅ Correct approach
- R&D process: ❌ **Missing** (fixed now)

Best practice includes RESEARCH as first step.

### 5. **Efficiency Matters**

- 20% unique value: ✅ Worth building
- 40% redundant: ❌ Wasted effort
- 40% questionable: ❓ Needs validation

Always ask: "Is this the highest-value use of time?"

---

## 📊 Success Metrics

### For This Project

- [x] Identified 40% redundancy
- [x] Documented lessons learned
- [ ] Removed redundant code
- [ ] Refactored to use official servers
- [ ] Prevented future redundant work

### For Future Projects

- [ ] R&D phase mandatory BEFORE coding
- [ ] 20-minute research checklist completed
- [ ] RESEARCH-FINDINGS.md created
- [ ] User approval documented
- [ ] No redundant implementations

---

## 🔗 References

### This Incident

- **MCP-INTEGRATION-STATUS.md**: Full post-mortem
- **Official Notion MCP**: <https://github.com/makenotion/notion-mcp-server>
- **Community Todoist MCP**: <https://github.com/abhiz123/todoist-mcp-server>
- **MCP Servers Registry**: <https://github.com/modelcontextprotocol/servers>

### Research Resources

- **MCP Documentation**: <https://modelcontextprotocol.io>
- **MCP Servers List**: <https://github.com/modelcontextprotocol/servers>
- **npm Package Search**: <https://www.npmjs.com/search?q=mcp-server>
- **GitHub Topics**: <https://github.com/topics/mcp-server>

### Best Practices

- **Before You Code**: Research existing solutions
- **DRY Principle**: Don't Repeat (existing) Work
- **Standing on Shoulders**: Leverage community/official tools
- **Value Focus**: Only build what's truly unique

---

## 🚀 Action Items

### Immediate (This Project)

1. [ ] Apply 20-minute research checklist to remaining features
2. [ ] Remove redundant code (mcp-servers/notion/)
3. [ ] Configure official MCP servers
4. [ ] Verify orchestrator is only custom component

### Process (Future Projects)

1. [ ] Add R&D phase to project template
2. [ ] Create RESEARCH-FINDINGS.md template
3. [ ] Add research checklist to pre-commit hook
4. [ ] Document decision-making in all proposals

### Cultural (Team/Personal)

1. [ ] "Websearch first" becomes reflex
2. [ ] "What exists?" before "How do I build?"
3. [ ] Official > Community > Custom (always)
4. [ ] Best practice includes R&D phase

---

## 💬 Final Thoughts

**From the User**:
> "Well that's shit. Next time we need to implement a much better R&D phase... All of that could have been solved with a simple websearch."

**The Lesson**:
Research is not overhead. Research is the work. Building without research is just expensive guessing.

**The Commitment**:
Never again. 20-minute research checklist. Every time. No exceptions.

**The Philosophy** (User's words):
> "IT's best practice? THAT was the whole point - best practice. Always..."

Best practice now includes: **Websearch first. Always.**

---

**Status**: ✅ Lessons documented
**Next**: Apply to all future features
**Owner**: @kingm
**Last Updated**: 17 October 2025
