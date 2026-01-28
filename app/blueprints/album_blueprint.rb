# frozen_string_literal: true

# Serializes Album for embedding in release responses
# Only includes name - duration accessed via Release delegation
class AlbumBlueprint < ApplicationBlueprint
  field :name

  field :cover_url do |album|
    attachment_url(album, :cover)
  end
end
