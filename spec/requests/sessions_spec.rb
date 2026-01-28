# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions" do
  let(:user) { create(:user, password: "password123") }

  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end

    it "displays login form" do
      get login_path
      expect(response.body).to include("Sign in")
    end

    context "when already authenticated" do
      before { sign_in user }

      it "redirects to root" do
        get login_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /login" do
    context "with valid credentials" do
      it "creates a session" do
        post login_path, params: { email: user.email, password: "password123" }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid credentials" do
      it "returns unprocessable entity for wrong password" do
        post login_path, params: { email: user.email, password: "wrongpassword" }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns unprocessable entity for non-existent email" do
        post login_path, params: { email: "nonexistent@example.com", password: "password123" }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "re-renders the login form" do
        post login_path, params: { email: user.email, password: "wrongpassword" }
        expect(response.body).to include("Sign in")
      end
    end
  end

  describe "DELETE /logout" do
    before { sign_in user }

    it "destroys the session" do
      delete logout_path
      expect(response).to redirect_to(login_path)
    end

    it "sets a flash notice" do
      delete logout_path
      expect(flash[:notice]).to eq("You have been logged out.")
    end
  end
end
