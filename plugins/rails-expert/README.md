# rails-expert

Ruby and Rails best practices following POODR and Refactoring Ruby.

## Installation

```bash
/plugin install rails-expert@claude-code-in-avinyc
```

## Usage

This skill activates automatically when discussing Rails code, architecture, or best practices. Just ask naturally:

- "How should I structure this service object?"
- "Is this controller following best practices?"
- "Help me refactor this method using POODR principles"
- "What's the Rails way to handle this?"

## Core References

- **Practical Object Oriented Design in Ruby** by Sandi Metz
- **Refactoring: Ruby Edition** by Martin Fowler
- **Everyday Rails Testing with RSpec** (using fixtures, not factories)

## Principles

1. Use Rails best practices and conventions
2. Use latest gem versions unless Gemfile locks to specific version
3. Keep code simple and logical
4. Review existing functionality before adding new code
5. Never write duplicate methods

## Code Quality Guidelines

- Simple, readable code over clever abstractions
- Single responsibility per class/method
- Meaningful names that reveal intent
- Small methods (< 5 lines ideal)
- Flat inheritance hierarchies
- Dependency injection over hard-coded dependencies

## Testing Approach

- Use fixtures, not factories
- Write model specs, request specs, and system specs
- Use Capybara + Cuprite for system specs
- Use VCR for external HTTP calls
- Only test features worth testing
- Never test Rails internals

## License

MIT
