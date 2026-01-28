# frozen_string_literal: true

# Serializes Artist for embedding in other responses
# Includes logo for visual representation
class ArtistBlueprint < ApplicationBlueprint
  identifier :id

  field :name

  field :logo_url do |artist|
    attachment_url(artist, :logo)
  end
end
