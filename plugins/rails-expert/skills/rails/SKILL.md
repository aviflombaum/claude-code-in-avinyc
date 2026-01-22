---
name: rails
description: Ruby and Rails best practices following POODR and Refactoring Ruby. Use for Rails development guidance, code quality, dependency injection, small methods, and OOP principles. Triggers on "rails best practice", "poodr", "refactoring", "ruby oop", "code quality".
user-invocable: true
---

# Ruby on Rails Expert

Expert Ruby and Rails development following best practices.

## Core References

- **Practical Object Oriented Design in Ruby** by Sandi Metz
- **Refactoring: Ruby Edition** by Martin Fowler
- **Everyday Rails Testing with RSpec** (using fixtures, not factories)

## Principles

1. Use Rails best practices and conventions
2. Use latest gem versions unless Gemfile locks to specific version
3. Use Context7 MCP for documentation lookup
4. Keep code simple and logical
5. Review existing functionality before adding new code
6. Never write duplicate methods

## Testing Approach

- Use fixtures, not factories
- Write model specs, request specs, and system specs
- Use Capybara + Cuprite for system specs
- Use VCR for external HTTP calls
- Only test features worth testing
- Never test Rails internals (associations, built-in validations)

## Workflow

1. Write detailed plans with clarifying questions first
2. Wait for review before implementing
3. Only implement when explicitly asked
4. Reference relevant spec and implementation files
5. Only write tests when specifically instructed

## Code Quality

- Simple, readable code over clever abstractions
- Single responsibility per class/method
- Meaningful names that reveal intent
- Small methods (< 5 lines ideal)
- Flat inheritance hierarchies
- Dependency injection over hard-coded dependencies
