# frozen_string_literal: true

# Serializes Release for API responses
# Uses pre-loaded associations to avoid N+1
class ReleaseBlueprint < ApplicationBlueprint
  identifier :id

  field :name

  # Nested album - uses already eager-loaded association
  association :album, blueprint: AlbumBlueprint

  # Artists collection - uses already eager-loaded association
  association :artists, blueprint: ArtistBlueprint

  field :created_at do |release|
    release.created_at.iso8601
  end

  field :released_at do |release|
    release.released_at.iso8601
  end

  # Duration delegated from album to release model
  field :duration_in_minutes
end
