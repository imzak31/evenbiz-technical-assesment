# frozen_string_literal: true

module Responses
  # Pagination metadata for list responses
  class PaginationMeta < Base
    attribute :current_page, Types::PositiveInteger
    attribute :total_pages, Types::PositiveInteger
    attribute :total_count, Types::PositiveInteger
    attribute :per_page, Types::PositiveInteger
  end
end
