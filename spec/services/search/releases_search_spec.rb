# frozen_string_literal: true

require "rails_helper"

RSpec.describe Search::ReleasesSearch do
  describe "#call" do
    let(:search) { described_class.new }

    # Helper to create a release with artist
    def create_release_with_artist(release_name:, artist_name:)
      artist = create(:artist, name: artist_name)
      release = create(:release, name: release_name)
      create(:artist_release, artist: artist, release: release)
      release
    end

    context "with blank query" do
      it "returns all releases when query is nil" do
        create_list(:release, 3)

        result = search.call(nil)

        expect(result.count).to eq(3)
      end

      it "returns all releases when query is empty string" do
        create_list(:release, 3)

        result = search.call("")

        expect(result.count).to eq(3)
      end
    end

    context "matching release name" do
      it "finds release by exact name" do
        matching = create(:release, name: "Thriller")
        _non_matching = create(:release, name: "Abbey Road")

        result = search.call("Thriller")

        expect(result).to contain_exactly(matching)
      end

      it "finds release by partial name" do
        matching = create(:release, name: "Abbey Road")

        result = search.call("Abbey")

        expect(result).to contain_exactly(matching)
      end

      it "is case insensitive" do
        matching = create(:release, name: "Thriller")

        result = search.call("thriller")

        expect(result).to contain_exactly(matching)
      end
    end

    context "matching artist name" do
      it "finds release by artist name" do
        matching = create_release_with_artist(
          release_name: "Thriller",
          artist_name: "Michael Jackson"
        )
        _non_matching = create_release_with_artist(
          release_name: "Abbey Road",
          artist_name: "The Beatles"
        )

        result = search.call("Michael")

        expect(result).to contain_exactly(matching)
      end

      it "finds release by partial artist name" do
        matching = create_release_with_artist(
          release_name: "Thriller",
          artist_name: "Michael Jackson"
        )

        result = search.call("Jackson")

        expect(result).to contain_exactly(matching)
      end
    end

    context "with fuzzy matching" do
      it "matches release name with character sequence" do
        matching = create(:release, name: "High Voltage")
        _non_matching = create(:release, name: "Low Power")

        result = search.call("hihvlt")

        expect(result).to contain_exactly(matching)
      end

      it "matches artist name with character sequence" do
        matching = create_release_with_artist(
          release_name: "Some Album",
          artist_name: "High Energy Band"
        )
        _non_matching = create_release_with_artist(
          release_name: "Other Album",
          artist_name: "Low Power Group"
        )

        result = search.call("hihegy")

        expect(result).to contain_exactly(matching)
      end
    end

    context "with multiple artists" do
      it "finds release when any artist matches" do
        artist1 = create(:artist, name: "John Lennon")
        artist2 = create(:artist, name: "Paul McCartney")
        release = create(:release, name: "Imagine")
        create(:artist_release, artist: artist1, release: release)
        create(:artist_release, artist: artist2, release: release)

        result = search.call("Paul")

        expect(result).to contain_exactly(release)
      end

      it "does not duplicate releases with multiple matching artists" do
        artist1 = create(:artist, name: "The Band One")
        artist2 = create(:artist, name: "The Band Two")
        release = create(:release, name: "Collaboration")
        create(:artist_release, artist: artist1, release: release)
        create(:artist_release, artist: artist2, release: release)

        result = search.call("The Band")

        expect(result.count).to eq(1)
        expect(result).to contain_exactly(release)
      end
    end

    context "matching either release or artist" do
      it "returns releases matching name OR artist" do
        release_by_name = create(:release, name: "Thunder Road")
        release_by_artist = create_release_with_artist(
          release_name: "Born to Run",
          artist_name: "Thunder Band"
        )
        _non_matching = create_release_with_artist(
          release_name: "Other Album",
          artist_name: "Other Artist"
        )

        result = search.call("Thunder")

        expect(result).to contain_exactly(release_by_name, release_by_artist)
      end
    end

    context "with custom scope" do
      it "respects the provided scope" do
        release1 = create(:release, name: "Matching One")
        _release2 = create(:release, name: "Matching Two")

        custom_scope = Release.where(id: release1.id)
        search_with_scope = described_class.new(custom_scope)

        result = search_with_scope.call("Matching")

        expect(result).to contain_exactly(release1)
      end
    end
  end
end
