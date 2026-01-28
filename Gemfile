# frozen_string_literal: true

source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"

# Fast, declarative serializers for JSON APIs
gem "blueprinter"

# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.7"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Typed structs and value objects for safer data handling
gem "dry-struct"

# Flexible type system for Ruby, useful with dry-struct
gem "dry-types"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Track changes to your models' data
gem "paper_trail"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# A Scope & Engine based, clean, powerful, customizable and sophisticated pagination for Rails 3+
gem "kaminari"

# Support for Cross-Origin Resource Sharing (CORS) for API usage
gem "rack-cors"

# Use the database-backed adapters for Action Cable
gem "solid_cable"

# Use the database-backed adapters for Rails.cache
gem "solid_cache"

# Use the database-backed adapters for Active Job
gem "solid_queue"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Debugging tool for Ruby [https://github.com/ruby/debug]
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Load environment variables from .env file
  gem "dotenv-rails"

  # Replacement for Rails fixtures, allowing build strategies
  gem "factory_bot_rails"

  # Generate fake data for seeds and tests
  gem "faker"

  # Integration testing framework for Ruby
  gem "rspec-rails"

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Performance optimizations for RuboCop
  gem "rubocop-performance", require: false

  # RSpec cops for RuboCop
  gem "rubocop-rspec", require: false
end

group :development do
  # Help to kill N+1 queries and unused eager loading
  gem "bullet"

  # Preview emails in the default browser instead of sending it
  gem "letter_opener"

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
