# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_custom_token do
      api_token { SecureRandom.hex(32) }
    end

    trait :with_avatar do
      after(:build) do |user|
        user.avatar.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/avatar.png")),
          filename: "avatar.png",
          content_type: "image/png",
        )
      end
    end
  end
end
