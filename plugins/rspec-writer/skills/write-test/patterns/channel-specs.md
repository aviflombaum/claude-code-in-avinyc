# ActionCable Specs Pattern

Location: `spec/channels/<channel_name>_spec.rb`

## Purpose

Test WebSocket connections, channel subscriptions, broadcasts, and real-time features. Keep tests fast and deterministic.

## Core Principles

1. **Stub connections** - Use `stub_connection` for identifiers
2. **Test isolation** - Each test independent
3. **No real WebSockets** - Test logic, not transport
4. **Deterministic assertions** - No timing dependencies
5. **Test both paths** - Success and rejection

## Structure Pattern

```ruby
RSpec.describe ChatChannel, type: :channel do
  let(:user) { users(:alice) }

  before { stub_connection current_user: user }

  describe "#subscribed" do
    it "subscribes to room stream" do
      subscribe room_id: 42

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("chat_42")
    end

    it "rejects without room_id" do
      subscribe room_id: nil

      expect(subscription).to be_rejected
    end
  end

  describe "#speak" do
    it "broadcasts message" do
      subscribe room_id: 42

      expect {
        perform :speak, message: "Hello!"
      }.to have_broadcasted_to("chat_42")
        .with(a_hash_including(text: "Hello!"))
    end
  end
end
```

## Connection Testing

```ruby
RSpec.describe ApplicationCable::Connection, type: :channel do
  it "connects with valid cookie" do
    connect "/cable", cookies: { user_id: "42" }

    expect(connection.current_user.id).to eq(42)
  end

  it "rejects without authentication" do
    expect { connect "/cable" }.to have_rejected_connection
  end

  it "connects with token header" do
    user = users(:alice)

    connect "/cable", headers: { "Authorization" => "Bearer #{user.auth_token}" }

    expect(connection.current_user).to eq(user)
  end
end
```

## Subscription Testing

### Confirmed Subscription
```ruby
it "subscribes successfully" do
  subscribe room_id: 42

  expect(subscription).to be_confirmed
end
```

### Stream Verification
```ruby
it "streams from room channel" do
  subscribe room_id: 42

  expect(subscription).to have_stream_from("chat_42")
end

it "streams for model" do
  room = rooms(:general)
  subscribe room_id: room.id

  expect(subscription).to have_stream_for(room)
end
```

### Rejected Subscription
```ruby
it "rejects unauthorized user" do
  stub_connection current_user: users(:banned)
  subscribe room_id: 42

  expect(subscription).to be_rejected
end

it "rejects invalid room" do
  subscribe room_id: 999

  expect(subscription).to be_rejected
end
```

## Action Testing

```ruby
describe "#speak" do
  before { subscribe room_id: 42 }

  it "broadcasts to room" do
    expect {
      perform :speak, message: "Hello"
    }.to have_broadcasted_to("chat_42")
  end

  it "includes user info" do
    perform :speak, message: "Hello"

    expect(transmissions.last).to include(
      "user_id" => user.id,
      "text" => "Hello"
    )
  end
end

describe "#typing" do
  before { subscribe room_id: 42 }

  it "broadcasts typing indicator" do
    expect {
      perform :typing
    }.to have_broadcasted_to("chat_42")
      .with(hash_including(type: "typing", user_id: user.id))
  end
end
```

## Broadcast Matchers

### Basic Broadcasting
```ruby
expect {
  ActionCable.server.broadcast("notifications", data)
}.to have_broadcasted_to("notifications")
  .with(hash_including(text: "Hello"))
  .exactly(:once)
```

### Channel-Specific Broadcasting
```ruby
expect {
  ChatChannel.broadcast_to(user, message)
}.to have_broadcasted_to(user)
  .from_channel(ChatChannel)
```

### Count Specifications
```ruby
.exactly(3).times
.at_least(2).times
.at_most(:twice)
.exactly(:once)
```

### No Broadcast
```ruby
expect { some_action }.not_to have_broadcasted_to("stream")
```

## Integration with Controllers

```ruby
RSpec.describe MessagesController, type: :request do
  it "broadcasts on create" do
    room = rooms(:general)

    expect {
      post room_messages_path(room, as: users(:alice)),
           params: { message: { body: "Test" } }
    }.to have_broadcasted_to("room_#{room.id}")
      .with(a_hash_including(body: "Test"))
  end
end
```

## Presence Testing

```ruby
describe "presence" do
  it "broadcasts join on subscribe" do
    expect {
      subscribe room_id: 42
    }.to have_broadcasted_to("chat_42")
      .with(hash_including(type: "presence", action: "join"))
  end

  it "broadcasts leave on unsubscribe" do
    subscribe room_id: 42

    expect {
      subscription.unsubscribe_from_channel
    }.to have_broadcasted_to("chat_42")
      .with(hash_including(type: "presence", action: "leave"))
  end
end
```

## Transmission Testing

```ruby
describe "direct transmissions" do
  before { subscribe room_id: 42 }

  it "transmits to subscriber" do
    perform :request_history

    expect(transmissions.size).to eq(1)
    expect(transmissions.last).to include("type" => "history")
  end
end
```

## Rate Limiting Testing

```ruby
describe "rate limiting" do
  before { subscribe room_id: 42 }

  it "limits message frequency" do
    10.times { perform :speak, message: "Spam" }

    expect(transmissions.last).to include("error" => "rate_limited")
  end
end
```

## Shared Examples

```ruby
RSpec.shared_examples "requires authentication" do
  it "rejects unauthenticated" do
    stub_connection current_user: nil
    subscribe

    expect(subscription).to be_rejected
  end
end

RSpec.describe ChatChannel, type: :channel do
  it_behaves_like "requires authentication"
end
```

## Helper Methods

```ruby
# spec/support/action_cable_helper.rb
module ActionCableHelper
  def subscribe_as(user, **params)
    stub_connection current_user: user
    subscribe(**params)
  end

  def perform_as(user, action, **params)
    subscribe_as(user, room_id: params.delete(:room_id) || 42)
    perform(action, **params)
  end
end

RSpec.configure do |config|
  config.include ActionCableHelper, type: :channel
  config.include ActionCable::TestHelper, type: :channel
  config.include ActionCable::TestHelper, type: :request
end
```

## Configuration

```yaml
# config/cable.yml
test:
  adapter: test
```

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.include ActionCable::TestHelper, type: :channel
  config.include ActionCable::TestHelper, type: :request
end
```

## Anti-Patterns to Avoid

- Testing WebSocket transport directly
- Relying on sleep or arbitrary delays
- Not stubbing connection identifiers
- Missing rejection/failure cases
- Testing Rails internals vs application behavior
- Forgetting to test broadcast content

## Quality Checklist

- [ ] Connection authentication tested?
- [ ] All channels have subscription tests?
- [ ] Channel actions covered with perform tests?
- [ ] Broadcasts verified with content assertions?
- [ ] Rejection scenarios tested?
- [ ] Stream naming consistent?
- [ ] Integration tests for controller broadcasts?
- [ ] No timing-dependent assertions?
- [ ] Helper methods for common patterns?
