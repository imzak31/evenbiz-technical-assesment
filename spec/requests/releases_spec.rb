# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Releases" do
  let(:user) { create(:user) }

  before do
    post login_path, params: { email: user.email, password: "password123" }
  end

  describe "GET /releases" do
    it "returns successful response" do
      get releases_path

      expect(response).to have_http_status(:ok)
    end

    it "renders the index template" do
      get releases_path

      expect(response.body).to include("Releases")
    end

    context "with existing releases" do
      before do
        artist = create(:artist)
        release = create(:release)
        create(:album, release: release)
        create(:artist_release, artist: artist, release: release)
      end

      it "displays releases" do
        get releases_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "with search query" do
      let(:artist) { create(:artist, name: "Search Artist") }
      let!(:matching_release) do
        release = create(:release, name: "Matching Album")
        create(:album, release: release)
        create(:artist_release, artist: artist, release: release)
        release
      end

      it "filters releases by search query" do
        get releases_path, params: { search: "Matching" }

        expect(response.body).to include("Matching")
      end
    end
  end

  describe "GET /releases/:id" do
    let(:release) do
      r = create(:release)
      create(:album, release: r)
      r
    end

    it "returns successful response" do
      get release_path(release)

      expect(response).to have_http_status(:ok)
    end

    it "displays release details" do
      get release_path(release)

      expect(response.body).to include(release.name)
    end
  end

  describe "GET /releases/new" do
    it "returns successful response" do
      get new_release_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /releases" do
    let(:artist) { create(:artist) }
    let(:valid_params) do
      {
        release: {
          name: "New Release",
          released_at: 1.week.from_now.to_date,
          artist_ids: [artist.id],
          album_attributes: {
            name: "New Album",
            duration_in_minutes: 45,
            artist_id: artist.id
          }
        }
      }
    end

    context "with valid parameters" do
      it "creates a new release" do
        expect {
          post releases_path, params: valid_params
        }.to change(Release, :count).by(1)
      end

      it "creates associated album" do
        expect {
          post releases_path, params: valid_params
        }.to change(Album, :count).by(1)
      end

      it "redirects to the created release" do
        post releases_path, params: valid_params

        expect(response).to redirect_to(release_path(Release.last))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { release: { name: "" } } }

      it "does not create a new release" do
        expect {
          post releases_path, params: invalid_params
        }.not_to change(Release, :count)
      end
    end
  end

  describe "GET /releases/:id/edit" do
    let(:release) do
      r = create(:release)
      create(:album, release: r)
      r
    end

    it "returns successful response" do
      get edit_release_path(release)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /releases/:id" do
    let(:release) do
      r = create(:release, name: "Old Name")
      create(:album, release: r)
      r
    end
    let(:valid_params) { { release: { name: "New Name" } } }

    context "with valid parameters" do
      it "updates the release" do
        patch release_path(release), params: valid_params

        expect(release.reload.name).to eq("New Name")
      end

      it "redirects to the release" do
        patch release_path(release), params: valid_params

        expect(response).to redirect_to(release_path(release))
      end
    end
  end

  describe "DELETE /releases/:id" do
    let!(:release) do
      r = create(:release)
      create(:album, release: r)
      r
    end

    it "deletes the release" do
      expect {
        delete release_path(release)
      }.to change(Release, :count).by(-1)
    end

    it "redirects to releases index" do
      delete release_path(release)

      expect(response).to redirect_to(releases_path)
    end
  end
end
