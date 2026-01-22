# Request Specs Pattern

Location: `spec/requests/<resource_name>_spec.rb`

## Purpose

Test controllers at the HTTP level: routing, authentication, authorization, parameter handling, status codes, and redirects. Keep controllers thin - test business logic in model specs.

## Core Principles

1. **Use `type: :request`** - Preferred over controller specs
2. **Group by HTTP action** - `describe "GET /index"`, `describe "POST /create"`
3. **Context by auth state** - `context "as a guest"`, `context "as the owner"`
4. **Max 3 nesting levels** - Keep structure readable
5. **Test HTTP concerns** - Not business logic

## Structure Pattern

```ruby
RSpec.describe "Recipes", type: :request do
  describe "GET /recipes" do
    context "as authenticated user" do
      it "returns success" do
        get recipes_path(as: users(:alice))
        expect(response).to have_http_status(:ok)
      end
    end

    context "as guest" do
      it "redirects to login" do
        get recipes_path
        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

  describe "POST /recipes" do
    context "with valid params" do
      it "creates recipe and redirects" do
        user = users(:alice)

        expect {
          post recipes_path(as: user), params: { recipe: { name: "Pie" } }
        }.to change(user.recipes, :count).by(1)

        expect(response).to redirect_to(recipe_path(Recipe.last))
      end
    end

    context "with invalid params" do
      it "renders new template" do
        post recipes_path(as: users(:alice)), params: { recipe: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
```

## Authentication Patterns

### Clearance BackDoor
```ruby
get recipes_path(as: users(:alice))
post recipes_path(as: users(:alice)), params: { recipe: attributes }
delete recipe_path(recipe, as: users(:alice))
```

### Devise
```ruby
before { sign_in users(:alice) }

it "returns success" do
  get recipes_path
  expect(response).to have_http_status(:ok)
end
```

### Custom Token Auth
```ruby
it "authenticates with token" do
  get api_recipes_path, headers: { "Authorization" => "Bearer #{token}" }
  expect(response).to have_http_status(:ok)
end
```

## HTTP Matchers

### Status Codes
```ruby
expect(response).to have_http_status(200)        # numeric
expect(response).to have_http_status(:ok)        # symbolic
expect(response).to have_http_status(:success)   # generic (:success, :redirect, :error)
expect(response).to have_http_status(:not_found)
expect(response).to have_http_status(:forbidden)
expect(response).to have_http_status(:unprocessable_entity)
```

### Redirects
```ruby
expect(response).to redirect_to(recipe_url(recipe))
expect(response).to redirect_to(action: :show, id: recipe.id)
expect(response).to redirect_to(recipe)  # object
expect(response).to redirect_to("/recipes/#{recipe.id}")
expect(response).to redirect_to(sign_in_path)
```

### Template Rendering (use sparingly)
```ruby
expect(response).to render_template(:new)  # Useful for failed creates
```

## Data Verification Patterns

### Create Actions
```ruby
it "creates record" do
  expect {
    post recipes_path(as: user), params: { recipe: valid_attrs }
  }.to change(Recipe, :count).by(1)
end

it "associates with current user" do
  post recipes_path(as: user), params: { recipe: valid_attrs }
  expect(Recipe.last.user).to eq(user)
end
```

### Update Actions
```ruby
it "updates the record" do
  recipe = recipes(:draft)

  patch recipe_path(recipe, as: recipe.user),
        params: { recipe: { name: "New Name" } }

  expect(recipe.reload.name).to eq("New Name")
end
```

### Delete Actions
```ruby
it "destroys the record" do
  recipe = recipes(:draft)

  expect {
    delete recipe_path(recipe, as: recipe.user)
  }.to change(Recipe, :count).by(-1)
end

it "redirects after deletion" do
  recipe = recipes(:draft)
  delete recipe_path(recipe, as: recipe.user)
  expect(response).to redirect_to(recipes_path)
end
```

## Authorization Patterns

### Owner-only Access
```ruby
describe "PATCH /recipes/:id" do
  let(:recipe) { recipes(:alice_recipe) }

  context "as owner" do
    it "updates successfully" do
      patch recipe_path(recipe, as: users(:alice)),
            params: { recipe: { name: "Updated" } }
      expect(response).to redirect_to(recipe)
    end
  end

  context "as non-owner" do
    it "returns not found" do
      patch recipe_path(recipe, as: users(:bob)),
            params: { recipe: { name: "Hacked" } }
      expect(response).to have_http_status(:not_found)
    end
  end

  context "as guest" do
    it "redirects to login" do
      patch recipe_path(recipe), params: { recipe: { name: "Hacked" } }
      expect(response).to redirect_to(sign_in_path)
    end
  end
end
```

### Admin-only Access
```ruby
describe "GET /admin/users" do
  context "as admin" do
    it "returns success" do
      get admin_users_path(as: users(:admin))
      expect(response).to have_http_status(:ok)
    end
  end

  context "as regular user" do
    it "returns forbidden" do
      get admin_users_path(as: users(:alice))
      expect(response).to have_http_status(:forbidden)
    end
  end
end
```

## API Response Patterns

```ruby
describe "GET /api/recipes" do
  it "returns JSON" do
    get api_recipes_path(as: users(:alice))

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include("application/json")
  end

  it "includes recipe data" do
    get api_recipes_path(as: users(:alice))

    json = JSON.parse(response.body)
    expect(json["recipes"]).to be_an(Array)
    expect(json["recipes"].first).to include("name", "id")
  end
end

describe "POST /api/recipes" do
  context "with invalid params" do
    it "returns errors" do
      post api_recipes_path(as: users(:alice)),
           params: { recipe: { name: "" } }

      json = JSON.parse(response.body)
      expect(json["errors"]).to include("name")
    end
  end
end
```

## Anti-Patterns to Avoid

- Testing business logic in controller specs (belongs in models/services)
- Deep nesting and sprawling top-level setup
- Using `before(:all)` with ActiveRecord data
- Global helpers that hide state and increase cognitive load
- Not verifying persistence with `reload` or `change`

## Quality Checklist

- [ ] Using `type: :request`?
- [ ] Clear action grouping with state-based contexts?
- [ ] Authentication handled in appropriate scope?
- [ ] Proper status/redirect assertions for each state?
- [ ] Persistence verified with `reload` or `change`?
- [ ] No unnecessary data or excessive nesting?
- [ ] Examples named with outcome-focused verbs?
- [ ] Max 3 nesting levels?
