# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Albums" do
  let(:user) { create(:user) }

  before do
    post login_path, params: { email: user.email, password: "password123" }
  end

  describe "GET /albums" do
    it "returns successful response" do
      get albums_path

      expect(response).to have_http_status(:ok)
    end

    it "renders the index template" do
      get albums_path

      expect(response.body).to include("Albums")
    end

    context "with existing albums" do
      before { create_list(:album, 3) }

      it "displays albums" do
        get albums_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "with search query" do
      before do
        create(:album, name: "Thriller")
        create(:album, name: "Abbey Road")
      end

      it "filters albums by search query" do
        get albums_path, params: { search: "Thriller" }

        expect(response.body).to include("Thriller")
      end
    end
  end

  describe "GET /albums/:id" do
    let(:album) { create(:album) }

    it "returns successful response" do
      get album_path(album)

      expect(response).to have_http_status(:ok)
    end

    it "displays album details" do
      get album_path(album)

      expect(response.body).to include(album.name)
    end
  end

  describe "GET /albums/new" do
    it "returns successful response" do
      get new_album_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /albums" do
    context "with valid parameters" do
      it "creates a new album" do
        artist = create(:artist)
        release = create(:release)
        valid_params = {
          album: {
            name: "New Album",
            duration_in_minutes: 45,
            artist_id: artist.id,
            release_id: release.id,
          },
        }

        expect {
          post albums_path, params: valid_params
        }.to change(Album, :count).by(1)
      end

      it "redirects to the created album" do
        artist = create(:artist)
        release = create(:release)
        valid_params = {
          album: {
            name: "New Album",
            duration_in_minutes: 45,
            artist_id: artist.id,
            release_id: release.id,
          },
        }

        post albums_path, params: valid_params

        expect(response).to redirect_to(album_path(Album.last))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { album: { name: "" } } }

      it "does not create a new album" do
        expect {
          post albums_path, params: invalid_params
        }.not_to change(Album, :count)
      end

      it "returns unprocessable entity status" do
        post albums_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /albums/:id/edit" do
    let(:album) { create(:album) }

    it "returns successful response" do
      get edit_album_path(album)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /albums/:id" do
    let(:album) { create(:album, name: "Old Name") }
    let(:valid_params) { { album: { name: "New Name" } } }

    context "with valid parameters" do
      it "updates the album" do
        patch album_path(album), params: valid_params

        expect(album.reload.name).to eq("New Name")
      end

      it "redirects to the album" do
        patch album_path(album), params: valid_params

        expect(response).to redirect_to(album_path(album))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { album: { name: "" } } }

      it "does not update the album" do
        patch album_path(album), params: invalid_params

        expect(album.reload.name).to eq("Old Name")
      end

      it "returns unprocessable entity status" do
        patch album_path(album), params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /albums/:id" do
    let!(:album) { create(:album) }

    it "deletes the album" do
      expect {
        delete album_path(album)
      }.to change(Album, :count).by(-1)
    end

    it "redirects to albums index" do
      delete album_path(album)

      expect(response).to redirect_to(albums_path)
    end
  end

  describe "authentication" do
    before do
      delete logout_path
    end

    it "redirects to login when not authenticated" do
      get albums_path

      expect(response).to redirect_to(login_path)
    end
  end
end
