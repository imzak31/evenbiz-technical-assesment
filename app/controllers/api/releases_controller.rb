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
        render_jsonapi(ReleaseSerializer, result.data, include: %i[album artists], meta: result.meta)
      else
        render_jsonapi_errors(result.errors, :unprocessable_entity)
      end
    end

    private

    def permitted_params_mapping
      {
        index: pagination_params + %i[past search],
      }
    end
  end
end
