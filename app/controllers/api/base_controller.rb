# frozen_string_literal: true

module Api
  # Base controller for all API endpoints
  # Inherits from ActionController::API (no sessions, no CSRF)
  # Uses token-based authentication
  class BaseController < ActionController::API
    include TokenAuthentication
    include ApiResponder
    include ParameterSanitizer

    # Rescue common errors with JSON responses
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request

    private

    def not_found
      render json: { errors: [ "Record not found" ] }, status: :not_found
    end

    def unprocessable_entity(exception)
      render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
    end

    def bad_request(exception)
      render json: { errors: [ exception.message ] }, status: :bad_request
    end
  end
end
