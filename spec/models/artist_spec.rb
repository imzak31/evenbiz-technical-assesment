# frozen_string_literal: true

require "rails_helper"

RSpec.describe Artist do
  describe "associations" do
    it { is_expected.to have_many(:albums).dependent(:destroy) }
    it { is_expected.to have_many(:artist_releases).dependent(:destroy) }
    it { is_expected.to have_many(:releases).through(:artist_releases) }
    it { is_expected.to have_one_attached(:logo) }
    it { is_expected.to have_one_attached(:banner) }
  end

  describe "validations" do
    subject { build(:artist) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
  end

  describe ".for_release" do
    let(:release) { create(:release) }
    let(:artist) { create(:artist) }
    let(:other_artist) { create(:artist) }

    before do
      create(:artist_release, artist: artist, release: release)
    end

    it "returns artists for the given release" do
      expect(described_class.for_release(release.id)).to include(artist)
      expect(described_class.for_release(release.id)).not_to include(other_artist)
    end
  end

  describe ".for_index" do
    it "orders by name" do
      create(:artist, name: "Zulu Band")
      create(:artist, name: "Alpha Band")

      result = described_class.for_index.pluck(:name)
      expect(result.index("Alpha Band")).to be < result.index("Zulu Band")
    end
  end
end
