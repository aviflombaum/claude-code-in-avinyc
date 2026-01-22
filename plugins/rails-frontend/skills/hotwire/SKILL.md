---
name: hotwire
description: Hotwire, Turbo, and Stimulus patterns for Rails. Use when implementing JavaScript interactions, Turbo Frames/Streams, or Stimulus controllers. Triggers on "stimulus controller", "turbo frame", "turbo stream", "hotwire", "rails javascript".
argument-hint: "[controller|frame|stream] description"
user-invocable: true
---

# Hotwire, Turbo & Stimulus for Rails

Expert patterns for JavaScript and Hotwire integration with Ruby on Rails.

## Core Principles

1. Use latest versions based on Gemfile
2. Follow Rails conventions and best practices
3. Use Context7 MCP or hotwire.dev for documentation
4. Test JavaScript with RSpec system specs (Capybara + Cuprite)
5. Review existing Stimulus controllers before creating new ones

## Stimulus Controllers

### Guidelines
- Keep controllers simple and focused
- Make controllers generic when possible, specific only when needed
- **Never** have controllers communicate with each other
- Integrate into ERB templates using Rails conventions

### Structure
```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  static values = { open: Boolean }

  toggle() {
    this.openValue = !this.openValue
  }

  openValueChanged() {
    this.contentTarget.classList.toggle("hidden", !this.openValue)
  }
}
```

### ERB Integration
```erb
<div data-controller="toggle" data-toggle-open-value="false">
  <button data-action="toggle#toggle">Toggle</button>
  <div data-toggle-target="content" class="hidden">
    Content here
  </div>
</div>
```

## Turbo Frames

Use for partial page updates without full refreshes.

```erb
<%= turbo_frame_tag "user_profile" do %>
  <%= render @user %>
<% end %>

<!-- Link that updates only the frame -->
<%= link_to "Edit", edit_user_path(@user), data: { turbo_frame: "user_profile" } %>
```

## Turbo Streams

Use for real-time updates from server.

```ruby
# Controller
respond_to do |format|
  format.turbo_stream
  format.html { redirect_to @post }
end
```

```erb
<%# app/views/posts/create.turbo_stream.erb %>
<%= turbo_stream.prepend "posts", @post %>
<%= turbo_stream.update "post_count", Post.count %>
```

## AJAX Requests

Use `request.js` for AJAX when needed:

```javascript
import { get, post } from "@rails/request.js"

async function loadData() {
  const response = await get("/api/data", { responseKind: "json" })
  if (response.ok) {
    const data = await response.json
    // handle data
  }
}
```

## Import Maps

Include JavaScript libraries via import maps. Only add libraries when absolutely necessary.

```ruby
# config/importmap.rb
pin "lodash", to: "https://ga.jspm.io/npm:lodash@4.17.21/lodash.js"
```

If import maps aren't used, follow whatever asset pipeline the application uses.

## Testing

Test Hotwire features with RSpec system specs:

```ruby
RSpec.describe "Posts", type: :system do
  before { driven_by(:cuprite) }

  it "updates post inline with Turbo" do
    post = posts(:published)
    visit post_path(post)

    click_link "Edit"
    fill_in "Title", with: "Updated Title"
    click_button "Save"

    expect(page).to have_content("Updated Title")
    expect(page).to have_current_path(post_path(post)) # No redirect
  end
end
```
