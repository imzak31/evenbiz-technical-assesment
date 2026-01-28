# frozen_string_literal: true

FactoryBot.define do
  factory :release do
    sequence(:name) { |n| "#{Faker::Music.album} #{n}" }
    released_at { Faker::Time.between(from: 1.year.ago, to: 1.year.from_now) }

    trait :past do
      released_at { Faker::Time.between(from: 1.year.ago, to: 1.day.ago) }
    end

    trait :upcoming do
      released_at { Faker::Time.between(from: 1.day.from_now, to: 1.year.from_now) }
    end
  end
end
