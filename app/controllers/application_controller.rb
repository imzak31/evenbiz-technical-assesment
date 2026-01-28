# frozen_string_literal: true

# Base controller for UI/Monolith routes
# Uses session-based authentication with CSRF protection
class ApplicationController < ActionController::Base
  include SessionAuthentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Skip authentication for public pages (override in child controllers)
  skip_before_action :require_authentication, only: [], raise: false
end
