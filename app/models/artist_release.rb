# frozen_string_literal: true

class ArtistRelease < ApplicationRecord
  belongs_to :artist
  belongs_to :release
end
