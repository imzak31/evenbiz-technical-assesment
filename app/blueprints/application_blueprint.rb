# frozen_string_literal: true

# Base serializer configuration
# Sets up Blueprinter defaults for the application
class ApplicationBlueprint < Blueprinter::Base
  # Use snake_case for JSON keys (Rails convention)
  # Override in child classes if needed
end
