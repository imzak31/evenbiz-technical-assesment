# frozen_string_literal: true

require "dry-types"

# Base types module for the application
# Provides strict typing for service responses and value objects
module Types
  include Dry.Types()

  # Common types
  PositiveInteger = Strict::Integer.constrained(gteq: 0)
  NonEmptyString = Strict::String.constrained(min_size: 1)
end
