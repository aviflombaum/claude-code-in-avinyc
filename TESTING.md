# Marketplace Validation Toolkit

## Overview

The validation toolkit ensures Claude Code marketplace/plugin structure is correct. All shared scripts live in `scripts/` in this repo (`claude-code-in-avinyc`), which is the canonical source.

- **Local use**: Other marketplaces symlink to these scripts. Changes here propagate immediately.
- **CI**: Workflows are copied (not symlinked) because GitHub Actions clones repos fresh and can't follow cross-repo symlinks. Version tracking keeps copies in sync.

## Scripts Reference

| Script | Description | Usage | Args |
|--------|-------------|-------|------|
| `validate-marketplace.sh` | Comprehensive 10-check marketplace validation | `./scripts/validate-marketplace.sh [--ci]` | `--ci`: suppress color, skip interactive checks |
| `validate-versions.sh` | Check version consistency between plugin.json and marketplace.json, detect unbumped changes | `./scripts/validate-versions.sh [base-branch]` | `base-branch`: branch to compare (default: `main`) |
| `bump-version.sh` | Bump semver in both plugin.json and marketplace.json | `./scripts/bump-version.sh <plugin> <type>` | `plugin`: plugin directory name, `type`: `patch`/`minor`/`major` |
| `validate-settings.sh` | Verify local settings has all plugins enabled | `./scripts/validate-settings.sh [marketplace-name]` | `marketplace-name`: override auto-detection |
| `setup-local-dev.sh` | Configure Claude Code to use local directory source | `./scripts/setup-local-dev.sh [name] [repo]` | `name`: marketplace name, `repo`: GitHub org/repo |
| `teardown-local-dev.sh` | Revert to GitHub source | `./scripts/teardown-local-dev.sh [name] [repo]` | `name`: marketplace name, `repo`: GitHub org/repo |
| `update-validation-ci.sh` | Sync CI workflow to target marketplaces when source updated | `./scripts/update-validation-ci.sh` | None (targets hardcoded) |

## Running Locally

```bash
# From any marketplace root (with symlinked scripts):
./scripts/validate-marketplace.sh

# Check version consistency:
./scripts/validate-versions.sh

# Bump a plugin version:
./scripts/bump-version.sh my-plugin patch
```

## CI/CD

The GitHub Actions workflow lives at `.github/workflows/validate.yml` and triggers on push/PR to main.

- Runs the same 10 checks as `validate-marketplace.sh` but **inline** (can't reference symlinked scripts in CI).
- Posts a PR comment on failure with details.
- Includes a `# Source-Version: X.Y.Z` comment for version tracking.
- To update all marketplaces' CI: `./scripts/update-validation-ci.sh`

## Script Metadata

Every shared script has a standard header:

```bash
#!/bin/bash
# ============================================================================
# Name:        script-name.sh
# Version:     1.0.0
# Description: One-line description
# Source:      claude-code-in-avinyc/scripts/script-name.sh
# Usage:       ./script-name.sh [args]
# Requires:    bash 4+, node/python3
# Updated:     YYYY-MM-DD
# ============================================================================
```

The `Version` field is used by `update-validation-ci.sh` to detect when CI workflows need updating. Bump this version when making changes that should propagate to CI.

## Adding a New Marketplace

1. Create `scripts/` directory in the marketplace.
2. Symlink each shared script: `ln -s /path/to/claude-code-in-avinyc/scripts/script.sh scripts/script.sh`
3. Symlink TESTING.md: `ln -s /path/to/claude-code-in-avinyc/TESTING.md TESTING.md`
4. Run `./scripts/update-validation-ci.sh` to generate the CI workflow.
5. Run `./scripts/validate-marketplace.sh` to verify everything passes.
6. Add the marketplace path to the `TARGETS` array in `update-validation-ci.sh`.

## Gotchas

- **Single-line descriptions (Issue #9817)**: SKILL.md `description:` MUST be a single line. Multi-line YAML (using `|` or `>`) silently breaks skill discovery. Use a single quoted string.
- **Allowed frontmatter keys**: Only these are valid in SKILL.md: `name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `context`, `agent`, `hooks`, `license`, `metadata`. Unknown keys cause validation warnings.
- **`$schema` dead link**: The `$schema` URL in marketplace.json/plugin.json is a dead link. Community schemas exist at `hesreallyhim/claude-code-json-schema` on GitHub.
- **Symlinks in CI**: GitHub Actions clones repos fresh -- symlinks pointing outside the repo will break. That's why CI workflows are COPIED, not symlinked. The `update-validation-ci.sh` script manages this.

## Symlink Architecture

```
claude-code-in-avinyc/scripts/          <- CANONICAL SOURCE
├── validate-marketplace.sh
├── validate-versions.sh
├── bump-version.sh
├── validate-settings.sh
├── setup-local-dev.sh
├── teardown-local-dev.sh
└── update-validation-ci.sh

avi-ai/scripts/
├── validate-marketplace.sh  -> symlink
├── validate-versions.sh     -> symlink
├── bump-version.sh          -> symlink
├── validate-settings.sh     -> symlink
├── setup-local-dev.sh       -> symlink
├── teardown-local-dev.sh    -> symlink
├── update-validation-ci.sh  -> symlink
└── migrate-to-public.sh     <- REAL FILE (unique to avi-ai)

innovent-ai/scripts/         -> all 7 symlinked
innovent-ai-devops/scripts/  -> all 7 symlinked
innovent-rails-skills/scripts/ -> all 7 symlinked

Each marketplace root also has:
TESTING.md -> symlink to claude-code-in-avinyc/TESTING.md
```

All symlinks point to the canonical source. Changes to scripts in `claude-code-in-avinyc` are immediately available everywhere locally. CI workflows must be updated separately via `update-validation-ci.sh`.
