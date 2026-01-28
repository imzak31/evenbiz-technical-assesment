# frozen_string_literal: true

# Concern for standardized API response formatting
# Handles success/failure responses with consistent structure
module ApiResponder
  extend ActiveSupport::Concern

  private

  # Renders a successful service result with serialization
  def render_success(result, serializer:, status: :ok)
    body = {
      data: serializer.render_as_hash(result.data),
    }

    body[:meta] = result.meta.to_h if result.meta

    render_json(body, status: status)
  end

  # Renders a failure service result
  def render_failure(result, status: :unprocessable_entity)
    render_json({ errors: result.errors }, status: status)
  end

  # Renders JSON with pretty formatting in development
  def render_json(body, status:)
    if Rails.env.development?
      render json: JSON.pretty_generate(body), status: status
    else
      render json: body, status: status
    end
  end

  # Convenience method for service result handling
  def respond_with_result(result, serializer:, success_status: :ok, failure_status: :unprocessable_entity)
    if result.success?
      render_success(result, serializer: serializer, status: success_status)
    else
      render_failure(result, status: failure_status)
    end
  end
end
