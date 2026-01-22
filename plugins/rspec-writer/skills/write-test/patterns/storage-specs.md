# ActiveStorage Specs Pattern

Location: `spec/models/<model_name>_spec.rb` (attachment logic) and `spec/system/<feature>_spec.rb` (upload UI)

## Purpose

Test file uploads, attachments, and storage operations. Cover both UI flows and model-level logic.

## Core Principles

1. **Test at multiple levels** - Both UI (system) and logic (model)
2. **Use appropriate drivers** - `rack_test` for non-JS, `cuprite` for JS
3. **Clean storage between runs** - Prevent test pollution
4. **Use small fixture files** - Representative, not production-sized
5. **Test fallbacks** - Default behavior when no attachment

## Model Spec Pattern

```ruby
RSpec.describe Recipe, type: :model do
  describe "#photo" do
    context "with attached photo" do
      it "returns the attachment" do
        recipe = recipes(:draft)
        file = fixture_file_upload("spec/fixtures/recipe.jpg", "image/jpeg")
        recipe.photo.attach(file)

        expect(recipe.photo).to be_attached
      end
    end

    context "without photo" do
      it "returns placeholder" do
        recipe = Recipe.new
        expect(recipe.photo).not_to be_attached
        expect(recipe.photo_url).to eq("recipe-placeholder.png")
      end
    end
  end
end
```

## System Spec Pattern

```ruby
RSpec.describe "Recipe Photos", type: :system do
  before { driven_by(:rack_test) }

  it "uploads a photo" do
    visit new_recipe_path(as: users(:alice))

    fill_in "Name", with: "Apple Pie"
    attach_file "Photo", Rails.root.join("spec/fixtures/recipe.jpg")
    click_button "Create Recipe"

    expect(page).to have_content("Recipe was successfully created")
    expect(page).to have_css("img.recipe-photo")
  end
end
```

## File Upload Methods

### fixture_file_upload
```ruby
# In model/request specs
file = fixture_file_upload("spec/fixtures/recipe.jpg", "image/jpeg")
recipe.photo.attach(file)

# Windows compatibility (binary mode)
file = fixture_file_upload(
  Rails.root.join("spec/fixtures/recipe.jpg"),
  "image/jpeg",
  :binary
)
```

### attach_file (Capybara)
```ruby
# Single file
attach_file "Photo", Rails.root.join("spec/fixtures/recipe.jpg")

# Multiple files
attach_file "Photos", [
  Rails.root.join("spec/fixtures/photo1.jpg"),
  Rails.root.join("spec/fixtures/photo2.jpg")
]
```

## Validation Testing

### File Size Validation
```ruby
it "validates file size" do
  large_file = fixture_file_upload("spec/fixtures/large.jpg", "image/jpeg")
  recipe = recipes(:draft)
  recipe.photo.attach(large_file)

  expect(recipe).not_to be_valid
  expect(recipe.errors[:photo]).to include("is too large")
end
```

### Content Type Validation
```ruby
it "validates content type" do
  pdf = fixture_file_upload("spec/fixtures/document.pdf", "application/pdf")
  recipe = recipes(:draft)
  recipe.photo.attach(pdf)

  expect(recipe).not_to be_valid
  expect(recipe.errors[:photo]).to include("must be an image")
end
```

### Accepted Types
```ruby
it "accepts valid image types" do
  %w[jpg png gif webp].each do |ext|
    file = fixture_file_upload("spec/fixtures/image.#{ext}", "image/#{ext}")
    recipe = Recipe.new(name: "Test")
    recipe.photo.attach(file)

    expect(recipe).to be_valid, "Expected .#{ext} to be valid"
  end
end
```

## Image Variants Testing

```ruby
describe "variants" do
  it "generates thumbnail" do
    recipe = recipes(:with_photo)
    thumbnail = recipe.photo.variant(resize_to_limit: [100, 100])

    expect(thumbnail).to be_processed
  end

  it "generates preview for video" do
    recipe = recipes(:with_video)
    preview = recipe.video.preview(resize_to_limit: [300, 300])

    expect(preview.image).to be_attached
  end
end
```

## Direct Upload Testing

```ruby
describe "direct uploads" do
  it "creates blob for direct upload" do
    blob = ActiveStorage::Blob.create_before_direct_upload!(
      filename: "test.jpg",
      byte_size: 1024,
      checksum: "abc123",
      content_type: "image/jpeg"
    )

    expect(blob.service_url_for_direct_upload).to be_present
  end
end
```

## Purging Attachments

```ruby
describe "#purge" do
  it "removes attachment and blob" do
    recipe = recipes(:with_photo)

    expect {
      recipe.photo.purge
    }.to change { ActiveStorage::Blob.count }.by(-1)

    expect(recipe.photo).not_to be_attached
  end
end
```

## Multiple Attachments

```ruby
RSpec.describe Gallery, type: :model do
  describe "#images" do
    it "supports multiple attachments" do
      gallery = galleries(:empty)

      3.times do |i|
        file = fixture_file_upload("spec/fixtures/image#{i}.jpg", "image/jpeg")
        gallery.images.attach(file)
      end

      expect(gallery.images.count).to eq(3)
    end

    it "orders by attachment date" do
      gallery = galleries(:with_images)
      expect(gallery.images.first.created_at).to be <= gallery.images.last.created_at
    end
  end
end
```

## Storage Cleanup Configuration

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.before(:suite) do
    # Clean storage directory
    storage_dir = ActiveStorage::Blob.services.fetch(:test).root
    FileUtils.rm_rf(storage_dir)
    FileUtils.mkdir_p(storage_dir)
    FileUtils.touch(File.join(storage_dir, ".keep"))
  end

  config.after(:each) do
    ActiveStorage::Current.reset
  end
end
```

## Test Service Configuration

```yaml
# config/storage.yml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_test") %>
```

```ruby
# config/environments/test.rb
config.active_storage.service = :test
```

## Fixture Organization

```
spec/fixtures/
├── files/
│   ├── recipe.jpg          # Standard test image (small)
│   ├── large.jpg           # For size validation tests
│   ├── document.pdf        # For content type tests
│   └── image.png
└── .keep
```

## Anti-Patterns to Avoid

- Testing file uploads only through system specs (slow)
- Not cleaning storage between test runs
- Using production-sized files in tests
- Forgetting Windows binary mode compatibility
- Missing fallback/default behavior tests
- Not testing file validation rules
- Hardcoding paths instead of using Rails.root

## Quality Checklist

- [ ] Storage cleaned before test suite?
- [ ] Both system and model specs for uploads?
- [ ] Fallback behavior tested?
- [ ] File validations covered (size, type)?
- [ ] Windows compatibility handled?
- [ ] Fixtures organized in spec/fixtures/?
- [ ] Using fast drivers where possible?
- [ ] Variants/previews tested if used?
- [ ] Direct upload tested if used?
