# frozen_string_literal: true

require "dry-struct"

module Responses
  # Base struct for all response objects
  # Provides strict typing and immutability
  class Base < Dry::Struct
    transform_keys(&:to_sym)
  end
end
