# frozen_string_literal: true

# Base service class providing common patterns
# All services return ServiceResult for consistency
class BaseService
  def self.call(...)
    new(...).call
  end

  private

  def success(data:, meta: nil)
    ServiceResult.success(data: data, meta: meta)
  end

  def failure(errors:)
    ServiceResult.failure(errors: errors)
  end

  def paginate(scope, page:, per_page:)
    paginated = scope.page(page).per(per_page)

    meta = PaginationMeta.new(
      current_page: paginated.current_page,
      total_pages: paginated.total_pages,
      total_count: paginated.total_count,
      per_page: paginated.limit_value,
    )

    [ paginated, meta ]
  end
end
