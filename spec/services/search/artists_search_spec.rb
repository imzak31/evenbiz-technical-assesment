# frozen_string_literal: true

require "rails_helper"

RSpec.describe Search::ArtistsSearch do
  describe "#call" do
    let(:search) { described_class.new }

    context "with blank query" do
      it "returns all artists when query is nil" do
        artists = create_list(:artist, 3)

        result = search.call(nil)

        expect(result.count).to eq(3)
      end

      it "returns all artists when query is empty string" do
        artists = create_list(:artist, 3)

        result = search.call("")

        expect(result.count).to eq(3)
      end

      it "returns all artists when query is whitespace only" do
        artists = create_list(:artist, 3)

        result = search.call("   ")

        expect(result.count).to eq(3)
      end
    end

    context "with exact match" do
      it "finds artist by exact name" do
        matching = create(:artist, name: "The Beatles")
        _non_matching = create(:artist, name: "Pink Floyd")

        result = search.call("The Beatles")

        expect(result).to contain_exactly(matching)
      end

      it "is case insensitive" do
        matching = create(:artist, name: "The Beatles")

        result = search.call("the beatles")

        expect(result).to contain_exactly(matching)
      end
    end

    context "with partial match" do
      it "finds artist by partial name" do
        matching = create(:artist, name: "The Beatles")

        result = search.call("Beatles")

        expect(result).to contain_exactly(matching)
      end

      it "finds artist by beginning of name" do
        matching = create(:artist, name: "The Beatles")

        result = search.call("The")

        expect(result).to contain_exactly(matching)
      end
    end

    context "with fuzzy matching" do
      it "matches characters in sequence skipping letters" do
        matching = create(:artist, name: "High Energy")
        _non_matching = create(:artist, name: "Low Power")

        # "hih" should match "High" (h-i-h pattern)
        result = search.call("hih")

        expect(result).to contain_exactly(matching)
      end

      it "matches across word boundaries" do
        matching = create(:artist, name: "John Lennon")
        _non_matching = create(:artist, name: "Paul McCartney")

        # "jhnln" matches J-o-h-n L-e-n-n-o-n
        result = search.call("jhnln")

        expect(result).to contain_exactly(matching)
      end

      it "handles typos gracefully" do
        matching = create(:artist, name: "Michael Jackson")

        # "mcljck" - fuzzy match for Michael Jackson
        result = search.call("mcljck")

        expect(result).to contain_exactly(matching)
      end

      it "ignores spaces in search query" do
        matching = create(:artist, name: "Pink Floyd")

        result = search.call("pnk fld")

        expect(result).to contain_exactly(matching)
      end
    end

    context "with special SQL characters" do
      it "escapes percent signs" do
        matching = create(:artist, name: "100% Pure")

        result = search.call("100%")

        expect(result).to contain_exactly(matching)
      end

      it "escapes underscores" do
        matching = create(:artist, name: "Under_score Band")

        result = search.call("Under_score")

        expect(result).to contain_exactly(matching)
      end

      it "escapes backslashes" do
        matching = create(:artist, name: "Back\\Slash")

        result = search.call("Back\\Slash")

        expect(result).to contain_exactly(matching)
      end
    end

    context "with custom scope" do
      it "respects the provided scope" do
        artist1 = create(:artist, name: "Active Artist")
        _artist2 = create(:artist, name: "Another Active")

        custom_scope = Artist.where(id: artist1.id)
        search_with_scope = described_class.new(custom_scope)

        result = search_with_scope.call("Active")

        expect(result).to contain_exactly(artist1)
      end
    end

    context "with multiple matches" do
      it "returns all matching artists" do
        beatles = create(:artist, name: "The Beatles")
        beach_boys = create(:artist, name: "The Beach Boys")
        _pink_floyd = create(:artist, name: "Pink Floyd")

        result = search.call("The B")

        expect(result).to contain_exactly(beatles, beach_boys)
      end
    end
  end
end
