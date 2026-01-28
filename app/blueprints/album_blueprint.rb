# frozen_string_literal: true

module Blueprints
  # Serializes Album for embedding in release responses
  # Only includes name - duration accessed via Release delegation
  class AlbumBlueprint < ApplicationBlueprint
    field :name
  end
end
