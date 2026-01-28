# frozen_string_literal: true

class Artist < ApplicationRecord
  has_many :albums, dependent: :destroy
  has_many :artist_releases, dependent: :destroy
  has_many :releases, through: :artist_releases

  # Attachments (polymorphic via Active Storage)
  has_one_attached :logo
  has_one_attached :banner

  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }

  # ==================
  # Query Planners
  # ==================

  # Minimal select for embedding in other serializations
  scope :for_embed, -> { select(:id, :name) }

  # Eager loads associations for index listing
  # Includes logo attachment to avoid N+1 queries on list views
  scope :for_index, -> { includes(:releases, logo_attachment: :blob).order(:name) }

  # Filter by release participation
  scope :for_release, ->(release_id) { joins(:artist_releases).where(artist_releases: { release_id: release_id }) }
end
