# frozen_string_literal: true

FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "#{Faker::Music.band} #{n}" }
  end
end
