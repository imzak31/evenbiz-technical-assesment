# frozen_string_literal: true

# Pagination metadata for list responses
class PaginationMeta < BaseResponse
  attribute :current_page, Types::PositiveInteger
  attribute :total_pages, Types::PositiveInteger
  attribute :total_count, Types::PositiveInteger
  attribute :per_page, Types::PositiveInteger
end
