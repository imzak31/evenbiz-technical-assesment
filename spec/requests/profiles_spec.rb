# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Profiles" do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /profile" do
    it "returns http success" do
      get profile_path
      expect(response).to have_http_status(:success)
    end

    it "displays user email" do
      get profile_path
      expect(response.body).to include(user.email)
    end
  end

  describe "GET /profile/edit" do
    it "returns http success" do
      get edit_profile_path
      expect(response).to have_http_status(:success)
    end

    it "displays profile form" do
      get edit_profile_path
      expect(response.body).to include("Edit Profile")
    end
  end

  describe "PATCH /profile" do
    context "with valid parameters" do
      it "updates user email" do
        patch profile_path, params: { user: { email: "new@example.com" } }
        expect(user.reload.email).to eq("new@example.com")
      end

      it "updates user first name" do
        patch profile_path, params: { user: { first_name: "NewFirst" } }
        expect(user.reload.first_name).to eq("NewFirst")
      end

      it "updates user last name" do
        patch profile_path, params: { user: { last_name: "NewLast" } }
        expect(user.reload.last_name).to eq("NewLast")
      end

      it "redirects to profile show" do
        patch profile_path, params: { user: { email: "new@example.com" } }
        expect(response).to redirect_to(profile_path)
      end

      it "sets a flash notice" do
        patch profile_path, params: { user: { email: "new@example.com" } }
        expect(flash[:notice]).to eq("Profile was successfully updated.")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity for invalid email" do
        patch profile_path, params: { user: { email: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "re-renders the edit template" do
        patch profile_path, params: { user: { email: "" } }
        expect(response.body).to include("Edit Profile")
      end
    end
  end

  context "when not authenticated" do
    before { sign_out }

    it "redirects GET /profile to login" do
      get profile_path
      expect(response).to redirect_to(login_path)
    end

    it "redirects GET /profile/edit to login" do
      get edit_profile_path
      expect(response).to redirect_to(login_path)
    end

    it "redirects PATCH /profile to login" do
      patch profile_path, params: { user: { email: "new@example.com" } }
      expect(response).to redirect_to(login_path)
    end
  end
end
