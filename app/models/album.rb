# frozen_string_literal: true

class Album < ApplicationRecord
  belongs_to :release
  belongs_to :artist

  # Attachments (polymorphic via Active Storage)
  has_one_attached :cover

  validates :name, presence: true, length: { maximum: 255 }
  validates :duration_in_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :release_id, uniqueness: { message: "already has an album assigned" }

  # ==================
  # Query Planners
  # ==================

  # Minimal select for embedding in release serialization
  scope :for_embed, -> { select(:id, :name, :duration_in_minutes, :release_id) }

  # Eager loads associations for index listing
  # Includes cover attachment to avoid N+1 queries on list views
  scope :for_index, -> { includes(:artist, :release, cover_attachment: :blob).order(created_at: :desc) }

  # Filter by artist
  scope :for_artist, ->(artist_id) { where(artist_id: artist_id) }
end
