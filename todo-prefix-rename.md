---
title: "Add avinyc: prefix to all remaining skills"
marketplace: claude-code-in-avinyc
status: done
depends_on: [plan-04]
---

# Add avinyc: prefix to all remaining skills

All skills in this marketplace should use the `avinyc:` namespace prefix for clarity and to avoid collisions with other marketplaces.

## Skill rename mapping

| Current name | Target name | Plugin |
|---|---|---|
| commit | avinyc:commit | git-workflows |
| rails-worktree | avinyc:rails-worktree | git-workflows (already done) |
| interview | avinyc:interview | plan-interview |
| search | avinyc:qmd-search | qmd |
| configure | avinyc:qmd-configure | qmd |
| doctor | avinyc:qmd-doctor | qmd |
| status | avinyc:qmd-status | qmd |
| analyze | avinyc:analyze | compound-analyzer |
| ux-ui | avinyc:ux-ui | design-system |
| web-design | avinyc:web-design | design-system |
| business | avinyc:business | saas-metrics |
| marketing | avinyc:marketing | saas-metrics |
| write | avinyc:write | tech-writer |
| bootstrap | avinyc:warp-bootstrap | warp-rails |
| monitor-config | avinyc:monitor-config | monitor-config |

## Notes

- `avinyc:rails-worktree` was already renamed in Plan 04
- Some skills get more descriptive names (e.g., `search` becomes `avinyc:qmd-search`, `bootstrap` becomes `avinyc:warp-bootstrap`) to clarify their scope
- Update the `name:` field in each skill's SKILL.md frontmatter
