# frozen_string_literal: true

module Responses
  # Standardized service result wrapper
  # Encapsulates success/failure state with typed data
  class ServiceResult < Base
    attribute :success, Types::Bool
    attribute :data, Types::Any.optional
    attribute :errors, Types::Array.of(Types::String).default([].freeze)
    attribute :meta, Types::Any.optional

    def success?
      success
    end

    def failure?
      !success
    end

    # Factory methods for cleaner service code
    def self.success(data:, meta: nil)
      new(success: true, data: data, errors: [], meta: meta)
    end

    def self.failure(errors:)
      errors_array = errors.is_a?(Array) ? errors : [ errors ]
      new(success: false, data: nil, errors: errors_array, meta: nil)
    end
  end
end
