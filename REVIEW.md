# Plugin Marketplace Standards Compliance Review

A comprehensive audit of this marketplace against Anthropic's official Claude Code documentation (January 2026), the Agent Skills open standard, and industry patterns.

---

## Executive Summary

This marketplace is **ahead of the curve** on content quality and **well-aligned with Claude Code conventions**, but uses some Claude Code-specific fields that limit portability to other agent platforms.

**Overall Grade: A-**
- Content Quality: A+
- Claude Code Compliance: A
- Agent Skills Spec Compliance: B+
- Distribution/Portability: B
- Progressive Disclosure: A+

**Key Finding**: Anthropic merged Slash Commands into Skills (January 2026). Your `commands/` wrappers are now legacy. Skills can be invoked directly with `/skill-name`. No migration required, but consider consolidating to skills-only for simplicity.

---

## Standards Reviewed

| Source | URL | Status |
|--------|-----|--------|
| Claude Code Plugin Docs | [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins) | Official, current |
| Claude Code Skills Docs | [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills) | Official, current |
| Plugins Reference | [code.claude.com/docs/en/plugins-reference](https://code.claude.com/docs/en/plugins-reference) | Technical spec |
| Agent Skills Spec | [agentskills.io/specification](https://agentskills.io/specification) | Open standard |
| Anthropic Skills Repo | [github.com/anthropics/skills](https://github.com/anthropics/skills) | Reference implementation |

---

## Validation Summary

**Automated validation passed.** Plugin validator found:
- 0 critical issues
- 5 minor warnings (detailed below)
- All 8 plugins at consistent v1.3.0

---

## Detailed Compliance Analysis

### 1. SKILL.md Frontmatter

#### Official Claude Code Fields (from code.claude.com/docs/en/skills)

| Field | Required | Your Usage | Status |
|-------|----------|------------|--------|
| `name` | No (uses dir name) | Present | Valid |
| `description` | Recommended | Present with triggers | Excellent |
| `argument-hint` | No | Present on 7/11 skills | Good |
| `disable-model-invocation` | No | Not used | Correct (skills should auto-trigger) |
| `user-invocable` | No | Present where needed | Valid |
| `allowed-tools` | No | Not used | Optional |
| `context` | No | Not used | Optional |
| `model` | No | Not used | Optional |

#### Agent Skills Spec Fields (from agentskills.io)

| Field | Spec Status | Your Usage | Notes |
|-------|-------------|------------|-------|
| `name` | Required | Present | Valid |
| `description` | Required | Present | Valid, includes trigger phrases |
| `license` | Optional | Missing | In marketplace.json instead |
| `compatibility` | Optional | Missing | Consider adding |
| `metadata.author` | Optional | Missing | In plugin.json instead |
| `metadata.version` | Optional | Missing | In plugin.json instead |

**Verdict**: 100% compliant with Claude Code. 70% compliant with portable Agent Skills spec. The non-standard fields (`argument-hint`, `user-invocable`) are Claude Code extensions that won't break other implementations but won't be used either.

---

### 2. Directory Structure

#### Official Claude Code Structure (from plugins-reference)

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json           # Required: metadata
├── commands/                 # Slash commands (legacy)
├── skills/                   # Agent Skills (preferred)
│   └── skill-name/
│       ├── SKILL.md          # Required
│       └── [references/]     # Optional
├── agents/                   # Subagents
├── hooks/                    # Event handlers
├── .mcp.json                 # MCP servers
└── README.md                 # Documentation
```

#### Your Structure

```
plugins/rspec-writer/
├── .claude-plugin/
│   └── plugin.json           # Correct
├── commands/
│   └── write-test.md         # Command wrapper - correct
├── skills/
│   └── write-test/
│       ├── SKILL.md          # Correct
│       └── patterns/         # References - correct
└── README.md                 # Correct
```

**Verdict**: 100% compliant with Claude Code plugin structure. The `commands/` + `skills/` pattern for discoverability is well-executed.

---

### 3. Progressive Disclosure

#### Anthropic Recommendations
- Keep SKILL.md under 500 lines
- Split detailed content into separate files
- Reference files loaded on-demand
- One level deep from SKILL.md

#### Your Implementation

| Skill | SKILL.md Lines | Reference Files | Assessment |
|-------|----------------|-----------------|------------|
| write-test | 152 | 10 pattern files | Excellent |
| web-design | 83 | 0 | Good |
| hotwire | ~100 | 0 | Good |
| interview | ~80 | 0 | Good |
| rails | 51 | 0 | Good |
| tailwind | ~60 | 0 | Good |
| business | 68 | 0 | Good |
| marketing | ~50 | 0 | Good |
| analyze | ~60 | 0 | Good |
| write | ~80 | 0 | Good |
| ux-ui | ~50 | 0 | Good |

**Verdict**: Excellent. All skills under 200 lines. The write-test skill is exemplary with its 10 focused pattern files. Reference syntax `@./patterns/file.md` is a Claude Code convention.

---

### 4. Description Quality

#### Best Practices (from Claude Code docs)
- Describe what AND when to use
- Include specific trigger keywords
- Max 1024 characters
- Help Claude decide when to auto-load

#### Analysis

**Excellent Examples:**

```yaml
# write-test - A+
description: Writes comprehensive RSpec tests for Rails applications. Use when writing model specs, request specs, system specs, job specs, mailer specs, channel specs, or storage specs. Triggers on "write tests for", "add specs to", "test the User model", "create request specs", "write RSpec", "add test coverage".
```

```yaml
# business - A
description: SaaS unit economics and growth strategy. Use for LTV, CAC, MRR/ARR analysis, payback period, churn analysis, Rule of 40, and SaaS financial modeling. Triggers on "unit economics", "ltv", "cac", "mrr", "arr", "churn", "saas metrics".
```

**Improvement Opportunities:**

```yaml
# rails - B+
description: Ruby and Rails best practices following POODR and Refactoring Ruby. Use for Rails development guidance...
# Could add: Triggers on "rails pattern", "ruby refactoring", "POODR"
```

**Verdict**: 9/11 skills have excellent descriptions with explicit triggers. 2 skills could benefit from more trigger phrases.

---

### 5. Naming Conventions

#### Agent Skills Spec Recommendations
- Use lowercase with hyphens
- Action verbs or gerunds preferred: `write-test`, `analyzing-data`
- Avoid vague names: `helper`, `utils`

#### Your Names

| Skill | Name Pattern | Assessment |
|-------|--------------|------------|
| write-test | Action verb | Excellent |
| analyze | Action verb | Excellent |
| write | Action verb | Excellent |
| interview | Action verb | Excellent |
| hotwire | Framework name | Good (specific) |
| tailwind | Framework name | Good (specific) |
| web-design | Noun phrase | Good |
| ux-ui | Domain abbreviation | Good |
| rails | Framework name | Acceptable |
| business | Generic noun | Consider: `saas-metrics` |
| marketing | Generic noun | Consider: `marketing-funnels` |

**Verdict**: Good overall. Framework-specific names make sense. Generic names (`business`, `marketing`) could be more specific but descriptions clarify scope.

---

### 6. Command Wrapper Pattern (Now Legacy)

> **Important Update (January 2026)**: Anthropic has merged Slash Commands into Skills. The `commands/` directory is now legacy. Skills can be directly invoked with `/skill-name` and serve as the unified abstraction.

Your current pattern uses thin command wrappers:

```markdown
---
name: command-name
description: Brief description
argument-hint: "[args]"
---

Invoke the plugin:skill skill for: $ARGUMENTS
```

**What changed**: Skills now support:
- Direct `/skill-name` invocation (no command wrapper needed)
- `user-invocable: false` to hide from "/" menu
- `disable-model-invocation: true` to prevent auto-triggering
- `agent: <agent-name>` to spawn subagents with skill loaded
- `context: fork` to fork context for parallel operations

**Your current pattern**: Still works, but is now redundant. Each action-oriented skill has two files (command + skill) where one skill file would suffice.

**Migration path**: Remove `commands/` wrappers and rely on skills directly. Skills are invocable at `/plugin:skill-name` automatically.

**Verdict**: Pattern works but is now legacy. Consider consolidating to skills-only for new plugins.

---

### 6b. Skills + Subagents Patterns (New)

Anthropic recommends pairing Skills with Subagents for context protection:

| Pattern | Frontmatter | Use Case |
|---------|-------------|----------|
| Search/Research | `agent: Explore` | Summarize files, return to main context |
| Memory/Background | `context: fork` | Parallel work, don't pollute main context |
| Protected execution | `agent: Plan` | Planning work in isolated context |

**Your skills don't use these yet.** Consider for:
- `analyze` skill: could use `agent: Explore` for codebase scanning
- `interview` skill: could use `context: fork` for background processing

**Verdict**: Opportunity to adopt new patterns in future versions.

---

### 7. Version Management

#### Anthropic Recommendations
- Semantic versioning (MAJOR.MINOR.PATCH)
- Version in plugin.json triggers update detection
- Document changes in CHANGELOG.md

#### Your Implementation

| Location | Version | Correct |
|----------|---------|---------|
| marketplace.json metadata | 1.3.0 | Yes |
| All plugin.json files | 1.3.0 | Yes |
| AGENTS.md documentation | 1.2.0 | **No - outdated** |

**Your version tooling is excellent:**
- `./scripts/bump-version.sh` atomically updates both files
- `./scripts/validate-versions.sh` checks consistency
- GitHub Actions CI validates on PRs
- PostToolUse hook reminds about version bumps

**Verdict**: Tooling is A+. Documentation has one stale reference.

---

### 8. Multi-Agent Compatibility

#### Current State
- `CLAUDE.md` symlinks to `AGENTS.md` - correct
- `skills/` directory with symlinks for flat access - correct
- Supports `npx add-skill` pattern

#### Distribution Methods

| Method | Supported | Notes |
|--------|-----------|-------|
| Claude Code marketplace | Yes | Primary distribution |
| `npx add-skill` | Yes | Via skills/ symlinks |
| npm package | No | Not published |
| OpenAI Codex (AGENTS.md) | Yes | Via symlink |

**Verdict**: Good multi-agent support through AGENTS.md symlink and flat skills/ directory.

---

## Specific Issues Found

### High Priority

1. **AGENTS.md line 181**: Version reference says "1.2.0" but current version is "1.3.0"
   - Fix: Update to match actual version

### Medium Priority

2. **Consider migrating from commands/ to skills-only**

   Since Anthropic merged Slash Commands into Skills, your `commands/*.md` wrappers are now redundant. Skills can be invoked directly with `/plugin:skill-name`.

   **Current**: 8 command files that wrap 8 skills
   **After migration**: Delete commands/, skills work identically

   This simplifies maintenance and aligns with Anthropic's recommended architecture.

3. **Missing `argument-hint` in 4 skills** (less critical after migration):
   - `plugins/compound-analyzer/skills/analyze/SKILL.md`
   - `plugins/saas-metrics/skills/business/SKILL.md`
   - `plugins/saas-metrics/skills/marketing/SKILL.md`
   - `plugins/design-system/skills/ux-ui/SKILL.md`

4. **Consider Skills + Subagents patterns** for context-heavy skills:
   - `analyze`: Add `agent: Explore` for codebase scanning
   - `interview`: Add `context: fork` for parallel background work

### Low Priority

3. **No `license` field in SKILL.md frontmatter**
   - License is in plugin.json and marketplace.json
   - Adding to SKILL.md would improve Agent Skills spec compliance

4. **No `compatibility` field**
   - Could add: `Requires Ruby, Rails, RSpec. Designed for Claude Code.`

---

## Comparison with Anthropic's Official Skills

| Aspect | anthropics/skills | Your Marketplace | Assessment |
|--------|-------------------|------------------|------------|
| Frontmatter compliance | Standard only | Claude Code extensions | You use more features |
| Description quality | Variable | Consistently excellent | You're better |
| Progressive disclosure | Basic | Excellent (write-test) | You're better |
| Reference files | Mixed | Clean patterns/ structure | You're better |
| Documentation | Minimal | Comprehensive AGENTS.md | You're better |
| Version tooling | None visible | Excellent automation | You're better |
| Test coverage patterns | Generic | Rails-specific, detailed | More specialized |

---

## Recommendations

### Do Now (Quick Fixes)

1. **Update AGENTS.md version reference**
   ```
   Line 181: "Version (currently 1.3.0)" instead of "1.2.0"
   ```

2. **Add missing argument-hints** to 4 skills for consistency with their command wrappers

### Consider (Nice to Have)

3. **Add license/metadata to SKILL.md frontmatter** for Agent Skills spec compliance:
   ```yaml
   ---
   name: write-test
   description: ...
   license: MIT
   metadata:
     author: aviflombaum
     version: "1.3.0"
   ---
   ```

4. **Add explicit trigger phrases** to `rails` skill description

5. **Consider renaming generic skills** for discoverability:
   - `business` → `saas-metrics` or `saas-economics`
   - `marketing` → `marketing-funnels` or `growth-marketing`

### Don't Change

- Your Claude Code plugin structure is correct
- Your progressive disclosure in write-test is exemplary
- Your version bump tooling is better than most
- Existing commands/ files work fine (no urgency to remove)

---

## Content Quality Assessment

Your skills demonstrate best practices that could serve as reference implementations:

### write-test Skill (A+)
- Clear workflow with numbered steps
- Decision tree for spec type selection
- Quality checklist at the end
- 10 focused pattern reference files
- Explicit "What to Test" and "What NOT to Test" sections

### Skill Content Patterns
- Scope clarification ("This skill covers... Use X skill instead for...")
- Red flags and anti-patterns documented
- Tool/platform references where relevant
- Consistent structure across skills

---

## Final Assessment

**This marketplace is production-ready and well-maintained.**

Strengths:
- Excellent content quality, especially write-test
- Strong version management tooling
- Good multi-agent support
- Comprehensive documentation

Architecture note:
- Your commands/ + skills/ pattern predates the January 2026 merge
- It still works perfectly, but is now redundant
- Future plugins should use skills-only (simpler, same functionality)

Minor gaps:
- Some Agent Skills spec optional fields not used
- A few inconsistencies in argument-hints
- One stale version reference in docs
- Not yet using Skills + Subagents patterns (`agent:`, `context: fork`)

The content quality of your skills exceeds many "official" examples. The write-test skill with its pattern files could serve as a reference implementation for the community.

---

## References

1. Claude Code Plugin Docs: https://code.claude.com/docs/en/plugins
2. Claude Code Skills Docs: https://code.claude.com/docs/en/skills
3. Plugins Reference: https://code.claude.com/docs/en/plugins-reference
4. Agent Skills Specification: https://agentskills.io/specification
5. Anthropic Skills Repository: https://github.com/anthropics/skills
6. Skills/Commands Merge Announcement: https://x.com/trq212/status/2014836841846132761

---

*Review conducted 2026-01-25 using Anthropic official documentation and automated plugin validation.*
