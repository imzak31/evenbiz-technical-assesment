# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Artists" do
  let(:user) { create(:user) }

  before do
    # Simulate logged in user for session-based auth
    post login_path, params: { email: user.email, password: "password123" }
  end

  describe "GET /artists" do
    it "returns successful response" do
      get artists_path

      expect(response).to have_http_status(:ok)
    end

    it "renders the index template" do
      get artists_path

      expect(response.body).to include("Artists")
    end

    context "with existing artists" do
      before { create_list(:artist, 3) }

      it "displays artists" do
        get artists_path

        expect(response.body).to include("artist")
      end
    end

    context "with search query" do
      let!(:matching_artist) { create(:artist, name: "The Beatles") }
      let!(:non_matching_artist) { create(:artist, name: "Pink Floyd") }

      it "filters artists by search query" do
        get artists_path, params: { search: "Beatles" }

        expect(response.body).to include("Beatles")
      end
    end
  end

  describe "GET /artists/:id" do
    let(:artist) { create(:artist) }

    it "returns successful response" do
      get artist_path(artist)

      expect(response).to have_http_status(:ok)
    end

    it "displays artist details" do
      get artist_path(artist)

      expect(response.body).to include(artist.name)
    end
  end

  describe "GET /artists/new" do
    it "returns successful response" do
      get new_artist_path

      expect(response).to have_http_status(:ok)
    end

    it "renders new form" do
      get new_artist_path

      expect(response.body).to include("form")
    end
  end

  describe "POST /artists" do
    let(:valid_params) { { artist: { name: "New Artist" } } }
    let(:invalid_params) { { artist: { name: "" } } }

    context "with valid parameters" do
      it "creates a new artist" do
        expect {
          post artists_path, params: valid_params
        }.to change(Artist, :count).by(1)
      end

      it "redirects to the created artist" do
        post artists_path, params: valid_params

        expect(response).to redirect_to(artist_path(Artist.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new artist" do
        expect {
          post artists_path, params: invalid_params
        }.not_to change(Artist, :count)
      end

      it "returns unprocessable entity status" do
        post artists_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /artists/:id/edit" do
    let(:artist) { create(:artist) }

    it "returns successful response" do
      get edit_artist_path(artist)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /artists/:id" do
    let(:artist) { create(:artist, name: "Old Name") }
    let(:valid_params) { { artist: { name: "New Name" } } }

    context "with valid parameters" do
      it "updates the artist" do
        patch artist_path(artist), params: valid_params

        expect(artist.reload.name).to eq("New Name")
      end

      it "redirects to the artist" do
        patch artist_path(artist), params: valid_params

        expect(response).to redirect_to(artist_path(artist))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { artist: { name: "" } } }

      it "does not update the artist" do
        patch artist_path(artist), params: invalid_params

        expect(artist.reload.name).to eq("Old Name")
      end

      it "returns unprocessable entity status" do
        patch artist_path(artist), params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /artists/:id" do
    let!(:artist) { create(:artist) }

    it "deletes the artist" do
      expect {
        delete artist_path(artist)
      }.to change(Artist, :count).by(-1)
    end

    it "redirects to artists index" do
      delete artist_path(artist)

      expect(response).to redirect_to(artists_path)
    end
  end

  describe "authentication" do
    before do
      delete logout_path # Log out the user
    end

    it "redirects to login when not authenticated" do
      get artists_path

      expect(response).to redirect_to(login_path)
    end
  end
end
