# frozen_string_literal: true

class Album < ApplicationRecord
  belongs_to :release
  belongs_to :artist

  validates :name, presence: true, length: { maximum: 255 }
  validates :duration_in_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
