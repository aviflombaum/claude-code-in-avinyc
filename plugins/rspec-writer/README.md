# rspec-writer

AI-powered RSpec test generation for Rails applications.

## Installation

```bash
/plugin install rspec-writer@claude-code-in-avinyc
```

## Usage

### Slash Command

```bash
/rspec:write-test model User
/rspec:write-test request Posts
/rspec:write-test system checkout
```

### Natural Language

Just ask Claude to write tests:

- "Write tests for the User model"
- "Add request specs for the Posts controller"
- "Create system specs for the checkout flow"

## Supported Spec Types

| Type | Location | Use For |
|------|----------|---------|
| Model | `spec/models/` | Validations, scopes, methods, callbacks |
| Request | `spec/requests/` | HTTP routing, auth, status codes, redirects |
| System | `spec/system/` | Full user flows, UI interactions |
| Job | `spec/jobs/` | Background job logic, queuing, retries |
| Mailer | `spec/mailers/` | Email headers, body, attachments |
| Channel | `spec/channels/` | WebSocket subscriptions, broadcasts |
| Storage | `spec/models/` | ActiveStorage attachments, validations |

## Conventions

This plugin follows opinionated Rails testing best practices:

- **Fixtures over factories** - Use `users(:admin)`, not `create(:user)`
- **Modern syntax** - `expect().to`, never `should`
- **Fast feedback** - Always run with `--fail-fast`
- **Focused tests** - One outcome per example

## Pattern Files

Detailed patterns are available for each spec type:

- `patterns/model-specs.md` - Model testing patterns
- `patterns/request-specs.md` - Request/controller testing
- `patterns/system-specs.md` - System/integration testing
- `patterns/job-specs.md` - ActiveJob testing
- `patterns/mailer-specs.md` - ActionMailer testing
- `patterns/channel-specs.md` - ActionCable testing
- `patterns/storage-specs.md` - ActiveStorage testing
- `patterns/fixtures.md` - Fixture management
- `patterns/isolation.md` - Mocks, stubs, VCR
- `patterns/dry-patterns.md` - Shared examples, matchers

## License

MIT
