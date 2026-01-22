# Fixtures Pattern

Location: `spec/fixtures/*.yml`

## Purpose

Manage test data with Rails fixtures. Create predictable, reusable data that loads once and supports all specs.

## Core Principles

1. **Fixtures over factories** - Use `users(:admin)`, not `create(:user)`
2. **Boring defaults** - Valid with minimal attributes
3. **Minimal set** - Small, well-documented fixtures
4. **Clear naming** - Purpose obvious from name
5. **Explicit relationships** - Use fixture labels for associations

## Basic Structure

```yaml
# spec/fixtures/users.yml
alice:
  email: alice@example.com
  name: Alice Smith
  role: user

bob:
  email: bob@example.com
  name: Bob Jones
  role: user

admin:
  email: admin@example.com
  name: Admin User
  role: admin

inactive:
  email: inactive@example.com
  name: Inactive User
  role: user
  active: false
```

## Accessing Fixtures

```ruby
# In specs
users(:alice)
users(:admin)
recipes(:published)

# Multiple fixtures
let(:active_users) { [users(:alice), users(:bob)] }
```

## Association References

```yaml
# spec/fixtures/recipes.yml
published:
  name: Apple Pie
  user: alice           # References users(:alice)
  status: published

draft:
  name: Work in Progress
  user: alice
  status: draft

bob_recipe:
  name: Chocolate Cake
  user: bob
  status: published
```

```yaml
# spec/fixtures/comments.yml
first_comment:
  body: Great recipe!
  user: bob
  recipe: published     # References recipes(:published)

second_comment:
  body: Thanks!
  user: alice
  recipe: published
```

## Naming Conventions

### By State
```yaml
# Good - describes the state
published:
  status: published

draft:
  status: draft

archived:
  status: archived
  archived_at: <%= 1.week.ago %>
```

### By Role/Purpose
```yaml
# Good - describes the purpose
with_notifications:
  email_notifications: true

without_notifications:
  email_notifications: false

premium:
  plan: premium

free:
  plan: free
```

### Generic Names (Simple Cases)
```yaml
# OK for simple cases
one:
  name: First Item

two:
  name: Second Item
```

## Self-Referential Associations

Use ordered map (`omap`) for self-references:

```yaml
# spec/fixtures/categories.yml
--- !omap
- root:
    name: Root Category
    parent: null

- child:
    name: Child Category
    parent: root        # Must come after root

- grandchild:
    name: Grandchild
    parent: child       # Must come after child
```

## Polymorphic Associations

```yaml
# spec/fixtures/comments.yml
on_recipe:
  body: Great recipe!
  commentable_type: Recipe
  commentable_id: <%= ActiveRecord::FixtureSet.identify(:published) %>
  user: alice

on_article:
  body: Interesting read
  commentable_type: Article
  commentable_id: <%= ActiveRecord::FixtureSet.identify(:featured) %>
  user: bob
```

## ERB in Fixtures (Use Sparingly)

```yaml
# spec/fixtures/users.yml
recent:
  email: recent@example.com
  created_at: <%= 1.day.ago %>

old:
  email: old@example.com
  created_at: <%= 1.year.ago %>

# Dynamic IDs for polymorphic
comment:
  commentable_id: <%= ActiveRecord::FixtureSet.identify(:published) %>
```

**Note**: Excessive ERB is a code smell. Prefer static values.

## YAML Aliases (DRY)

```yaml
defaults: &defaults
  role: user
  active: true
  email_notifications: true

alice:
  <<: *defaults
  email: alice@example.com
  name: Alice

bob:
  <<: *defaults
  email: bob@example.com
  name: Bob

# Override defaults
admin:
  <<: *defaults
  email: admin@example.com
  name: Admin
  role: admin
```

## Loading Fixtures

### All Fixtures (Recommended)
```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join("spec/fixtures")]
  config.use_transactional_fixtures = true
  config.global_fixtures = :all
end
```

### Selective Loading
```ruby
RSpec.describe User, type: :model do
  fixtures :users, :organizations

  it "belongs to organization" do
    expect(users(:alice).organization).to eq(organizations(:acme))
  end
end
```

## File Organization

```
spec/fixtures/
├── users.yml
├── organizations.yml
├── recipes.yml
├── comments.yml
├── tags.yml
├── files/                    # For ActiveStorage
│   ├── recipe.jpg
│   └── document.pdf
└── action_text/              # For ActionText
    └── rich_texts.yml
```

## ActionText Fixtures

```yaml
# spec/fixtures/action_text/rich_texts.yml
recipe_description:
  record_type: Recipe
  record_id: <%= ActiveRecord::FixtureSet.identify(:published) %>
  name: description
  body: <div>Delicious apple pie recipe</div>
```

## Fixture Helpers

```ruby
# spec/support/fixture_helpers.rb
module FixtureHelpers
  def fixture_file(name)
    Rails.root.join("spec/fixtures/files", name)
  end

  def attach_fixture(record, attachment, filename)
    file = fixture_file_upload(fixture_file(filename))
    record.send(attachment).attach(file)
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers
end
```

## When to Create New Records

Fixtures are pre-loaded. Create records dynamically only when:

1. **Testing uniqueness** - Need conflicting records
2. **Testing creation** - Verifying `create` action
3. **Dynamic state** - State depends on test conditions

```ruby
# Uniqueness - need to create second record
it "requires unique email" do
  existing = users(:alice)
  new_user = User.new(email: existing.email)
  expect(new_user).to be_invalid
end

# Creation - testing the create action
it "creates user" do
  expect {
    post users_path, params: { user: { email: "new@example.com" } }
  }.to change(User, :count).by(1)
end
```

## Anti-Patterns to Avoid

- Fixture proliferation (too many fixtures)
- Excessive ERB making fixtures hard to read
- Not documenting special-case fixtures
- Circular dependencies in self-references
- Using factories when fixtures suffice
- Duplicating data instead of using references

## Quality Checklist

- [ ] Fixtures minimal and well-named?
- [ ] Defaults boring and valid?
- [ ] Associations use fixture labels?
- [ ] Self-references use omap?
- [ ] ERB used sparingly?
- [ ] Special cases documented?
- [ ] File fixtures organized?
- [ ] Fixtures load without errors?
