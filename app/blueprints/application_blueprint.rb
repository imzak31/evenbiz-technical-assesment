# frozen_string_literal: true

# Base serializer configuration
# Sets up Blueprinter defaults for the application
class ApplicationBlueprint < Blueprinter::Base
  # Use snake_case for JSON keys (Rails convention)
  # Override in child classes if needed

  # Helper to generate Active Storage attachment URLs
  # Returns nil if attachment is not present
  def self.attachment_url(record, attachment_name)
    attachment = record.public_send(attachment_name)
    return nil unless attachment.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      attachment,
      host: Rails.application.config.action_mailer.default_url_options&.dig(:host) || "localhost:3000"
    )
  end
end
