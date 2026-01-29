# frozen_string_literal: true

module Api
  # Thin controller for releases API
  # Delegates all business logic to services
  # Only handles HTTP concerns: params, responses, status codes
  # Returns JSON:API compliant responses
  class ReleasesController < BaseController
    def index
      result = Releases::ListService.call(params: sanitized_params)

      if result.success?
        render_jsonapi_collection(result.data, result.meta)
      else
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    end

    private

    def render_jsonapi_collection(releases, pagination_meta)
      options = {
        include: %i[album artists],
        meta: build_meta(pagination_meta),
        links: build_pagination_links(pagination_meta),
      }

      render json: ReleaseSerializer.new(releases, options).serializable_hash,
             content_type: "application/vnd.api+json"
    end

    def build_meta(pagination_meta)
      {
        current_page: pagination_meta.current_page,
        total_pages: pagination_meta.total_pages,
        total_count: pagination_meta.total_count,
        per_page: pagination_meta.per_page,
      }
    end

    def build_pagination_links(meta)
      base_url = request.base_url + request.path
      current_params = request.query_parameters.except("page")

      links = {
        self: build_page_url(base_url, current_params, meta.current_page),
        first: build_page_url(base_url, current_params, 1),
        last: build_page_url(base_url, current_params, meta.total_pages),
      }

      links[:prev] = build_page_url(base_url, current_params, meta.current_page - 1) if meta.current_page > 1
      links[:next] = build_page_url(base_url, current_params, meta.current_page + 1) if meta.current_page < meta.total_pages

      links
    end

    def build_page_url(base_url, params, page)
      query = params.merge(page: page).to_query
      query.present? ? "#{base_url}?#{query}" : base_url
    end

    def permitted_params_mapping
      {
        index: pagination_params + %i[past search],
      }
    end
  end
end
