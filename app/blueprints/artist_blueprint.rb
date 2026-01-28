# frozen_string_literal: true

module Blueprints
  # Serializes Artist for embedding in other responses
  # Minimal footprint - only id and name
  class ArtistBlueprint < ApplicationBlueprint
    identifier :id

    field :name
  end
end
