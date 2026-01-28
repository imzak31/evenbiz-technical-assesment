# frozen_string_literal: true

module Api
  # Thin controller for releases API
  # Delegates all business logic to services
  # Only handles HTTP concerns: params, responses, status codes
  class ReleasesController < BaseController
    def index
      result = Releases::ListService.call(params: sanitized_params)

      respond_with_result(result, serializer: ReleaseBlueprint)
    end

    private

    def permitted_params_mapping
      {
        index: pagination_params + [ :past ],
      }
    end
  end
end
