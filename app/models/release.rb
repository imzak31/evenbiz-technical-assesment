# frozen_string_literal: true

class Release < ApplicationRecord
  has_one :album, dependent: :destroy
  has_many :artist_releases, dependent: :destroy
  has_many :artists, through: :artist_releases

  validates :name, presence: true, length: { maximum: 255 }
  validates :released_at, presence: true

  # ==================
  # Query Planners
  # ==================

  # Eager loads all associations needed for index/list serialization
  scope :for_index, -> { includes(:album, :artists).order(released_at: :desc) }

  # Eager loads associations for detailed serialization
  scope :for_show, -> { includes(album: :artist, artists: {}) }

  # Filter by artist participation (primary or featured)
  scope :for_artist, ->(artist_id) { joins(:artist_releases).where(artist_releases: { artist_id: artist_id }) }

  # ==================
  # Filters
  # ==================

  scope :past, -> { where(released_at: ...Time.current) }
  scope :upcoming, -> { where(released_at: Time.current..) }

  # ==================
  # Delegations
  # ==================

  delegate :duration_in_minutes, to: :album, allow_nil: true
end
