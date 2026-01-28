# frozen_string_literal: true

class ArtistRelease < ApplicationRecord
  belongs_to :artist
  belongs_to :release

  validates :artist_id, uniqueness: { scope: :release_id, message: "has already been added to this release" }
end
