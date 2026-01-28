# frozen_string_literal: true

# Concern for parameter sanitization and whitelisting
# Provides a clean interface for permitted params per action
module ParameterSanitizer
  extend ActiveSupport::Concern

  private

  # Override in controllers to define permitted params per action
  # Returns a hash of action_name => permitted_keys
  def permitted_params_mapping
    {}
  end

  # Returns sanitized params for the current action
  def sanitized_params
    allowed_keys = permitted_params_mapping[action_name.to_sym] || []

    params.permit(*allowed_keys)
  end

  # Common pagination params - reusable across controllers
  def pagination_params
    [ :page, :limit ]
  end
end
