# frozen_string_literal: true

require "rails_helper"

RSpec.describe Release do
  describe "associations" do
    it { is_expected.to have_one(:album).dependent(:destroy) }
    it { is_expected.to have_many(:artist_releases).dependent(:destroy) }
    it { is_expected.to have_many(:artists).through(:artist_releases) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_presence_of(:released_at) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:duration_in_minutes).to(:album).allow_nil }
  end

  describe ".for_index" do
    it "orders by released_at desc as primary sort" do
      older_release = create(:release, :past, name: "Zebra", released_at: 2.days.ago)
      newer_release = create(:release, :past, name: "Alpha", released_at: 1.day.ago)

      result = described_class.for_index.pluck(:id)
      expect(result.index(newer_release.id)).to be < result.index(older_release.id)
    end

    it "orders by name asc as secondary sort for same released_at" do
      base_time = 3.days.ago
      release_z = create(:release, :past, name: "Zulu", released_at: base_time)
      release_a = create(:release, :past, name: "Apple", released_at: base_time)

      result = described_class.for_index.pluck(:name)
      expect(result.index("Apple")).to be < result.index("Zulu")
    end

    it "eager loads album and artists associations" do
      scope = described_class.for_index

      includes = scope.includes_values.first
      expect(includes.keys).to include(:album, :artists)
    end
  end

  describe ".past" do
    let!(:past_release) { create(:release, released_at: 1.day.ago) }
    let!(:future_release) { create(:release, released_at: 1.day.from_now) }

    it "returns only releases with released_at before now" do
      expect(described_class.past).to include(past_release)
      expect(described_class.past).not_to include(future_release)
    end
  end

  describe ".upcoming" do
    let!(:past_release) { create(:release, released_at: 1.day.ago) }
    let!(:future_release) { create(:release, released_at: 1.day.from_now) }

    it "returns only releases with released_at in the future" do
      expect(described_class.upcoming).to include(future_release)
      expect(described_class.upcoming).not_to include(past_release)
    end
  end

  describe ".for_artist" do
    let(:artist) { create(:artist) }
    let(:other_artist) { create(:artist) }
    let!(:release_with_artist) { create(:release) }
    let!(:release_without_artist) { create(:release) }

    before do
      create(:artist_release, artist: artist, release: release_with_artist)
      create(:artist_release, artist: other_artist, release: release_without_artist)
    end

    it "returns releases for the given artist" do
      expect(described_class.for_artist(artist.id)).to include(release_with_artist)
      expect(described_class.for_artist(artist.id)).not_to include(release_without_artist)
    end
  end
end
