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

| Plugin | Description | Skills |
|--------|-------------|--------|
| **rspec-writer** | AI-powered RSpec test generation | `/write-test` |
| **rails-frontend** | Hotwire, Turbo, Stimulus, Tailwind | `/hotwire`, `/tailwind` |
| **rails-expert** | POODR and Refactoring Ruby patterns | `/rails` |

### Design & UX

| Plugin | Description | Skills |
|--------|-------------|--------|
| **design-system** | UI/UX design and visual implementation | `/web-designer`, `/ux-ui` |

### Business & Writing

| Plugin | Description | Skills |
|--------|-------------|--------|
| **saas-metrics** | SaaS unit economics and marketing analytics | `/business`, `/marketing` |
| **tech-writer** | Technical blog posts in Flatiron style | `/write` |

### Productivity

| Plugin | Description | Skills |
|--------|-------------|--------|
| **compound-analyzer** | Identify automation opportunities | `/analyze` |
| **plan-interview** | Refine plans through Socratic questioning | `/interview` |

---

## Plugin Details

### rspec-writer

Generate comprehensive RSpec tests for Rails applications.

```bash
# Write tests for a model
/write-test model User

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

# Style a component
/tailwind card with shadow and hover state
```

**Hotwire skill covers:** Turbo Frames, Turbo Streams, Stimulus controllers, morphing, broadcasts

**Tailwind skill covers:** Utility patterns, responsive design, component styling, animations

---

### rails-expert

Ruby and Rails best practices from the books that matter.

```bash
# Get guidance on Rails patterns
/rails best practice for service objects
```

**References:**
- Practical Object Oriented Design in Ruby (POODR) by Sandi Metz
- Refactoring: Ruby Edition by Martin Fowler
- Everyday Rails Testing with RSpec

---

### design-system

UI/UX design expertise for building beautiful, usable interfaces.

```bash
# Design a landing page
/web-designer hero section for a SaaS product

# Get UX guidance
/ux-ui information architecture for settings page
```

**Web Designer:** Visual hierarchy, typography, color theory, layout systems, design aesthetics (Bauhaus, Retro, Futuristic)

**UX/UI:** Usability principles, accessibility, interaction design, information architecture

---

### saas-metrics

SaaS business metrics for founders building products.

```bash
# Analyze unit economics
/business calculate LTV:CAC ratio

# Model a marketing funnel
/marketing ad spend to conversion analysis
```

**Business skill:** LTV, CAC, MRR/ARR, churn analysis, payback period, Rule of 40

**Marketing skill:** CPM, CPC, conversion funnels, landing page optimization, waitlist economics

---

### tech-writer

Write technical content with Flatiron School's engaging teaching style.

```bash
# Write a blog post
/write blog "How to implement Action Cable"

# Create a tutorial
/write tutorial "Building a Rails API"
```

**Style:** Technically unimpeachable yet refreshingly human. Strong opinions, loosely held. Clarity through progression.

---

### compound-analyzer

Identify automation and systematization opportunities in your development work.

```bash
# Analyze completed work
/analyze

# Or describe what to review
"Analyze this feature for automation opportunities"
```

**Identifies:** Delegation opportunities, automation candidates, pattern extraction, workflow systematization

---

### plan-interview

Refine project plans through in-depth Socratic questioning.

```bash
# Interview about a plan
/interview path/to/plan.md
```

**Questions cover:** Technical implementation, UI/UX considerations, edge cases, tradeoffs, assumptions

---

## Contributing

1. Fork the repository
2. Create your plugin in `plugins/<plugin-name>/`
3. Add `.claude-plugin/plugin.json` manifest
4. Add skills under `skills/<skill-name>/SKILL.md`
5. Register in `.claude-plugin/marketplace.json`
6. Submit a pull request

## License

MIT
