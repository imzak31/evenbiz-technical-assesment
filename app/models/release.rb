# frozen_string_literal: true

class Release < ApplicationRecord
  has_one :album, dependent: :destroy
  has_many :artist_releases, dependent: :destroy
  has_many :artists, through: :artist_releases

  accepts_nested_attributes_for :album, reject_if: :all_blank

  validates :name, presence: true, length: { maximum: 255 }
  validates :released_at, presence: true

  # ==================
  # Query Planners
  # ==================

  # Eager loads all associations needed for index/list serialization
  # Includes attachments (cover, logo) to avoid N+1 queries
  # Orders by released_at desc, then by name for deterministic ordering
  scope :for_index, lambda {
    includes(album: { cover_attachment: :blob }, artists: { logo_attachment: :blob })
      .order(released_at: :desc, name: :asc)
  }

  # Eager loads associations for detailed serialization
  scope :for_show, -> { includes(album: [ :cover_attachment, :artist ], artists: :logo_attachment) }

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
