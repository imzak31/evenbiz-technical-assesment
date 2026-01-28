# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard" do
  let(:user) { create(:user) }

  describe "GET /" do
    context "when authenticated" do
      before { sign_in user }

      it "returns http success" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      context "with data" do
        let(:artist) { create(:artist) }
        let(:release) { create(:release) }
        let(:album) { create(:album, release: release, artist: artist) }

        it "loads successfully with artists, releases, and albums" do
          # Create the data through the album (which requires artist and release)
          album

          get root_path
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get root_path
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
