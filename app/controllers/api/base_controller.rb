# frozen_string_literal: true

module Api
  # Base controller for all API endpoints
  # Inherits from ActionController::API (no sessions, no CSRF)
  # Uses token-based authentication
  class BaseController < ActionController::API
    include TokenAuthentication

    # Rescue common errors with JSON responses
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request

    private

    def not_found
      render json: { error: "Not Found" }, status: :not_found
    end

    def unprocessable_entity(exception)
      render json: { error: "Unprocessable Entity", details: exception.record.errors }, status: :unprocessable_entity
    end

    def bad_request(exception)
      render json: { error: "Bad Request", message: exception.message }, status: :bad_request
    end

    # Pagination helper
    def pagination_meta(collection)
      {
        current_page: collection.current_page,
        total_pages: collection.total_pages,
        total_count: collection.total_count,
        per_page: collection.limit_value,
      }
    end
  end
end
