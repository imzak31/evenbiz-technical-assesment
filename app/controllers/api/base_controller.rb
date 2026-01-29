# frozen_string_literal: true

module Api
  # Base controller for all API endpoints
  # Inherits from ActionController::API (no sessions, no CSRF)
  # Uses token-based authentication
  class BaseController < ActionController::API
    include TokenAuthentication
    include ParameterSanitizer
    include JsonApiResponder

    # Rescue common errors with JSON:API formatted responses
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request

    private

    def not_found
      render_jsonapi_error("Record not found", :not_found)
    end

    def unprocessable_entity(exception)
      render_jsonapi_errors(exception.record.errors.full_messages, :unprocessable_entity)
    end

    def bad_request(exception)
      render_jsonapi_error(exception.message, :bad_request)
    end
  end
end
