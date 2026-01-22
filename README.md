# Claude Code Plugins

A curated collection of Claude Code plugins for Ruby, Rails, and SaaS development.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Plugins](https://img.shields.io/badge/plugins-8-green.svg)](#available-plugins)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-blueviolet.svg)](https://claude.ai/code)

## Quick Start

```bash
# Add this marketplace to Claude Code
/plugin marketplace add aviflombaum/claude-code-in-avinyc

# Install all plugins
/plugin install rspec-writer@claude-code-in-avinyc
/plugin install rails-frontend@claude-code-in-avinyc
/plugin install rails-expert@claude-code-in-avinyc
/plugin install design-system@claude-code-in-avinyc
/plugin install saas-metrics@claude-code-in-avinyc
/plugin install tech-writer@claude-code-in-avinyc
/plugin install compound-analyzer@claude-code-in-avinyc
/plugin install plan-interview@claude-code-in-avinyc
```

## Available Plugins

### Rails Development

| Plugin | "/" Commands | Auto-triggered Skills |
|--------|--------------|----------------------|
| [**rspec-writer**](plugins/rspec-writer/README.md) | `/rspec:write-test` | write-test |
| [**rails-frontend**](plugins/rails-frontend/README.md) | `/hotwire` | hotwire, tailwind |
| [**rails-expert**](plugins/rails-expert/README.md) | - | rails |

### Design & UX

| Plugin | "/" Commands | Auto-triggered Skills |
|--------|--------------|----------------------|
| [**design-system**](plugins/design-system/README.md) | `/avinyc:web-design` | web-designer, ux-ui |

### Business & Writing

| Plugin | "/" Commands | Auto-triggered Skills |
|--------|--------------|----------------------|
| [**saas-metrics**](plugins/saas-metrics/README.md) | `/saas:business`, `/saas:marketing` | business, marketing |
| [**tech-writer**](plugins/tech-writer/README.md) | `/avinyc:write` | write |

### Productivity

| Plugin | "/" Commands | Auto-triggered Skills |
|--------|--------------|----------------------|
| [**compound-analyzer**](plugins/compound-analyzer/README.md) | `/compound:analyze` | analyze |
| [**plan-interview**](plugins/plan-interview/README.md) | `/avinyc:interview` | interview |

---

## Plugin Details

### rspec-writer

Generate comprehensive RSpec tests for Rails applications.

```bash
# Write tests for a model
/rspec:write-test model User

# Or describe what you need
"Write request specs for the Posts controller"
```

**Supports:** Model specs, request specs, system specs, job specs, mailer specs, channel specs, ActiveStorage specs

**Conventions:**
- Uses fixtures, not factories
- Modern `expect().to` syntax only
- Runs with `--fail-fast` flag

---

### rails-frontend

Modern Rails frontend development with Hotwire and Tailwind.

```bash
# Create a Stimulus controller
/hotwire controller dropdown toggle

# Tailwind knowledge auto-triggers when styling
"Style this card with shadow and hover state"
```

**`/hotwire` command:** Turbo Frames, Turbo Streams, Stimulus controllers, morphing, broadcasts

**`tailwind` skill (auto-triggered):** Utility patterns, responsive design, component styling, animations

---

### rails-expert

Ruby and Rails best practices from the books that matter.

```bash
# Rails knowledge auto-triggers when discussing Rails
"What's the best practice for service objects?"
```

**`rails` skill (auto-triggered):** Applies POODR and Refactoring Ruby principles automatically when discussing Rails code.

**References:**
- Practical Object Oriented Design in Ruby (POODR) by Sandi Metz
- Refactoring: Ruby Edition by Martin Fowler
- Everyday Rails Testing with RSpec

---

### design-system

UI/UX design expertise for building beautiful, usable interfaces.

```bash
# Design a landing page
/avinyc:web-design hero section for a SaaS product

# UX knowledge auto-triggers when discussing usability
"What's the best information architecture for a settings page?"
```

**`/avinyc:web-design` command:** Visual hierarchy, typography, color theory, layout systems, design aesthetics (Bauhaus, Retro, Futuristic)

**`ux-ui` skill (auto-triggered):** Usability principles, accessibility, interaction design, information architecture

---

### saas-metrics

SaaS business metrics for founders building products.

```bash
# Analyze unit economics
/saas:business calculate LTV:CAC ratio

# Model a marketing funnel
/saas:marketing ad spend to conversion analysis
```

**Business skill:** LTV, CAC, MRR/ARR, churn analysis, payback period, Rule of 40

**Marketing skill:** CPM, CPC, conversion funnels, landing page optimization, waitlist economics

---

### tech-writer

Write technical content with Flatiron School's engaging teaching style.

```bash
# Write a blog post
/avinyc:write blog "How to implement Action Cable"

# Create a tutorial
/avinyc:write tutorial "Building a Rails API"
```

**Style:** Technically unimpeachable yet refreshingly human. Strong opinions, loosely held. Clarity through progression.

---

### compound-analyzer

Identify automation and systematization opportunities in your development work.

```bash
# Analyze completed work
/compound:analyze

# Or describe what to review
"Analyze this feature for automation opportunities"
```

**Identifies:** Delegation opportunities, automation candidates, pattern extraction, workflow systematization

---

### plan-interview

Refine project plans through in-depth Socratic questioning.

```bash
# Interview about a plan
/avinyc:interview path/to/plan.md
```

**Questions cover:** Technical implementation, UI/UX considerations, edge cases, tradeoffs, assumptions

---

## Architecture: Commands vs Skills

This marketplace uses both **commands** and **skills**:

- **Commands** (`/command-name`): Appear in "/" autocomplete. Use for explicit actions.
- **Skills** (auto-triggered): Loaded based on conversation context. Use for contextual knowledge.

**Pattern:** Action-oriented features get both. Contextual knowledge gets skills only.

| Type | "/" Autocomplete | Auto-detection | Example |
|------|-----------------|----------------|---------|
| Command + Skill | Yes | Yes | `/rspec:write-test`, `/compound:analyze` |
| Skill only | No | Yes | `rails`, `tailwind`, `ux-ui` |

## Contributing

1. Fork the repository
2. Create your plugin in `plugins/<plugin-name>/`
3. Add `.claude-plugin/plugin.json` manifest
4. Add skills under `skills/<skill-name>/SKILL.md`
5. For action-oriented skills, add a command wrapper in `commands/<command-name>.md`:
   ```markdown
   ---
   name: command-name
   description: Brief description
   argument-hint: "[args]"
   ---

   Invoke the plugin-name:skill-name skill for: $ARGUMENTS
   ```
6. Register in `.claude-plugin/marketplace.json`
7. **Bump version** in `plugin.json` and matching entry in `marketplace.json` (required for updates to propagate)
8. Submit a pull request

## License

MIT
