# frozen_string_literal: true

# JSON:API serializer for Release resources
# Primary serializer for the /api/releases endpoint
class ReleaseSerializer
  include JSONAPI::Serializer

  set_type :releases
  set_id :id

  attributes :name

  attribute :created_at do |release|
    release.created_at.iso8601
  end

  attribute :released_at do |release|
    release.released_at.iso8601
  end

  attribute :duration_in_minutes do |release|
    release.duration_in_minutes
  end

  # Relationships
  has_one :album, serializer: AlbumSerializer
  has_many :artists, serializer: ArtistSerializer

  link :self do |release|
    "/api/releases/#{release.id}"
  end
end
