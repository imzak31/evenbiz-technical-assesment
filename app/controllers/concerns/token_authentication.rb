# frozen_string_literal: true

# Concern for token-based authentication (API routes)
# Stateless, no CSRF, uses Authorization header
module TokenAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_api_authentication
  end

  private

  def current_user
    @current_user ||= authenticate_with_token
  end

  def authenticated?
    current_user.present?
  end

  def require_api_authentication
    return if authenticated?

    render json: { error: "Unauthorized", message: "Invalid or missing API token" }, status: :unauthorized
  end

  def authenticate_with_token
    token = extract_token_from_header
    return nil if token.blank?

    # Use timing-safe comparison via database lookup with indexed column
    User.by_api_token(token).first
  end

  def extract_token_from_header
    # Supports: "Bearer <token>" or just "<token>"
    header = request.headers["Authorization"]
    return nil if header.blank?

    header.start_with?("Bearer ") ? header.delete_prefix("Bearer ") : header
  end
end
