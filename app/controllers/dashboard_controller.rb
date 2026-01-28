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

    @upcoming_releases = Release.includes(:artists, album: { cover_attachment: :blob })
                                .where("released_at > ?", Date.current)
                                .order(released_at: :asc)
                                .limit(5)

    @past_releases = Release.includes(:artists, album: { cover_attachment: :blob })
                            .where("released_at <= ?", Date.current)
                            .order(released_at: :desc)
                            .limit(5)

    @recent_artists = Artist.includes(logo_attachment: :blob)
                            .order(created_at: :desc)
                            .limit(6)
  end
end
