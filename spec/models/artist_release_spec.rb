# frozen_string_literal: true

require "rails_helper"

RSpec.describe ArtistRelease do
  describe "associations" do
    it { is_expected.to belong_to(:artist) }
    it { is_expected.to belong_to(:release) }
  end

  describe "join behavior" do
    let(:artist) { create(:artist) }
    let(:release) { create(:release) }

    it "links an artist to a release" do
      artist_release = create(:artist_release, artist: artist, release: release)

      expect(artist.releases).to include(release)
      expect(release.artists).to include(artist)
    end
  end
end
