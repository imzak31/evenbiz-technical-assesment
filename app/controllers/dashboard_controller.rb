# frozen_string_literal: true

# Dashboard controller - home page after login
class DashboardController < ApplicationController
  def show
    @stats = {
      artists: Artist.count,
      releases: Release.count,
      albums: Album.count,
      users: User.count,
    }
    @recent_releases = Release.for_index.limit(5)
  end
end
