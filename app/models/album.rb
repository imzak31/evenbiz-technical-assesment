# frozen_string_literal: true

class Album < ApplicationRecord
  belongs_to :release
  belongs_to :artist

  validates :name, presence: true, length: { maximum: 255 }
  validates :duration_in_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # ==================
  # Query Planners
  # ==================

  # Minimal select for embedding in release serialization
  scope :for_embed, -> { select(:id, :name, :duration_in_minutes, :release_id) }

  # Eager loads associations for index listing
  scope :for_index, -> { includes(:artist, :release).order(created_at: :desc) }

  # Filter by artist
  scope :for_artist, ->(artist_id) { where(artist_id: artist_id) }
end
