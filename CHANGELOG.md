# Changelog

All notable changes to this project will be documented in this file.

## [1.3.2] - 2025-01-25

### Added
- **Local development tooling**: New scripts for testing plugins locally before pushing
  - `scripts/setup-local-dev.sh` - Configure Claude Code to load from local directory
  - `scripts/validate-settings.sh` - Verify all plugins are enabled in settings
- **Documentation**: Added "Local Development" section to AGENTS.md explaining how to test changes locally
- **CI validation**: GitHub Actions now validates `settings.local.json` completeness

### Changed
- Updated CI workflow to check settings completeness alongside version validation
- Improved PR failure comments with instructions for both version bumps and settings fixes

### Fixed
- Resolved issue where local marketplace changes weren't reflected in Claude Code sessions (requires `known_marketplaces.json` to use `directory` source instead of `github`)

## [1.3.1] - 2025-01-25

### Added
- Subagent patterns for compound-analyzer, design-system, and saas-metrics plugins
- Standards compliance audit (REVIEW.md)

### Changed
- All plugins bumped to 1.3.1
- Updated contact email to im@avi.nyc

## [1.3.0] - 2025-01-24

### Changed
- Consolidated all plugins to version 1.3.0
- Updated author email across all manifests

## [1.2.0] - 2025-01-23

### Added
- Version bump enforcement system with three layers:
  - Claude Code hook for real-time reminders
  - `scripts/bump-version.sh` for atomic updates
  - GitHub Actions CI validation on PRs
- Namespaced commands to avoid conflicts:
  - `avinyc:*` for personal style
  - `compound:*` for compound engineering
  - `saas:*` for SaaS domain
  - `rspec:*` for framework tools

### Changed
- Refactored naming for consistency across plugins
- Removed duplicate patterns and consolidated documentation

## [1.1.0] - 2025-01-22

### Added
- Command wrappers for action-oriented skills (improves "/" autocomplete discoverability)
- Commands vs Skills architecture documentation
- Version field to marketplace metadata

## [1.0.0] - 2025-01-21

### Added
- Initial release with 8 plugins:
  - **rspec-writer**: RSpec test generation for Rails
  - **rails-frontend**: Hotwire (Turbo, Stimulus) and Tailwind CSS
  - **rails-expert**: POODR and Refactoring Ruby best practices
  - **design-system**: Web design and UX/UI principles
  - **saas-metrics**: Business metrics and marketing analytics
  - **tech-writer**: Technical writing with Flatiron style
  - **compound-analyzer**: Automation opportunity identification
  - **plan-interview**: Socratic plan refinement
- Multi-agent compatibility via Agent Skills specification
- Symlinked skills directory for `npx add-skill` support
