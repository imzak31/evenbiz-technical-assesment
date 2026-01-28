# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::Releases" do
  describe "GET /api/releases" do
    let(:user) { create(:user) }
    let(:headers) { { "Authorization" => "Bearer #{user.api_token}" } }

    context "without authentication" do
      it "returns 401 unauthorized" do
        get "/api/releases"

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        get "/api/releases"

        json = response.parsed_body
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

      it "returns JSON content type" do
        get "/api/releases", headers: headers

        expect(response.content_type).to include("application/json")
      end

      context "with successful response" do
        before do
          create_list(:release, 3)
          get "/api/releases", headers: headers
        end

        let(:json) { response.parsed_body }

        it "includes data array" do
          expect(json).to have_key("data")
          expect(json["data"]).to be_an(Array)
        end

        it "includes meta object" do
          expect(json).to have_key("meta")
          expect(json["meta"]).to be_a(Hash)
        end

        it "includes pagination in meta" do
          meta = json["meta"]
          expect(meta).to include(
            "current_page",
            "total_pages",
            "total_count",
            "per_page"
          )
        end
      end

      context "with release data" do
        let(:artist) { create(:artist) }
        let(:release) { create(:release, released_at: 1.day.ago) }
        let(:release_json) { response.parsed_body["data"].first }

        before do
          album = create(:album, release: release)
          create(:artist_release, artist: artist, release: release)
          get "/api/releases", headers: headers
        end


        it "includes required fields" do
          expect(release_json).to include(
            "id",
            "name",
            "album",
            "artists",
            "created_at",
            "released_at",
            "duration_in_minutes"
          )
        end

        it "includes album with name and cover_url" do
          expect(release_json["album"]).to include("name", "cover_url")
        end

        it "includes artists with id, name, and logo_url" do
          artist_json = release_json["artists"].first
          expect(artist_json).to include("id", "name", "logo_url")
        end

        it "formats timestamps as ISO8601" do
          expect(release_json["created_at"]).to match(/^\d{4}-\d{2}-\d{2}T/)
          expect(release_json["released_at"]).to match(/^\d{4}-\d{2}-\d{2}T/)
        end
      end
    end

    describe "filtering" do
      let!(:past_release) { create(:release, released_at: 1.day.ago) }
      let!(:future_release) { create(:release, released_at: 1.day.from_now) }

      context "with past=1" do
        it "returns only past releases" do
          get "/api/releases", params: { past: "1" }, headers: headers

          ids = response.parsed_body["data"].pluck("id")
          expect(ids).to include(past_release.id)
          expect(ids).not_to include(future_release.id)
        end
      end

      context "with past=0" do
        it "returns only upcoming releases" do
          get "/api/releases", params: { past: "0" }, headers: headers

          ids = response.parsed_body["data"].pluck("id")
          expect(ids).to include(future_release.id)
          expect(ids).not_to include(past_release.id)
        end
      end

      context "without past param" do
        it "returns all releases" do
          get "/api/releases", headers: headers

          ids = response.parsed_body["data"].pluck("id")
          expect(ids).to include(past_release.id, future_release.id)
        end
      end
    end

    describe "pagination" do
      before { create_list(:release, 15) }

      context "with default pagination" do
        before { get "/api/releases", headers: headers }

        it "returns 10 releases by default" do
          expect(response.parsed_body["data"].count).to eq(10)
        end

        it "includes correct pagination meta" do
          meta = response.parsed_body["meta"]
          expect(meta["current_page"]).to eq(1)
          expect(meta["total_count"]).to eq(15)
          expect(meta["per_page"]).to eq(10)
        end
      end

      context "with limit param" do
        before { get "/api/releases", params: { limit: 5 }, headers: headers }

        it "respects limit" do
          expect(response.parsed_body["data"].count).to eq(5)
        end
      end

      context "with page param" do
        before { get "/api/releases", params: { page: 2 }, headers: headers }

        it "returns second page" do
          meta = response.parsed_body["meta"]
          expect(meta["current_page"]).to eq(2)
          expect(response.parsed_body["data"].count).to eq(5)
        end
      end

      context "with excessive limit" do
        before { get "/api/releases", params: { limit: 500 }, headers: headers }

        it "caps at max per page" do
          meta = response.parsed_body["meta"]
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

        ids = response.parsed_body["data"].pluck("id")
        expect(ids).to eq([ newer.id, older.id ])
      end
    end
  end
end
