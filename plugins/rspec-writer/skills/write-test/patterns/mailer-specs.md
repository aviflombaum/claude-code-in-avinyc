# ActionMailer Specs Pattern

Location: `spec/mailers/<mailer_name>_spec.rb`

## Purpose

Test email functionality: headers, body content, attachments, delivery, and background processing.

## Core Principles

1. **Test headers** - Subject, to, from, cc, bcc
2. **Test body content** - Key elements, not exact HTML
3. **Test both parts** - HTML and plain text for multipart
4. **Clear deliveries** - Reset between tests
5. **Configure URL host** - Required for email links

## Structure Pattern

```ruby
RSpec.describe UserMailer, type: :mailer do
  describe "#welcome" do
    let(:user) { users(:alice) }
    let(:mail) { UserMailer.welcome(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to Our App")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["support@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Hi #{user.first_name}")
      expect(mail.body.encoded).to include("Welcome to our application")
    end

    it "includes action link" do
      expect(mail.body.encoded).to include(dashboard_url)
    end
  end
end
```

## Header Testing

```ruby
it "renders headers" do
  expect(mail.subject).to eq("Welcome!")
  expect(mail.to).to eq(["user@example.com"])
  expect(mail.from).to eq(["noreply@example.com"])
  expect(mail.cc).to eq(["admin@example.com"])
  expect(mail.bcc).to eq(["audit@example.com"])
  expect(mail.reply_to).to eq(["support@example.com"])
end
```

## Body Content Testing

```ruby
it "includes user name" do
  expect(mail.body.encoded).to include(user.name)
end

it "includes unsubscribe link" do
  expect(mail.body.encoded).to include(unsubscribe_url(user))
end

it "excludes sensitive data" do
  expect(mail.body.encoded).not_to include(user.password_digest)
end
```

## Multipart Email Testing

```ruby
describe "#notification" do
  let(:mail) { UserMailer.notification(user) }

  it "generates multipart message" do
    expect(mail).to be_multipart
    expect(mail.parts.length).to eq(2)
  end

  it "renders HTML version" do
    html_part = mail.parts.find { |p| p.content_type.include?("html") }

    expect(html_part.body.encoded).to include("<h1>Notification</h1>")
    expect(html_part.body.encoded).to include('class="button"')
  end

  it "renders text version" do
    text_part = mail.parts.find { |p| p.content_type.include?("plain") }

    expect(text_part.body.encoded).to include("NOTIFICATION")
    expect(text_part.body.encoded).not_to include("<h1>")
  end
end
```

## Parameterized Mailers

```ruby
RSpec.describe NotificationMailer, type: :mailer do
  describe "#digest" do
    let(:user) { users(:alice) }
    let(:date) { 1.week.ago }

    let(:mail) do
      NotificationMailer.with(user: user, since: date).digest
    end

    it "uses parameterized data" do
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to include("since #{date.strftime('%B %d')}")
    end

    it "includes recent items only" do
      expect(mail.body.encoded).to include(items(:recent).title)
      expect(mail.body.encoded).not_to include(items(:old).title)
    end
  end
end
```

## Attachment Testing

```ruby
describe "#report" do
  let(:mail) { ReportMailer.monthly_report(user) }

  it "attaches PDF report" do
    expect(mail.attachments.count).to eq(1)

    attachment = mail.attachments.first
    expect(attachment.filename).to eq("report.pdf")
    expect(attachment.content_type).to include("application/pdf")
  end
end

describe "#data_export" do
  let(:mail) { ReportMailer.data_export(user) }

  it "attaches CSV data" do
    csv = mail.attachments["export.csv"]

    expect(csv).to be_present
    expect(csv.body.encoded).to include("Name,Email")
  end
end
```

## Delivery Testing

### Synchronous Delivery
```ruby
it "sends immediately" do
  expect {
    UserMailer.welcome(user).deliver_now
  }.to change { ActionMailer::Base.deliveries.count }.by(1)

  delivered = ActionMailer::Base.deliveries.last
  expect(delivered.to).to eq([user.email])
end
```

### Asynchronous Delivery
```ruby
it "enqueues for later" do
  expect {
    UserMailer.welcome(user).deliver_later
  }.to have_enqueued_mail(UserMailer, :welcome)
    .with(user)
    .on_queue("mailers")
end
```

### Scheduled Delivery
```ruby
it "schedules for specific time" do
  expect {
    UserMailer.reminder(user).deliver_later(wait_until: Date.tomorrow.noon)
  }.to have_enqueued_mail(UserMailer, :reminder)
    .at(Date.tomorrow.noon)
end
```

## Conditional Email Testing

```ruby
describe "#notification" do
  context "when user has notifications enabled" do
    let(:user) { users(:with_notifications) }

    it "sends the email" do
      expect {
        UserMailer.notification(user).deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context "when user has notifications disabled" do
    let(:user) { users(:without_notifications) }

    it "does not send email" do
      mail = UserMailer.notification(user)
      expect(mail.message).to be_a(ActionMailer::Base::NullMail)
    end
  end
end
```

## Internationalized Emails

```ruby
describe "localized emails" do
  it "sends in user's locale" do
    user = users(:spanish_user)
    mail = UserMailer.welcome(user)

    expect(mail.subject).to eq("Bienvenido")
    expect(mail.body.encoded).to include("Hola")
  end

  it "falls back to default locale" do
    user = users(:unknown_locale_user)
    mail = UserMailer.welcome(user)

    expect(mail.subject).to eq("Welcome")
  end
end
```

## Configuration

### URL Host Setup
```ruby
# spec/support/mailer_url_options.rb
RSpec.configure do |config|
  config.before(:each, type: :mailer) do
    Rails.application.routes.default_url_options[:host] = "test.example.com"
    Rails.application.routes.default_url_options[:protocol] = "https"
  end
end
```

### Clear Deliveries
```ruby
RSpec.configure do |config|
  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end
end
```

## Anti-Patterns to Avoid

- Testing email delivery in system specs (slow)
- Not clearing deliveries between tests
- Forgetting to set default URL options
- Testing exact HTML instead of key content
- Not testing both HTML and text parts
- Missing conditional sending tests

## Quality Checklist

- [ ] Headers verified (subject, to, from)?
- [ ] Body content tested for key elements?
- [ ] URL helpers configured with host?
- [ ] Deliveries cleared between tests?
- [ ] Both HTML and text parts tested (if multipart)?
- [ ] Attachments verified (if applicable)?
- [ ] Parameterized mailers tested with `.with()`?
- [ ] Async delivery tested with job matchers?
- [ ] Conditional sending logic covered?
