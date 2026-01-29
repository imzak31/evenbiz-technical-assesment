# frozen_string_literal: true

# JSON:API serializer for Artist resources
# Used as an included resource in Release responses
class ArtistSerializer
  include JSONAPI::Serializer

  set_type :artists
  set_id :id

  attributes :name

  attribute :logo_url do |artist|
    if artist.logo.attached?
      Rails.application.routes.url_helpers.rails_blob_url(artist.logo, only_path: true)
    end
  end

  link :self do |artist|
    "/api/artists/#{artist.id}"
  end
end
