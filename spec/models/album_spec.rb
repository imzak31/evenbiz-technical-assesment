# frozen_string_literal: true

require "rails_helper"

RSpec.describe Album do
  describe "associations" do
    it { is_expected.to belong_to(:release) }
    it { is_expected.to belong_to(:artist) }
    it { is_expected.to have_one_attached(:cover) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_presence_of(:duration_in_minutes) }
    it { is_expected.to validate_numericality_of(:duration_in_minutes).only_integer.is_greater_than(0) }
  end

  describe ".for_artist" do
    let(:artist) { create(:artist) }
    let(:other_artist) { create(:artist) }
    let!(:album_for_artist) { create(:album, artist: artist) }
    let!(:album_for_other) { create(:album, artist: other_artist) }

    it "returns albums for the given artist" do
      expect(described_class.for_artist(artist.id)).to include(album_for_artist)
      expect(described_class.for_artist(artist.id)).not_to include(album_for_other)
    end
  end
end
