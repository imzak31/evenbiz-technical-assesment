# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations" do
  describe "GET /signup" do
    it "returns http success" do
      get signup_path
      expect(response).to have_http_status(:success)
    end

    it "displays registration form" do
      get signup_path
      expect(response.body).to include("Create")
    end

    context "when already authenticated" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "redirects to root" do
        get signup_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /signup" do
    let(:valid_params) do
      {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "Test",
          last_name: "User",
        },
      }
    end

    context "with valid parameters" do
      it "creates a new user" do
        expect {
          post signup_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "redirects to root" do
        post signup_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it "signs in the new user" do
        post signup_path, params: valid_params
        # Follow redirect and verify we can access authenticated content
        follow_redirect!
        expect(response).to have_http_status(:success)
      end

      it "sets a flash notice" do
        post signup_path, params: valid_params
        expect(flash[:notice]).to eq("Welcome! Your account has been created.")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity for missing email" do
        post signup_path, params: { user: { email: "", password: "password123", password_confirmation: "password123" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns unprocessable entity for mismatched passwords" do
        post signup_path, params: { user: { email: "test@example.com", password: "password123", password_confirmation: "different" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns unprocessable entity for duplicate email" do
        create(:user, email: "existing@example.com")
        post signup_path, params: { user: { email: "existing@example.com", password: "password123", password_confirmation: "password123" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a user" do
        expect {
          post signup_path, params: { user: { email: "", password: "password123", password_confirmation: "password123" } }
        }.not_to change(User, :count)
      end

      it "re-renders the registration form" do
        post signup_path, params: { user: { email: "", password: "password123", password_confirmation: "password123" } }
        expect(response.body).to include("Create")
      end
    end
  end
end
