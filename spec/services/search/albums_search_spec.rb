# frozen_string_literal: true

require "rails_helper"

RSpec.describe Search::AlbumsSearch do
  describe "#call" do
    let(:search) { described_class.new }

    context "with blank query" do
      it "returns all albums when query is nil" do
        create_list(:album, 3)

        result = search.call(nil)

        expect(result.count).to eq(3)
      end

      it "returns all albums when query is empty string" do
        create_list(:album, 3)

        result = search.call("")

        expect(result.count).to eq(3)
      end
    end

    context "matching album name" do
      it "finds album by exact name" do
        matching = create(:album, name: "Thriller")
        _non_matching = create(:album, name: "Abbey Road")

        result = search.call("Thriller")

        expect(result).to contain_exactly(matching)
      end

      it "finds album by partial name" do
        matching = create(:album, name: "Abbey Road")

        result = search.call("Abbey")

        expect(result).to contain_exactly(matching)
      end

      it "is case insensitive" do
        matching = create(:album, name: "Thriller")

        result = search.call("THRILLER")

        expect(result).to contain_exactly(matching)
      end
    end

    context "matching artist name" do
      it "finds album by artist name" do
        artist = create(:artist, name: "Michael Jackson")
        matching = create(:album, name: "Thriller", artist: artist)
        _non_matching = create(:album, name: "Abbey Road")

        result = search.call("Michael")

        expect(result).to contain_exactly(matching)
      end

      it "finds album by partial artist name" do
        artist = create(:artist, name: "Michael Jackson")
        matching = create(:album, name: "Thriller", artist: artist)

        result = search.call("Jackson")

        expect(result).to contain_exactly(matching)
      end
    end

    context "with fuzzy matching" do
      it "matches album name with character sequence" do
        matching = create(:album, name: "High Hopes")
        _non_matching = create(:album, name: "Low Rider")

        # "hihps" matches H-i-g-h H-o-p-e-s
        result = search.call("hihps")

        expect(result).to contain_exactly(matching)
      end

      it "matches artist name with character sequence" do
        artist = create(:artist, name: "High Energy")
        matching = create(:album, name: "Some Album", artist: artist)
        _non_matching = create(:album, name: "Other Album")

        result = search.call("hihngy")

        expect(result).to contain_exactly(matching)
      end

      it "handles complex fuzzy patterns" do
        matching = create(:album, name: "The Dark Side of the Moon")

        result = search.call("drksde")

        expect(result).to contain_exactly(matching)
      end
    end

    context "matching either album or artist" do
      it "returns albums matching name OR artist" do
        artist_with_matching_name = create(:artist, name: "Thunder")
        album_by_name = create(:album, name: "Thunder Road")
        album_by_artist = create(:album, name: "Born to Run", artist: artist_with_matching_name)
        _non_matching = create(:album, name: "Other Album")

        result = search.call("Thunder")

        expect(result).to contain_exactly(album_by_name, album_by_artist)
      end
    end

    context "with special SQL characters" do
      it "escapes percent signs safely" do
        matching = create(:album, name: "100% Hits")

        result = search.call("100%")

        expect(result).to contain_exactly(matching)
      end

      it "escapes underscores safely" do
        matching = create(:album, name: "Under_score Album")

        result = search.call("Under_score")

        expect(result).to contain_exactly(matching)
      end
    end

    context "with custom scope" do
      it "respects the provided scope" do
        album1 = create(:album, name: "Matching One")
        _album2 = create(:album, name: "Matching Two")

        custom_scope = Album.where(id: album1.id)
        search_with_scope = described_class.new(custom_scope)

        result = search_with_scope.call("Matching")

        expect(result).to contain_exactly(album1)
      end
    end

    context "with no matches" do
      it "returns empty relation when no albums match" do
        create(:album, name: "Abbey Road")

        result = search.call("xyz123nonexistent")

        expect(result).to be_empty
      end
    end
  end
end
