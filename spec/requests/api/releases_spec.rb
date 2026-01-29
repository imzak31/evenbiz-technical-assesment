# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::Releases" do
  describe "GET /api/releases" do
    let(:user) { create(:user) }
    let(:headers) { { "Authorization" => "Bearer #{user.api_token}" } }

    # Helper to parse JSON:API responses (content-type: application/vnd.api+json)
    def json_response
      JSON.parse(response.body)
    end

    context "without authentication" do
      it "returns 401 unauthorized" do
        get "/api/releases"

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        get "/api/releases"

        json = json_response
        expect(json["error"]).to eq("Unauthorized")
      end
    end

    context "with invalid token" do
      let(:headers) { { "Authorization" => "Bearer invalid_token" } }

      it "returns 401 unauthorized" do
        get "/api/releases", headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid authentication" do
      it "returns 200 success" do
        get "/api/releases", headers: headers

        expect(response).to have_http_status(:ok)
      end

      it "returns JSON:API content type" do
        get "/api/releases", headers: headers

        expect(response.content_type).to include("application/vnd.api+json")
      end

      context "with successful response structure" do
        before do
          create_list(:release, 3)
          get "/api/releases", headers: headers
        end

        let(:json) { json_response }

        it "includes data array" do
          expect(json).to have_key("data")
          expect(json["data"]).to be_an(Array)
        end

        it "includes links object with pagination URLs" do
          expect(json).to have_key("links")
          expect(json["links"]).to include("self", "first", "last")
        end

        it "includes meta object with pagination" do
          expect(json).to have_key("meta")
          expect(json["meta"]).to include(
            "current_page",
            "total_pages",
            "total_count",
            "per_page"
          )
        end

        it "includes 'included' array with related resources" do
          expect(json).to have_key("included")
          expect(json["included"]).to be_an(Array)
        end
      end

      context "with release data in JSON:API format" do
        let(:artist) { create(:artist, name: "Test Artist") }
        let(:release) { create(:release, name: "Test Release", released_at: 1.day.ago) }
        let(:release_data) { json_response["data"].first }

        before do
          create(:album, name: "Test Album", release: release, artist: artist)
          create(:artist_release, artist: artist, release: release)
          get "/api/releases", headers: headers
        end

        it "includes type and id" do
          expect(release_data["type"]).to eq("releases")
          expect(release_data["id"]).to eq(release.id.to_s)
        end

        it "includes attributes object" do
          expect(release_data).to have_key("attributes")
          attrs = release_data["attributes"]
          expect(attrs).to include("name", "created_at", "released_at", "duration_in_minutes")
        end

        it "includes relationships object" do
          expect(release_data).to have_key("relationships")
          relationships = release_data["relationships"]
          expect(relationships).to include("album", "artists")
        end

        it "has album relationship with data reference" do
          album_rel = release_data["relationships"]["album"]
          expect(album_rel).to have_key("data")
          expect(album_rel["data"]["type"]).to eq("albums")
          expect(album_rel["data"]["id"]).to be_present
        end

        it "has artists relationship with data array" do
          artists_rel = release_data["relationships"]["artists"]
          expect(artists_rel).to have_key("data")
          expect(artists_rel["data"]).to be_an(Array)
          expect(artists_rel["data"].first["type"]).to eq("artists")
        end

        it "includes self link" do
          expect(release_data).to have_key("links")
          expect(release_data["links"]["self"]).to eq("/api/releases/#{release.id}")
        end

        it "formats timestamps as ISO8601" do
          attrs = release_data["attributes"]
          expect(attrs["created_at"]).to match(/^\d{4}-\d{2}-\d{2}T/)
          expect(attrs["released_at"]).to match(/^\d{4}-\d{2}-\d{2}T/)
        end
      end

      context "with included resources" do
        let(:artist) { create(:artist, name: "Included Artist") }
        let(:included) { json_response["included"] }
        let(:release) { create(:release, released_at: 1.day.ago) }

        before do
          create(:album, name: "Included Album", release: release, artist: artist)
          create(:artist_release, artist: artist, release: release)
          get "/api/releases", headers: headers
        end

        it "includes album resources" do
          albums = included.select { |r| r["type"] == "albums" }
          expect(albums).not_to be_empty
          expect(albums.first["attributes"]).to include("name", "cover_url", "duration_in_minutes")
        end

        it "includes artist resources" do
          artists = included.select { |r| r["type"] == "artists" }
          expect(artists).not_to be_empty
          expect(artists.first["attributes"]).to include("name", "logo_url")
        end

        it "includes self links on included resources" do
          included.each do |resource|
            expect(resource).to have_key("links")
            expect(resource["links"]["self"]).to be_present
          end
        end
      end
    end

    describe "filtering" do
      let!(:past_release) { create(:release, released_at: 1.day.ago) }
      let!(:future_release) { create(:release, released_at: 1.day.from_now) }

      context "with past=1" do
        it "returns only past releases" do
          get "/api/releases", params: { past: "1" }, headers: headers

          ids = json_response["data"].pluck("id")
          expect(ids).to include(past_release.id.to_s)
          expect(ids).not_to include(future_release.id.to_s)
        end
      end

      context "with past=0" do
        it "returns only upcoming releases" do
          get "/api/releases", params: { past: "0" }, headers: headers

          ids = json_response["data"].pluck("id")
          expect(ids).to include(future_release.id.to_s)
          expect(ids).not_to include(past_release.id.to_s)
        end
      end

      context "without past param" do
        it "returns all releases" do
          get "/api/releases", headers: headers

          ids = json_response["data"].pluck("id")
          expect(ids).to include(past_release.id.to_s, future_release.id.to_s)
        end
      end
    end

    describe "pagination" do
      before { create_list(:release, 15) }

      context "with default pagination" do
        before { get "/api/releases", headers: headers }

        it "returns 10 releases by default" do
          expect(json_response["data"].count).to eq(10)
        end

        it "includes correct pagination meta" do
          meta = json_response["meta"]
          expect(meta["current_page"]).to eq(1)
          expect(meta["total_count"]).to eq(15)
          expect(meta["per_page"]).to eq(10)
        end

        it "includes pagination links" do
          links = json_response["links"]
          expect(links["self"]).to include("page=1")
          expect(links["first"]).to include("page=1")
          expect(links["last"]).to include("page=2")
          expect(links["next"]).to include("page=2")
          expect(links).not_to have_key("prev")
        end
      end

      context "with limit param" do
        before { get "/api/releases", params: { limit: 5 }, headers: headers }

        it "respects limit" do
          expect(json_response["data"].count).to eq(5)
        end

        it "preserves limit param in pagination links" do
          links = json_response["links"]
          expect(links["self"]).to include("limit=5")
          expect(links["next"]).to include("limit=5")
        end
      end

      context "with page param" do
        before { get "/api/releases", params: { page: 2 }, headers: headers }

        it "returns second page" do
          meta = json_response["meta"]
          expect(meta["current_page"]).to eq(2)
          expect(json_response["data"].count).to eq(5)
        end

        it "includes prev link on second page" do
          links = json_response["links"]
          expect(links["prev"]).to include("page=1")
          expect(links).not_to have_key("next")
        end
      end

      context "with excessive limit" do
        before { get "/api/releases", params: { limit: 500 }, headers: headers }

        it "caps at max per page" do
          meta = json_response["meta"]
          expect(meta["per_page"]).to eq(100)
        end
      end
    end

    describe "param sanitization" do
      it "ignores unpermitted params" do
        expect {
          get "/api/releases", params: { malicious: "data", sql: "injection" }, headers: headers
        }.not_to raise_error

        expect(response).to have_http_status(:ok)
      end
    end

    describe "ordering" do
      let!(:older) { create(:release, name: "Older", released_at: 2.days.ago) }
      let!(:newer) { create(:release, name: "Newer", released_at: 1.day.ago) }

      it "returns releases ordered by released_at desc" do
        get "/api/releases", headers: headers

        ids = json_response["data"].pluck("id")
        expect(ids).to eq([ newer.id.to_s, older.id.to_s ])
      end
    end

    describe "edge cases" do
      context "with empty results" do
        before { get "/api/releases", headers: headers }

        it "returns empty data array" do
          expect(json_response["data"]).to eq([])
        end

        it "returns zero in pagination meta" do
          meta = json_response["meta"]
          expect(meta["total_count"]).to eq(0)
          expect(meta["total_pages"]).to eq(0)
        end

        it "still includes links object" do
          expect(json_response).to have_key("links")
        end
      end

      context "with release missing album" do
        before do
          create(:release, released_at: 1.day.ago)  # No album
          get "/api/releases", headers: headers
        end

        it "handles nil album gracefully" do
          release_data = json_response["data"].first
          expect(release_data["relationships"]["album"]["data"]).to be_nil
        end
      end

      context "with release missing artists" do
        before do
          release = create(:release, released_at: 1.day.ago)
          create(:album, release: release)
          # No artists associated
          get "/api/releases", headers: headers
        end

        it "handles empty artists gracefully" do
          release_data = json_response["data"].first
          expect(release_data["relationships"]["artists"]["data"]).to eq([])
        end
      end
    end
  end
end
