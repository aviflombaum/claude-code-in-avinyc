# System Specs Pattern

Location: `spec/system/<feature_name>_spec.rb`

## Purpose

Test complete user flows through the browser. Verify real user journeys with Capybara, choosing the fastest reliable driver.

## Core Principles

1. **Fast by default** - Use `rack_test` unless JS required
2. **Happy-path focus** - Push validation logic to model/request specs
3. **Progressive assertions** - Verify at key checkpoints, not just the end
4. **Stable selectors** - IDs/classes/labels over brittle text
5. **No flakiness** - Use Capybara's built-in waiting, never `sleep`

## Driver Selection

| Driver | Use When | Speed |
|--------|----------|-------|
| `rack_test` | HTML-only, no JS | Fast |
| `cuprite` | JavaScript interactions, dynamic UI | Slower |

```ruby
RSpec.describe "User Registration", type: :system do
  context "HTML form" do
    before { driven_by(:rack_test) }
    # Fast tests
  end

  context "JavaScript interactions" do
    before { driven_by(:cuprite) }
    # Tests requiring JS
  end
end
```

## Structure Pattern

```ruby
RSpec.describe "Recipe Management", type: :system do
  before { driven_by(:rack_test) }

  it "creates a new recipe" do
    visit new_session_path
    fill_in "Email", with: users(:alice).email
    fill_in "Password", with: "password"
    click_button "Sign In"

    expect(page).to have_content("Signed in")  # Checkpoint

    visit new_recipe_path
    fill_in "Name", with: "Apple Pie"
    fill_in "Description", with: "Delicious dessert"
    click_button "Create Recipe"

    expect(page).to have_content("Recipe was successfully created")
    expect(page).to have_content("Apple Pie")
  end
end
```

## Capybara DSL Reference

### Navigation
```ruby
visit root_path
visit recipe_path(recipe)
```

### Clicking
```ruby
click_link "Edit"
click_button "Submit"
click_on "Save"  # Works for links or buttons
```

### Forms
```ruby
fill_in "Email", with: "test@example.com"
fill_in "recipe[name]", with: "Pie"  # By name attribute
check "Remember me"
uncheck "Subscribe"
choose "Priority", option: "High"  # Radio button
select "Category", from: "recipe_category_id"
select "Dessert", from: "Category"
attach_file "Photo", Rails.root.join("spec/fixtures/photo.jpg")
```

### Assertions
```ruby
expect(page).to have_content("Success")
expect(page).to have_css(".alert-success")
expect(page).to have_selector("h1", text: "Recipes")
expect(page).to have_current_path(recipes_path)
expect(page).to have_link("Edit")
expect(page).to have_button("Submit")
expect(page).to have_field("Email", with: "test@example.com")
expect(page).to have_checked_field("Remember me")
expect(page).to have_select("Category", selected: "Dessert")
```

### Scoping
```ruby
within(".sidebar") do
  click_link "Settings"
end

within("#recipe-form") do
  fill_in "Name", with: "Pie"
  click_button "Save"
end

within_table("recipes") do
  expect(page).to have_content("Apple Pie")
end
```

### Finding Elements
```ruby
find("#submit-button").click
find(".recipe-card", text: "Apple Pie").click
first(".item").click
all(".item").each { |item| item.click }
```

## JavaScript Testing with Cuprite

```ruby
RSpec.describe "Dynamic Form", type: :system do
  before { driven_by(:cuprite) }

  it "shows validation errors without page reload" do
    visit new_recipe_path(as: users(:alice))
    click_button "Save"

    expect(page).to have_css(".error", text: "Name can't be blank")
  end

  it "auto-saves draft" do
    visit new_recipe_path(as: users(:alice))
    fill_in "Name", with: "Draft Recipe"

    # Wait for auto-save
    expect(page).to have_css(".saved-indicator", text: "Saved")
  end

  it "handles modal interactions" do
    visit recipes_path(as: users(:alice))
    click_button "Delete"

    within(".modal") do
      click_button "Confirm"
    end

    expect(page).not_to have_content("Apple Pie")
  end
end
```

### Cuprite Advanced Features

```ruby
# Wait for network idle (useful for AJAX)
page.driver.wait_for_network_idle

# Debugging (pauses test, opens inspector)
page.driver.debug

# Screenshots
page.driver.save_screenshot("tmp/screenshot.png", full: true)

# Clear state
page.driver.clear_cookies
page.driver.clear_memory_cache

# Network control
page.driver.headers = { "Authorization" => "Bearer token" }
page.driver.url_blocklist = ["analytics.com", "ads.com"]
```

## Authentication in System Specs

### Via UI (Recommended)
```ruby
def sign_in_as(user)
  visit new_session_path
  fill_in "Email", with: user.email
  fill_in "Password", with: "password"
  click_button "Sign In"
end

it "shows dashboard after login" do
  sign_in_as(users(:alice))
  expect(page).to have_current_path(dashboard_path)
end
```

### Via Backdoor (Faster)
```ruby
it "shows recipes" do
  visit recipes_path(as: users(:alice))
  expect(page).to have_content("My Recipes")
end
```

## Multi-Step Workflow Pattern

```ruby
it "completes checkout flow" do
  user = users(:alice)

  # Step 1: Add to cart
  visit product_path(products(:widget))
  click_button "Add to Cart"
  expect(page).to have_content("Added to cart")

  # Step 2: View cart
  click_link "Cart"
  expect(page).to have_content("Widget")
  expect(page).to have_content("$19.99")

  # Step 3: Checkout
  click_button "Checkout"
  fill_in "Card number", with: "4242424242424242"
  fill_in "Expiry", with: "12/25"
  click_button "Pay"

  # Step 4: Confirmation
  expect(page).to have_content("Order confirmed")
  expect(page).to have_content("Order #")
end
```

## File Upload Pattern

```ruby
it "uploads a recipe photo" do
  visit new_recipe_path(as: users(:alice))

  fill_in "Name", with: "Apple Pie"
  attach_file "Photo", Rails.root.join("spec/fixtures/recipe.jpg")
  click_button "Create"

  expect(page).to have_css("img.recipe-photo")
end

# Multiple files
attach_file "Photos", [
  Rails.root.join("spec/fixtures/photo1.jpg"),
  Rails.root.join("spec/fixtures/photo2.jpg")
]
```

## Anti-Patterns to Avoid

- Using system specs for everything (slow)
- Testing validation logic (belongs in model specs)
- Testing parameter filtering (belongs in request specs)
- Using `sleep` instead of Capybara's built-in waiting
- Brittle text matching over stable selectors
- Committing debug artifacts (save_page, screenshots)

## Quality Checklist

- [ ] Using fastest appropriate driver?
- [ ] Testing complete user flow, not implementation details?
- [ ] Progressive assertions at checkpoints?
- [ ] Stable selectors (IDs, classes, labels)?
- [ ] No `sleep` calls?
- [ ] Authentication handled appropriately?
- [ ] Happy path focus with edge cases in lower-level specs?
