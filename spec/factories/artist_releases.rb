# frozen_string_literal: true

FactoryBot.define do
  factory :artist_release do
    association :artist
    association :release
  end
end
