---
name: write-test
description: Write comprehensive RSpec tests for Rails applications. Use when writing model specs, request specs, system specs, job specs, mailer specs, channel specs, or storage specs.
argument-hint: "[model|request|system|job|mailer|channel] ClassName"
user-invocable: true
---

# RSpec Test Writer

You write comprehensive, production-ready RSpec tests for Rails applications.

**CRITICAL RULES:**
- NEVER edit rails_helper.rb or spec_helper.rb
- NEVER add testing gems to Gemfile
- Use fixtures, not factories: `users(:admin)`, not `create(:user)`
- Use `--fail-fast` flag when running specs
- Modern syntax only: `expect().to`, never `should`

## Workflow

1. **Parse the request** - Identify what needs testing (model, controller, job, etc.)
2. **Find the source file** - Use Glob/Grep to locate the code to test
3. **Read the code** - Understand validations, methods, associations, behavior
4. **Check existing fixtures** - Look in `spec/fixtures/*.yml` for test data
5. **Determine spec type** - Use the decision framework below
6. **Consult patterns** - Reference the appropriate pattern file
7. **Write the spec file** - Follow the patterns exactly
8. **Run with `--fail-fast`** - Execute: `bundle exec rspec <spec_file> --fail-fast`
9. **Fix failures** - Iterate until green
10. **Apply DRY patterns** - Check spec/support for existing helpers

## Decision Framework

```
What am I testing?
├── Data & Business Logic    → Model specs      → @./patterns/model-specs.md
├── HTTP & Controllers       → Request specs    → @./patterns/request-specs.md
├── User Interface           → System specs     → @./patterns/system-specs.md
├── Background Processing    → Job specs        → @./patterns/job-specs.md
├── Email                    → Mailer specs     → @./patterns/mailer-specs.md
├── File Uploads             → Storage specs    → @./patterns/storage-specs.md
├── Real-time Features       → Channel specs    → @./patterns/channel-specs.md
└── External Services        → Use isolation    → @./patterns/isolation.md
```

## Spec Type Quick Reference

| Type | Location | Use For |
|------|----------|---------|
| Model | `spec/models/` | Validations, scopes, methods, callbacks |
| Request | `spec/requests/` | HTTP routing, auth, status codes, redirects |
| System | `spec/system/` | Full user flows, UI interactions |
| Job | `spec/jobs/` | Background job logic, queuing, retries |
| Mailer | `spec/mailers/` | Email headers, body, attachments |
| Channel | `spec/channels/` | WebSocket subscriptions, broadcasts |

## Testing Strategy

### For New Features
1. Start with **model specs** for data layer
2. Add **request specs** for API/controllers
3. Finish with **system specs** for critical UI paths only

### For API Development
1. **Request specs** for endpoints
2. **Job specs** for async processing
3. **Mailer specs** for notifications

### For Real-time Features
1. **Channel specs** for subscriptions/broadcasts
2. **Model specs** for message/data logic
3. **System specs** for UI (with Cuprite for JS)

## Core Testing Principles

### What to Test
- Validations (presence, uniqueness, format)
- Business logic in model methods
- Scopes and query methods
- HTTP status codes and redirects
- Authentication and authorization
- Happy path + one critical edge case

### What NOT to Test
- Rails internals (associations work, built-in validations work)
- Private methods directly
- Implementation details
- Every possible edge case (unless asked)
- Performance

### Test Quality Rules
1. **One outcome per example** - Focused, clear tests
2. **Test behavior, not implementation** - Assert outcomes
3. **Local setup** - Keep data close to tests that need it
4. **Expressive names** - Describe behavior, not method names
5. **Minimal fixtures** - Use only what you need

## External Dependencies

When tests involve external services (APIs, payment gateways, etc.):
- Use VCR for HTTP recording/playback
- Use verifying doubles (`instance_double`)
- See @./patterns/isolation.md for patterns

## Fixtures

Always check existing fixtures before creating test data:
- See @./patterns/fixtures.md for patterns
- Access with `users(:alice)`, `recipes(:published)`
- Create records only when testing uniqueness or creation

## DRY Patterns

Before duplicating code, check `spec/support/` for:
- Shared examples
- Custom matchers
- Helper modules
- See @./patterns/dry-patterns.md for patterns

## Pattern Files Reference

Consult these files for detailed patterns and examples:

### Spec Types
- Model specs: @./patterns/model-specs.md
- Request specs: @./patterns/request-specs.md
- System specs: @./patterns/system-specs.md
- Job specs: @./patterns/job-specs.md
- Mailer specs: @./patterns/mailer-specs.md
- Storage specs: @./patterns/storage-specs.md
- Channel specs: @./patterns/channel-specs.md

### Testing Strategies
- Fixtures: @./patterns/fixtures.md
- Isolation (mocks/stubs/VCR): @./patterns/isolation.md
- DRY patterns: @./patterns/dry-patterns.md

## Quality Checklist

Before finishing, verify:

- [ ] Using correct spec type?
- [ ] One outcome per example?
- [ ] Fixtures for test data (not factories)?
- [ ] Authentication tested at appropriate scope?
- [ ] Happy path AND at least one edge case?
- [ ] No testing of Rails internals?
- [ ] External services isolated with VCR/doubles?
- [ ] Example names describe behavior?
- [ ] Tests pass with `bundle exec rspec <file> --fail-fast`?
- [ ] DRY patterns applied where appropriate?
