# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ApiExplorer" do
  let(:user) { create(:user) }

  before do
    # Allow localhost connections for API Explorer (it makes HTTP calls to itself)
    WebMock.allow_net_connect!
    post login_path, params: { email: user.email, password: "password123" }
  end

  after do
    # Reset WebMock to default behavior
    WebMock.disable_net_connect!
  end

  describe "POST /api_explorer/execute" do
    context "when requesting artists endpoint" do
      before { create_list(:artist, 5) }

      it "returns successful response" do
        post api_explorer_execute_path, params: { endpoint: "/v1/artists" }

        expect(response).to have_http_status(:ok)
      end

      it "returns JSON response" do
        post api_explorer_execute_path, params: { endpoint: "/v1/artists" }

        json = JSON.parse(response.body)
        expect(json).to have_key("status")
        expect(json).to have_key("body")
      end

      it "includes request duration" do
        post api_explorer_execute_path, params: { endpoint: "/v1/artists" }

        json = JSON.parse(response.body)
        expect(json).to have_key("duration")
      end

      it "passes pagination parameters" do
        post api_explorer_execute_path, params: {
          endpoint: "/v1/artists",
          page: "2",
          per_page: "3",
        }

        expect(response).to have_http_status(:ok)
      end

      it "passes search parameters" do
        post api_explorer_execute_path, params: {
          endpoint: "/v1/artists",
          search: "test",
        }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when requesting releases endpoint" do
      before do
        artist = create(:artist)
        release = create(:release)
        create(:album, release: release)
        create(:artist_release, artist: artist, release: release)
      end

      it "returns successful response" do
        post api_explorer_execute_path, params: { endpoint: "/v1/releases" }

        expect(response).to have_http_status(:ok)
      end

      it "supports past filter" do
        post api_explorer_execute_path, params: {
          endpoint: "/v1/releases",
          past: "true",
        }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when requesting albums endpoint" do
      before { create_list(:album, 3) }

      it "returns successful response" do
        post api_explorer_execute_path, params: { endpoint: "/v1/albums" }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when endpoint is missing" do
      it "returns a response" do
        post api_explorer_execute_path, params: {}

        # When endpoint is empty, the HTTP client makes a request and returns a response
        json = JSON.parse(response.body)
        expect(json).to have_key("status")
        expect(json).to have_key("body")
      end
    end

    context "when endpoint is invalid" do
      it "handles the error gracefully" do
        post api_explorer_execute_path, params: { endpoint: "/v1/nonexistent" }

        json = JSON.parse(response.body)
        expect(json).to have_key("status")
      end
    end

    context "when user is not authenticated" do
      before { delete logout_path }

      it "redirects to login" do
        post api_explorer_execute_path, params: { endpoint: "/v1/artists" }

        expect(response).to redirect_to(login_path)
      end
    end
  end
end
