# frozen_string_literal: true

require "dry-struct"

# Base struct for all response objects
# Provides strict typing and immutability
class BaseResponse < Dry::Struct
  transform_keys(&:to_sym)
end
