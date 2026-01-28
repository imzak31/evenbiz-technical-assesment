# EvenBiz Music Platform - Technical Deep Dive

This document provides a comprehensive overview of the architecture, patterns, and rationale behind the EvenBiz Music Platform. Use this for interview preparation and to defend technical decisions.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Hotwire Stack: Turbo + Stimulus](#hotwire-stack-turbo--stimulus)
3. [Service Layer Pattern](#service-layer-pattern)
4. [API Design & Authentication](#api-design--authentication)
5. [N+1 Query Prevention](#n1-query-prevention)
6. [Value Objects & Type Safety](#value-objects--type-safety)
7. [Blueprinter Serialization](#blueprinter-serialization)
8. [Search Implementation](#search-implementation)
9. [Testing Strategy](#testing-strategy)
10. [Security Considerations](#security-considerations)
11. [Key Interview Talking Points](#key-interview-talking-points)

---

## Architecture Overview

### The Big Picture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Layer                              │
├─────────────────────────────────────────────────────────────────┤
│  Browser (Turbo + Stimulus)    │    API Clients (Bearer Token)  │
└─────────────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────────┐
│                      Controller Layer                            │
├─────────────────────────────────────────────────────────────────┤
│  ApplicationController          │    Api::BaseController         │
│  (Session Auth, CSRF)           │    (Token Auth, No CSRF)       │
│  ├── AlbumsController           │    └── Api::ReleasesController │
│  ├── ArtistsController          │                                │
│  ├── ReleasesController         │                                │
│  └── DashboardController        │                                │
└─────────────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────────┐
│                       Service Layer                              │
├─────────────────────────────────────────────────────────────────┤
│  BaseService                                                     │
│  ├── Releases::ListService (filtering, pagination, search)      │
│  └── Search::*Search (fuzzy search per entity)                  │
└─────────────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                                │
├─────────────────────────────────────────────────────────────────┤
│  Models (ActiveRecord)   │  Blueprints (Serializers)            │
│  ├── Artist              │  ├── ArtistBlueprint                 │
│  ├── Release             │  ├── ReleaseBlueprint                │
│  ├── Album               │  └── AlbumBlueprint                  │
│  ├── ArtistRelease       │                                      │
│  └── User                │  Responses (Value Objects)           │
│                          │  ├── ServiceResult                   │
│                          │  └── PaginationMeta                  │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Architecture?

1. **Separation of Concerns** - Each layer has a single responsibility
2. **Testability** - Services can be tested in isolation without HTTP
3. **Maintainability** - Changes in one layer don't cascade
4. **Scalability** - Can easily add new endpoints/features

---

## Hotwire Stack: Turbo + Stimulus

### What is Hotwire?

Hotwire is Rails' modern approach to building reactive web applications **without writing much JavaScript**. It consists of:

- **Turbo** - Makes navigation feel SPA-like
- **Stimulus** - Adds sprinkles of JavaScript for interactivity

### Turbo Drive

**What it does:** Intercepts all link clicks and form submissions, fetches the new page via AJAX, and swaps the `<body>` content.

**Why we use it:** Zero-configuration SPA-like navigation. The browser doesn't do a full reload, making the app feel instant.

```erb
<!-- This works automatically with Turbo Drive -->
<%= link_to "View Album", album_path(@album) %>
```

**The catch:** When redirecting after form submissions, use `status: :see_other` (303) to tell Turbo to follow the redirect with a GET request:

```ruby
# In controller
redirect_to @album, notice: "Created!", status: :see_other
```

### Turbo Frames

**What it does:** Allows updating only a portion of the page without a full reload.

**Example - Search Results:**

```erb
<!-- The search form targets this frame -->
<%= turbo_frame_tag "albums" do %>
  <% @albums.each do |album| %>
    <%= render album %>
  <% end %>
<% end %>
```

**When to break out of frames:**

```erb
<!-- This form submits and breaks out of any parent frame -->
<%= form_with model: @album, data: { turbo_frame: "_top" } do |f| %>
```

### Turbo Streams (Not heavily used here)

Would be used for real-time updates (WebSocket-based). We didn't need them for this assessment.

### Stimulus Controllers

**Philosophy:** Stimulus is a "modest" JavaScript framework. It enhances HTML rather than replacing it.

**Key Concepts:**

| Concept | Purpose | Example |
|---------|---------|---------|
| Controllers | Encapsulate behavior | `data-controller="search"` |
| Targets | Reference DOM elements | `data-search-target="input"` |
| Actions | Respond to events | `data-action="input->search#debounce"` |
| Values | Pass data from HTML | `data-search-delay-value="300"` |

### Our Stimulus Controllers

#### 1. `search_controller.js` - Debounced Live Search

```javascript
// Waits 300ms after typing stops, then auto-submits the form
debounce(event) {
  const query = event.target.value.trim()
  
  if (this.timeout) clearTimeout(this.timeout)

  if (query.length >= 3 || query.length === 0) {
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}
```

**Why debounce?** Prevents sending a request on every keystroke. Waits until user stops typing.

#### 2. `confirm_controller.js` - Custom Delete Confirmation

```javascript
// Replaces browser's ugly confirm() with a styled modal
show(event) {
  event.preventDefault()
  this.pendingForm = event.currentTarget.closest("form")
  this.dialogTarget.classList.remove("hidden")
}

confirm() {
  this.pendingForm.requestSubmit()  // Submit the delete form
  this.close()
}
```

**Why custom?** Browser's `confirm()` is ugly and can't be styled. This provides a consistent UX.

#### 3. `album_form_controller.js` - Dynamic Artist Filtering

```javascript
// When release changes, filter artists to only those on that release
async filterArtists() {
  const response = await fetch(`/releases/${releaseId}.json`)
  const release = await response.json()
  
  // Hide artists not associated with this release
  Array.from(select.options).forEach(option => {
    option.hidden = !artistIds.includes(parseInt(option.value))
  })
}
```

**Why?** Business rule: An album's artist must be one of the artists on its release.

#### 4. `dropdown_controller.js` - User Menu

Simple show/hide for the user dropdown in the navbar.

#### 5. `modal_controller.js` - Generic Modal

Reusable modal controller for any dialog-style UI.

#### 6. `flash_controller.js` - Auto-dismiss Notifications

```javascript
connect() {
  // Auto-dismiss after 5 seconds
  setTimeout(() => this.dismiss(), 5000)
}
```

---

## Service Layer Pattern

### Why Services?

Controllers should be thin. Services encapsulate business logic:

```ruby
# BAD - Fat controller
class ReleasesController < ApplicationController
  def index
    @releases = Release.includes(:album, :artists)
    @releases = @releases.where("released_at < ?", Time.current) if params[:past] == "1"
    @releases = @releases.page(params[:page]).per(params[:limit] || 10)
    # ... more logic
  end
end

# GOOD - Thin controller, fat service
class Api::ReleasesController < Api::BaseController
  def index
    result = Releases::ListService.call(params: sanitized_params)
    respond_with_result(result, serializer: ReleaseBlueprint)
  end
end
```

### BaseService Pattern

```ruby
class BaseService
  # Class method delegates to instance
  def self.call(...)
    new(...).call
  end

  private

  # All services return ServiceResult for consistency
  def success(data:, meta: nil)
    ServiceResult.success(data: data, meta: meta)
  end

  def failure(errors:)
    ServiceResult.failure(errors: errors)
  end

  # Reusable pagination helper
  def paginate(scope, page:, per_page:)
    paginated = scope.page(page).per(per_page)
    meta = PaginationMeta.new(...)
    [paginated, meta]
  end
end
```

### Releases::ListService

The core API logic lives here:

```ruby
def call
  releases = build_query
  paginated_releases, pagination_meta = paginate(releases, page: @page, per_page: @per_page)
  success(data: paginated_releases, meta: pagination_meta)
end

private

def build_query
  scope = Release.for_index    # Eager load associations
  scope = apply_past_filter(scope)  # past=1 or past=0
  scope = apply_search(scope)       # Fuzzy search
  scope
end
```

**Benefits:**
- Easy to test without HTTP
- Reusable (could be called from a background job)
- Single Responsibility

---

## API Design & Authentication

### Dual Authentication Strategy

| Type | Used By | Mechanism | CSRF? |
|------|---------|-----------|-------|
| Session | Web UI | Cookie + `session[:user_id]` | Yes |
| Token | API | `Authorization: Bearer <token>` | No |

### Token Authentication Concern

```ruby
module TokenAuthentication
  def authenticate_with_token
    token = extract_token_from_header
    return nil if token.blank?
    
    # Secure: database lookup with indexed column
    User.by_api_token(token).first
  end

  def extract_token_from_header
    header = request.headers["Authorization"]
    # Supports: "Bearer <token>" or just "<token>"
    header.start_with?("Bearer ") ? header.delete_prefix("Bearer ") : header
  end
end
```

### API Controller Inheritance

```ruby
module Api
  class BaseController < ActionController::API
    include TokenAuthentication  # No session, just token
    include ApiResponder         # Standardized responses
    include ParameterSanitizer   # Whitelist params
    
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
  end
end
```

**Why `ActionController::API`?** Lighter than full ApplicationController. No sessions, cookies, CSRF, flash messages.

### API Response Format

```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 100,
    "per_page": 10
  }
}
```

---

## N+1 Query Prevention

### The N+1 Problem

```ruby
# BAD - N+1 query (1 query for releases, N queries for artists)
Release.all.each do |release|
  release.artists.each { |a| puts a.name }  # Query per release!
end
```

### Our Solution: Query Planners (Scopes)

```ruby
class Release < ApplicationRecord
  scope :for_index, lambda {
    includes(
      album: { cover_attachment: :blob },
      artists: { logo_attachment: :blob }
    ).order(released_at: :desc, name: :asc)
  }
end
```

**In Controller:**

```ruby
def index
  result = Releases::ListService.call(params: sanitized_params)
  # ListService uses Release.for_index internally
end
```

### Result: Predictable Query Count

```
# With for_index scope (regardless of how many releases):
Release Load (1 query)
Artist Load via join (1 query)
ActiveStorage::Attachment Load (1 query)
ActiveStorage::Blob Load (1 query)
= 4 queries total
```

### Finding Releases Without Albums (Subquery Pattern)

```ruby
# BAD at scale - LEFT JOIN scans full tables
Release.left_joins(:album).where(albums: { id: nil })

# GOOD - Subquery lets database optimize
Release.where.not(id: Album.select(:release_id))
# Generates: WHERE id NOT IN (SELECT release_id FROM albums)
```

---

## Value Objects & Type Safety

### Why Dry::Struct?

Plain hashes are error-prone. Typos, wrong types, missing keys.

```ruby
# BAD - Hash
{ sucess: true, data: releases }  # Typo goes unnoticed

# GOOD - Typed struct
class ServiceResult < Dry::Struct
  attribute :success, Types::Bool
  attribute :data, Types::Any.optional
  attribute :errors, Types::Array.of(Types::String)
end
```

### ServiceResult

```ruby
class ServiceResult < BaseResponse
  attribute :success, Types::Bool
  attribute :data, Types::Any.optional
  attribute :errors, Types::Array.of(Types::String).default([].freeze)
  attribute :meta, Types::Any.optional

  def success?
    success
  end

  def self.success(data:, meta: nil)
    new(success: true, data: data, errors: [], meta: meta)
  end

  def self.failure(errors:)
    new(success: false, data: nil, errors: Array(errors))
  end
end
```

### PaginationMeta

```ruby
class PaginationMeta < BaseResponse
  attribute :current_page, Types::PositiveInteger
  attribute :total_pages, Types::PositiveInteger
  attribute :total_count, Types::PositiveInteger
  attribute :per_page, Types::PositiveInteger
end
```

**Benefits:**
- **Immutable** - Can't accidentally mutate
- **Self-documenting** - Types describe the shape
- **Fail-fast** - Wrong types raise immediately

---

## Blueprinter Serialization

### Why Blueprinter over JBuilder/AMS?

- **Faster** than JBuilder (no template compilation)
- **Cleaner** than ActiveModelSerializers
- **Association-aware** - Works with eager-loaded data

### ReleaseBlueprint

```ruby
class ReleaseBlueprint < ApplicationBlueprint
  identifier :id
  field :name

  # Uses pre-loaded association (no N+1)
  association :album, blueprint: AlbumBlueprint
  association :artists, blueprint: ArtistBlueprint

  # Custom formatting
  field :created_at do |release|
    release.created_at.iso8601
  end

  field :released_at do |release|
    release.released_at.iso8601
  end

  # Delegated from album
  field :duration_in_minutes
end
```

### In Controller

```ruby
render_success(result, serializer: ReleaseBlueprint)
# Internally calls: ReleaseBlueprint.render_as_hash(result.data)
```

---

## Search Implementation

### Fuzzy Search Pattern

User types "mj" and finds "Michael Jackson":

```ruby
def build_fuzzy_pattern(query)
  # "mj" becomes "%m%j%"
  "%#{query.chars.join('%')}%"
end
```

### Cross-Entity Search

Search across releases, albums, AND artists in one query:

```ruby
def apply_search(scope)
  pattern = build_fuzzy_pattern(@search_query)

  scope
    .joins(:album)
    .joins(:artists)
    .where(
      "releases.name ILIKE :pattern OR 
       albums.name ILIKE :pattern OR 
       artists.name ILIKE :pattern",
      pattern: pattern
    )
    .distinct  # Avoid duplicates from joins
end
```

**Why ILIKE?** Case-insensitive matching in PostgreSQL.

---

## Testing Strategy

### Test Pyramid

```
         /\
        /  \  E2E (None - not required)
       /____\
      /      \  Request Specs (integration)
     /________\
    /          \  Model Specs (unit)
   /______________\
  /                \  Service Specs (unit)
 /_____________________\
```

### Request Specs (Controller-level integration)

```ruby
RSpec.describe "Albums" do
  it "creates album with valid params" do
    post albums_path, params: { album: valid_params }
    
    expect(response).to redirect_to(album_path(Album.last))
    expect(Album.count).to eq(1)
  end
end
```

### Model Specs

```ruby
RSpec.describe Album do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:release_id) }
  end
end
```

### Service Specs

```ruby
RSpec.describe Releases::ListService do
  it "filters past releases" do
    past_release = create(:release, released_at: 1.day.ago)
    future_release = create(:release, released_at: 1.day.from_now)

    result = described_class.call(params: { past: "1" })

    expect(result.data).to include(past_release)
    expect(result.data).not_to include(future_release)
  end
end
```

### Test Coverage

- **268 examples, 0 failures**
- **RuboCop: 91 files, 0 offenses**
- **Brakeman: 0 security warnings**

---

## Security Considerations

### Brakeman Clean

We run Brakeman (static security analyzer) with zero warnings:

- No SQL injection vulnerabilities
- No mass assignment issues
- No XSS vulnerabilities
- CSRF protection on all web forms

### Key Security Patterns

1. **Strong Parameters** - Whitelist allowed attributes
   ```ruby
   def album_params
     params.require(:album).permit(:name, :duration_in_minutes, :artist_id, :release_id, :cover)
   end
   ```

2. **Token in Database** - Not in URL, stored securely
   ```ruby
   User.by_api_token(token).first  # Uses DB index
   ```

3. **Bcrypt Password Hashing** - Via `has_secure_password`

4. **API Token Generation** - SecureRandom
   ```ruby
   before_create :generate_api_token
   
   def generate_api_token
     self.api_token = SecureRandom.hex(32)
   end
   ```

---

## Key Interview Talking Points

### 1. "Why not use a JavaScript framework like React?"

> "Rails 8 with Hotwire provides 90% of the reactivity with 10% of the complexity. For a CRUD app, Turbo + Stimulus is more maintainable long-term. We get SPA-like navigation without a build step, state management, or hydration issues."

### 2. "How do you handle N+1 queries?"

> "We use query planners—scopes like `Release.for_index`—that eager load all needed associations. Controllers always go through these scopes, so N+1s are prevented by design, not by accident. Our test suite would catch any N+1 issues with tools like Bullet (if enabled)."

### 3. "Why extract to services instead of keeping logic in models?"

> "Models should know about persistence and relationships. Business logic that spans multiple models or has complex rules belongs in services. This also makes testing easier—we can test `Releases::ListService` without HTTP."

### 4. "Explain your API authentication strategy."

> "The API uses stateless Bearer token authentication. Tokens are stored in the database (indexed) and looked up on each request. No sessions or cookies for API routes. Web UI uses traditional session-based auth with CSRF protection."

### 5. "Why Blueprinter over JBuilder?"

> "Blueprinter is faster (no template compilation), works well with eager-loaded associations, and produces cleaner code. It's also more testable since it's just Ruby classes, not templates."

### 6. "How does your search work?"

> "We use PostgreSQL's ILIKE for case-insensitive matching with a fuzzy pattern. 'mj' becomes '%m%j%' which matches 'Michael Jackson'. The search spans releases, albums, and artists in a single query with proper indexing."

### 7. "What would you do differently with more time?"

> - "Add background jobs for heavy operations (Solid Queue is already configured)"
> - "Implement caching for the API (fragment caching, HTTP caching)"
> - "Add feature specs with Capybara for critical user journeys"
> - "Set up Bullet gem to catch N+1s in test suite automatically"

### 8. "Walk me through a request lifecycle."

> 1. Request hits `Api::ReleasesController#index`
> 2. `TokenAuthentication` concern validates the Bearer token
> 3. `ParameterSanitizer` whitelists allowed params
> 4. Controller calls `Releases::ListService.call(params:)`
> 5. Service builds query with eager loading and filters
> 6. Service returns `ServiceResult.success(data:, meta:)`
> 7. Controller calls `respond_with_result(result, serializer: ReleaseBlueprint)`
> 8. `ApiResponder` concern renders JSON with proper structure

---

## Quick Reference: File Locations

| Concern | Location |
|---------|----------|
| Stimulus controllers | `app/javascript/controllers/` |
| Services | `app/services/` |
| Blueprints (serializers) | `app/blueprints/` |
| Value objects | `app/responses/` |
| API controllers | `app/controllers/api/` |
| Auth concerns | `app/controllers/concerns/` |
| Model scopes | `app/models/*.rb` |
| Request specs | `spec/requests/` |

---
