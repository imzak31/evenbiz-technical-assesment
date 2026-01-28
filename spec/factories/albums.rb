# frozen_string_literal: true

FactoryBot.define do
  factory :album do
    sequence(:name) { |n| "#{Faker::Music.album} #{n}" }
    duration_in_minutes { Faker::Number.between(from: 3, to: 120) }
    association :release
    association :artist
  end
end
