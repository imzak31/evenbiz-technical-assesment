# frozen_string_literal: true

# JSON:API serializer for Album resources
# Used as an included resource in Release responses
class AlbumSerializer
  include JSONAPI::Serializer

  set_type :albums
  set_id :id

  attributes :name, :duration_in_minutes

  attribute :cover_url do |album|
    if album.cover.attached?
      Rails.application.routes.url_helpers.rails_blob_url(album.cover, only_path: true)
    end
  end

  belongs_to :artist, serializer: ArtistSerializer

  link :self do |album|
    "/api/albums/#{album.id}"
  end
end
