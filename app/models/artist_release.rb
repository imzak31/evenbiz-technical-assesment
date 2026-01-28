# frozen_string_literal: true

class ArtistRelease < ApplicationRecord
  belongs_to :artist
  belongs_to :release

  validates :artist_id, uniqueness: { scope: :release_id, message: "is already associated with this release" }
end
