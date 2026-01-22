# DRY Patterns

## Purpose

Optimize RSpec test suites by reducing duplication while maintaining readability. Balance DRY (Don't Repeat Yourself) with DAMP (Descriptive And Meaningful Phrases).

## Core Principles

1. **Preserve behavior** - Never change assertions
2. **Localize abstractions** - Keep helpers near usage
3. **Prefer `before(:each)`** - Never `before(:all)` with ActiveRecord
4. **Readability over cleverness** - Specs as documentation
5. **Max 3 nesting levels** - Keep structure flat

## When to Abstract

- Repeatable workflows (login, auth headers)
- Shared data shapes used in many files
- Repeated assertions that benefit from naming
- Setup that truly applies to all examples

## When to Keep Inline

- Test-specific setup that clarifies intent
- Small amounts of duplication (< 3 lines)
- One-off edge cases

## let vs let!

### let (Lazy - Default)
```ruby
let(:user) { users(:alice) }  # Created when first accessed

it "displays name" do
  expect(user.name).to eq("Alice")  # user created here
end
```

### let! (Eager - Use Sparingly)
```ruby
let!(:notification) { Notification.create!(user: user) }

it "shows notifications" do
  # notification already exists
  expect(page).to have_content(notification.message)
end
```

**Rule**: Default to `let`. Use `let!` only when laziness causes issues.

## Shared Examples

### Definition
```ruby
# spec/support/shared_examples/requires_authentication.rb
RSpec.shared_examples "requires authentication" do
  it "redirects to login" do
    expect(response).to redirect_to(sign_in_path)
  end

  it "sets flash message" do
    expect(flash[:alert]).to eq("Please sign in")
  end
end
```

### Usage
```ruby
RSpec.describe "Admin::Users", type: :request do
  describe "GET /admin/users" do
    context "as guest" do
      before { get admin_users_path }

      it_behaves_like "requires authentication"
    end
  end
end
```

### With Parameters
```ruby
RSpec.shared_examples "paginatable" do |per_page:|
  it "limits results" do
    expect(subject.count).to be <= per_page
  end

  it "provides pagination metadata" do
    expect(response_meta).to include(:total_pages, :current_page)
  end
end

# Usage
it_behaves_like "paginatable", per_page: 25
```

## Shared Contexts

### Definition
```ruby
# spec/support/shared_contexts/authenticated_user.rb
RSpec.shared_context "authenticated user" do
  let(:current_user) { users(:alice) }

  before do
    sign_in current_user
  end
end
```

### Usage
```ruby
RSpec.describe "Dashboard", type: :request do
  include_context "authenticated user"

  it "shows welcome message" do
    get dashboard_path
    expect(response.body).to include(current_user.name)
  end
end
```

## Custom Matchers

### Simple Matcher
```ruby
# spec/support/matchers/be_recent.rb
RSpec::Matchers.define :be_recent do
  match do |record|
    record.created_at > 1.hour.ago
  end

  failure_message do |record|
    "expected #{record} to be created within the last hour"
  end
end

# Usage
expect(post).to be_recent
```

### Matcher with Arguments
```ruby
RSpec::Matchers.define :have_error_on do |attribute|
  match do |record|
    record.valid?
    record.errors[attribute].any?
  end

  failure_message do |record|
    "expected #{record.class} to have error on #{attribute}"
  end
end

# Usage
expect(user).to have_error_on(:email)
```

### Composable Matcher
```ruby
RSpec::Matchers.define :be_valid_json do
  match do |string|
    JSON.parse(string)
    true
  rescue JSON::ParserError
    false
  end
end

# Usage
expect(response.body).to be_valid_json
```

## Support Modules

### Authentication Helper
```ruby
# spec/support/authentication_helper.rb
module AuthenticationHelper
  def sign_in_as(user)
    post session_path, params: {
      email: user.email,
      password: "password"
    }
  end

  def current_user
    @current_user ||= users(:alice)
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
  config.include AuthenticationHelper, type: :system
end
```

### JSON Helper
```ruby
# spec/support/json_helper.rb
module JsonHelper
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  def json_body
    json_response[:data]
  end

  def json_errors
    json_response[:errors]
  end
end

RSpec.configure do |config|
  config.include JsonHelper, type: :request
end
```

## aggregate_failures

Reduce setup duplication for multi-assertion tests:

```ruby
it "creates user with all attributes" do
  post users_path, params: { user: valid_attrs }

  aggregate_failures do
    expect(response).to redirect_to(user_path(User.last))
    expect(User.last.email).to eq(valid_attrs[:email])
    expect(User.last.name).to eq(valid_attrs[:name])
    expect(flash[:notice]).to eq("User created")
  end
end
```

## describe/context Organization

```ruby
RSpec.describe User, type: :model do
  # describe for the unit under test
  describe "#full_name" do
    # context for different states
    context "with first and last name" do
      it "combines names" do
        user = User.new(first_name: "John", last_name: "Doe")
        expect(user.full_name).to eq("John Doe")
      end
    end

    context "with only first name" do
      it "returns first name" do
        user = User.new(first_name: "John", last_name: nil)
        expect(user.full_name).to eq("John")
      end
    end
  end
end
```

## Setup Scoping

Keep setup at the nearest scope:

```ruby
# Bad - top-level setup for specific tests
RSpec.describe Order do
  let(:user) { users(:alice) }
  let(:product) { products(:widget) }
  let(:coupon) { coupons(:discount) }  # Only used in one test!

  it "calculates total" do
    # Uses user and product, not coupon
  end

  it "applies coupon" do
    # Uses coupon
  end
end

# Good - scoped setup
RSpec.describe Order do
  let(:user) { users(:alice) }
  let(:product) { products(:widget) }

  it "calculates total" do
    # Uses user and product
  end

  describe "with coupon" do
    let(:coupon) { coupons(:discount) }

    it "applies discount" do
      # Uses coupon
    end
  end
end
```

## Anti-Patterns to Avoid

- Huge top-level `before` blocks with unused data
- `before(:all)` with ActiveRecord writes
- Overuse of `let!` hiding state
- Deeply nested shared contexts
- One giant helpers module for everything
- Custom matchers duplicating built-ins
- Global magic that obscures intent

## Quality Checklist

- [ ] Outline reads clearly with describe/context/it?
- [ ] Shared setup at nearest scope?
- [ ] Example names outcome-focused?
- [ ] No `:all/:suite` DB setup?
- [ ] Nesting ≤ 3 levels?
- [ ] Helpers close to usage?
- [ ] Custom matchers provide better messages?
- [ ] DRY/DAMP balance appropriate?
