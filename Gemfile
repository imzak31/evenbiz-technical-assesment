# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "~> 8.1.2"

# Core
gem "bcrypt", "~> 3.1.7"
gem "bootsnap", require: false
gem "image_processing", "~> 1.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[windows jruby]

# Assets & Frontend
gem "cssbundling-rails"
gem "jsbundling-rails"
gem "propshaft"
gem "stimulus-rails"
gem "turbo-rails"

# API
gem "jsonapi-serializer"
gem "kaminari"
gem "rack-cors"

# Data & Types
gem "dry-struct"
gem "dry-types"

# Background Jobs & Caching
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"

# Deployment
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
  gem "rubocop-performance", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
end

group :development do
  gem "bullet"
  gem "letter_opener"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "webmock"
end
