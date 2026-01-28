# frozen_string_literal: true

class Artist < ApplicationRecord
  has_many :albums, dependent: :destroy
  has_many :artist_releases, dependent: :destroy
  has_many :releases, through: :artist_releases

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
end
