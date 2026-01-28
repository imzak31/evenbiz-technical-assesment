# frozen_string_literal: true

class Release < ApplicationRecord
  has_one :album, dependent: :destroy
  has_many :artist_releases, dependent: :destroy
  has_many :artists, through: :artist_releases

  validates :name, presence: true, length: { maximum: 255 }
  validates :released_at, presence: true

  scope :past, -> { where(released_at: ...Time.current) }
  scope :upcoming, -> { where(released_at: Time.current..) }
end
