# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_one_attached :avatar

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    length: { maximum: 255 },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :api_token, presence: true, uniqueness: true, length: { maximum: 64 }
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :profile_picture_url, length: { maximum: 2048 }, allow_blank: true

  before_validation :generate_api_token, on: :create

  # Normalize email before saving
  normalizes :email, with: ->(email) { email.strip.downcase }

  # ==================
  # Query Planners
  # ==================

  scope :for_auth, -> { select(:id, :email, :password_digest) }
  scope :for_embed, -> { select(:id, :first_name, :last_name, :email) }
  scope :by_api_token, ->(token) { where(api_token: token) }

  # ==================
  # Computed Attributes
  # ==================

  def full_name
    "#{first_name} #{last_name}".strip
  end

  # ==================
  # Token Management
  # ==================

  def regenerate_api_token!
    update!(api_token: self.class.generate_unique_token)
  end

  def self.generate_unique_token
    loop do
      token = SecureRandom.hex(32)
      break token unless exists?(api_token: token)
    end
  end

  private

  def generate_api_token
    self.api_token ||= self.class.generate_unique_token
  end
end
