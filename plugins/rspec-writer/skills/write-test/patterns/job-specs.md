# ActiveJob Specs Pattern

Location: `spec/jobs/<job_name>_spec.rb`

## Purpose

Test background jobs: execution logic, queuing, scheduling, retries, and error handling. Keep tests fast and deterministic.

## Core Principles

1. **Test logic with `perform_now`** - Synchronous, fast
2. **Test queuing with `perform_later`** - Verify job gets enqueued
3. **Stub external services** - No real API calls
4. **Use time helpers** - Deterministic time-dependent tests
5. **Test the test adapter** - Configure `queue_adapter = :test`

## Structure Pattern

```ruby
RSpec.describe ProcessOrderJob, type: :job do
  describe "#perform" do
    it "processes the order" do
      order = orders(:pending)

      ProcessOrderJob.perform_now(order)

      expect(order.reload.status).to eq("processed")
      expect(order.processed_at).to be_present
    end

    it "sends confirmation email" do
      order = orders(:pending)

      expect {
        ProcessOrderJob.perform_now(order)
      }.to have_enqueued_mail(OrderMailer, :confirmation)
    end
  end

  describe "queuing" do
    it "enqueues on correct queue" do
      expect {
        ProcessOrderJob.perform_later(orders(:pending))
      }.to have_enqueued_job.on_queue("orders")
    end
  end
end
```

## Job Execution Testing

### Basic Execution
```ruby
it "processes the order" do
  order = orders(:pending)
  ProcessOrderJob.perform_now(order)
  expect(order.reload.status).to eq("processed")
end
```

### With Side Effects
```ruby
it "updates inventory" do
  order = orders(:pending)

  expect {
    ProcessOrderJob.perform_now(order)
  }.to change { order.items.sum(&:inventory_count) }.by(-order.total_items)
end
```

### Triggering Other Jobs
```ruby
it "enqueues follow-up jobs" do
  order = orders(:pending)

  expect {
    ProcessOrderJob.perform_now(order)
  }.to have_enqueued_job(SendReceiptJob).with(order)
    .and have_enqueued_job(UpdateAnalyticsJob).with(order)
end
```

## Queue & Scheduling Matchers

### Basic Queuing
```ruby
expect {
  ImportJob.perform_later(file)
}.to have_enqueued_job(ImportJob)
  .with(file)
  .on_queue("imports")
  .exactly(:once)
```

### Scheduled Jobs
```ruby
it "schedules for specific time" do
  expect {
    ReportJob.set(wait_until: Date.tomorrow.noon).perform_later
  }.to have_enqueued_job.at(Date.tomorrow.noon)
end

it "schedules with delay" do
  expect {
    ReminderJob.set(wait: 1.hour).perform_later(user)
  }.to have_enqueued_job.at(1.hour.from_now)
end
```

### Priority
```ruby
it "sets priority" do
  expect {
    UrgentJob.set(priority: 1).perform_later
  }.to have_enqueued_job.with(priority: 1)
end
```

### Already Enqueued
```ruby
ImportJob.perform_later(file)
expect(ImportJob).to have_been_enqueued.with(file)
```

## Time-Dependent Testing

```ruby
RSpec.describe DailyReportJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  it "generates report for previous day" do
    travel_to Time.zone.local(2024, 1, 15, 10, 0, 0) do
      expect(Report).to receive(:generate).with(
        start_date: Date.new(2024, 1, 14),
        end_date: Date.new(2024, 1, 14)
      )

      DailyReportJob.perform_now
    end
  end

  it "schedules next run" do
    freeze_time do
      expect {
        DailyReportJob.perform_now
      }.to have_enqueued_job(DailyReportJob)
        .at(Date.tomorrow.beginning_of_day)
    end
  end
end
```

## Coordinator Job Pattern

Jobs that spawn other jobs:

```ruby
RSpec.describe WeeklyDigestJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  it "sends digest to all active users" do
    mail_delivery = instance_double(ActionMailer::MessageDelivery)
    allow(DigestMailer).to receive(:weekly).and_return(mail_delivery)
    allow(mail_delivery).to receive(:deliver_later)

    freeze_time do
      WeeklyDigestJob.perform_now

      [users(:alice), users(:bob)].each do |user|
        expect(DigestMailer).to have_received(:weekly)
          .with(user: user, since: 1.week.ago)
      end

      expect(DigestMailer).not_to have_received(:weekly)
        .with(user: users(:inactive), since: anything)
    end
  end
end
```

## Error Handling & Retries

### Testing Retry Logic
```ruby
it "retries on transient failure" do
  allow(ExternalAPI).to receive(:call)
    .and_raise(Net::ReadTimeout)

  expect {
    perform_enqueued_jobs { RetryableJob.perform_later }
  }.to raise_error(Net::ReadTimeout)

  expect(ExternalAPI).to have_received(:call).exactly(3).times
end
```

### Testing Recovery
```ruby
it "succeeds after retry" do
  call_count = 0
  allow(ExternalAPI).to receive(:call) do
    call_count += 1
    raise Net::ReadTimeout if call_count < 3
    { status: "success" }
  end

  perform_enqueued_jobs do
    RetryableJob.perform_later
  end

  expect(call_count).to eq(3)
end
```

### Testing Discard
```ruby
# Given: discard_on ActiveRecord::RecordNotFound
it "discards when record not found" do
  expect {
    ProcessPaymentJob.perform_now(999)  # Non-existent ID
  }.not_to raise_error
end
```

## Batch Processing Pattern

```ruby
RSpec.describe BatchImportJob, type: :job do
  let(:csv_file) { fixture_file_upload("data.csv") }

  it "enqueues job for each record" do
    expect {
      BatchImportJob.perform_now(csv_file)
    }.to have_enqueued_job(ImportRecordJob).exactly(10).times
  end

  it "tracks failures" do
    allow(ImportRecordJob).to receive(:perform_later)
      .and_raise(StandardError)

    expect {
      BatchImportJob.perform_now(csv_file)
    }.to change(FailedImport, :count).by(10)
  end
end
```

## Chain of Jobs Pattern

```ruby
it "triggers full fulfillment chain" do
  order = orders(:pending)

  expect {
    OrderFulfillmentJob.perform_now(order)
  }.to have_enqueued_job(ChargePaymentJob).with(order)
    .and have_enqueued_job(UpdateInventoryJob).with(order)
    .and have_enqueued_job(SendShippingJob).with(order)
end
```

## Test Configuration

```ruby
# config/environments/test.rb
config.active_job.queue_adapter = :test

# Or in specific specs
RSpec.describe MyJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :test }

  after do
    ActiveJob::Base.queue_adapter.performed_jobs.clear
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end
end
```

## Anti-Patterns to Avoid

- Testing job implementation only through integration tests
- Not clearing job queues between tests
- Using real external services
- Testing Rails' job infrastructure vs your logic
- Missing error and retry scenarios
- Not testing job argument serialization

## Quality Checklist

- [ ] Job logic tested with `perform_now`?
- [ ] Queuing tested with job matchers?
- [ ] Queue and priority verified?
- [ ] Error handling and retries covered?
- [ ] Time-dependent logic uses time helpers?
- [ ] External services stubbed?
- [ ] Chain reactions verified?
- [ ] Test adapter configured?
