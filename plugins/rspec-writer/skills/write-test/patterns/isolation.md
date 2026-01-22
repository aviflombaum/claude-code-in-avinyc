# Isolation Patterns

## Purpose

Use mocks, stubs, doubles, spies, and fakes strategically to:
- Cover rare/error paths that are hard to provoke
- Avoid slow or flaky external calls
- Make nondeterminism deterministic
- Replace heavy collaborators when performance matters

## Core Principles

1. **Preserve public behavior** - Test via public API only
2. **Scope narrowly** - Local stubs, never `allow_any_instance_of`
3. **Use verifying doubles** - `instance_double`, not plain `double`
4. **VCR for HTTP** - Record once, replay fast
5. **Assert outcomes** - Not internal call choreography

## When to Isolate

| Scenario | Approach |
|----------|----------|
| External APIs | VCR cassettes or WebMock |
| Randomness/time | Stub to deterministic values |
| Rare error paths | Stub to trigger them |
| Slow collaborators | Replace only if truly needed |

## When NOT to Isolate

- ActiveRecord operations (unless truly slow/flaky)
- Cheap internal collaborations
- Where integration tests provide clearer coverage

## Verifying Doubles

### instance_double (Recommended)
```ruby
# Verifies methods exist on the class
let(:gateway) { instance_double(PaymentGateway) }

before do
  allow(gateway).to receive(:charge).and_return(success: true)
end

it "processes payment" do
  result = PaymentService.new(gateway).process(order)
  expect(result).to be_success
end
```

### class_double
```ruby
# For class methods
let(:mailer) { class_double(UserMailer) }

before do
  allow(mailer).to receive(:welcome).and_return(double(deliver_later: true))
end
```

### Plain double (Avoid)
```ruby
# No verification - avoid this
let(:gateway) { double("Gateway", charge: true) }
```

## Stubbing Patterns

### Basic Stub
```ruby
allow(user).to receive(:admin?).and_return(true)
```

### With Arguments
```ruby
allow(api).to receive(:fetch).with(id: 123).and_return(data)
```

### Sequential Returns
```ruby
# First call fails, second succeeds
allow(api).to receive(:call)
  .and_return(nil, { status: "success" })

# Or with raise
allow(api).to receive(:call)
  .and_raise(Timeout::Error)
  .and_return({ status: "success" })
```

### Call Original
```ruby
allow(user).to receive(:full_name).and_call_original
```

### Yield
```ruby
allow(file).to receive(:open).and_yield(mock_io)
```

## Spy Pattern

Verify after the fact:

```ruby
it "logs the event" do
  logger = instance_spy(Logger)
  service = EventService.new(logger: logger)

  service.process(event)

  expect(logger).to have_received(:info).with(/processed/)
end
```

## VCR for HTTP

### Basic Usage
```ruby
it "fetches user data", :vcr do
  result = GitHubApi.fetch_user("octocat")
  expect(result[:login]).to eq("octocat")
end
```

### Named Cassette
```ruby
it "handles rate limiting" do
  VCR.use_cassette("github/rate_limited") do
    expect { GitHubApi.fetch_user("octocat") }
      .to raise_error(RateLimitError)
  end
end
```

### Configuration
```ruby
# spec/support/vcr.rb
VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Filter secrets
  config.filter_sensitive_data("<API_KEY>") { ENV["API_KEY"] }
  config.filter_sensitive_data("<AUTH_TOKEN>") { ENV["AUTH_TOKEN"] }

  # Allow localhost for system specs
  config.ignore_localhost = true
end
```

## WebMock (Without Recording)

```ruby
before do
  stub_request(:get, "https://api.example.com/users/1")
    .to_return(
      status: 200,
      body: { id: 1, name: "John" }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
end

it "fetches user" do
  user = Api.fetch_user(1)
  expect(user.name).to eq("John")
end
```

### Error Simulation
```ruby
stub_request(:get, /api.example.com/)
  .to_timeout

stub_request(:post, /api.example.com/)
  .to_return(status: 500, body: "Internal Error")
```

## Time Stubbing

```ruby
include ActiveSupport::Testing::TimeHelpers

it "expires after 24 hours" do
  token = Token.create!

  travel_to 25.hours.from_now do
    expect(token).to be_expired
  end
end

it "uses current time" do
  freeze_time do
    record = Record.create!
    expect(record.created_at).to eq(Time.current)
  end
end
```

## Randomness Stubbing

```ruby
it "generates predictable code" do
  allow(SecureRandom).to receive(:hex).and_return("abc123")

  code = VerificationCode.generate
  expect(code).to eq("abc123")
end
```

## Stubbing Rails Components

### Current Attributes
```ruby
before do
  allow(Current).to receive(:user).and_return(users(:alice))
end
```

### Environment
```ruby
it "behaves differently in production" do
  allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))

  expect(service.debug_mode?).to be false
end
```

## Partial Doubles

Stub methods on real objects:

```ruby
it "handles missing photo" do
  recipe = recipes(:without_photo)
  allow(recipe).to receive(:photo_url).and_return("placeholder.png")

  expect(recipe.display_image).to eq("placeholder.png")
end
```

## Dependency Injection

Better than stubbing globals:

```ruby
# Production code
class PaymentService
  def initialize(gateway: PaymentGateway.new)
    @gateway = gateway
  end

  def process(order)
    @gateway.charge(order.total)
  end
end

# Test
it "processes payment" do
  gateway = instance_double(PaymentGateway, charge: true)
  service = PaymentService.new(gateway: gateway)

  expect(service.process(order)).to be true
end
```

## Anti-Patterns to Avoid

- `allow_any_instance_of` - Fragile, hard to debug
- Blanket mocking of ActiveRecord
- Over-specifying internal call order
- Testing private methods
- Global stubs causing test pollution
- Plain `double` without verification

## Quality Checklist

- [ ] Using verifying doubles?
- [ ] Stubs scoped to specific examples?
- [ ] VCR for external HTTP?
- [ ] Secrets filtered from cassettes?
- [ ] Time helpers for time-dependent tests?
- [ ] Testing outcomes, not call choreography?
- [ ] No `allow_any_instance_of`?
- [ ] Dependency injection where appropriate?
