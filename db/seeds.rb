# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Clear existing data in correct order (respecting foreign keys)
ArtistRelease.destroy_all
Album.destroy_all
Release.destroy_all
Artist.destroy_all

puts "  ✓ Cleared existing data"

# Create 25 artists with unique names
artists = 25.times.map do |i|
  Artist.create!(name: "#{Faker::Music.band} #{Faker::Music.genre} #{i + 1}")
end

puts "  ✓ Created #{artists.count} artists"

# Create 100 releases with a mix of past and upcoming dates
releases = 100.times.map do |i|
  release_date = if i < 70
                   # 70% past releases
                   Faker::Time.between(from: 2.years.ago, to: 1.day.ago)
  else
                   # 30% upcoming releases
                   Faker::Time.between(from: 1.day.from_now, to: 1.year.from_now)
  end

  Release.create!(
    name: "#{Faker::Music.album} #{i + 1}",
    released_at: release_date,
  )
end

puts "  ✓ Created #{releases.count} releases"

# Create albums (one per release)
albums = releases.map do |release|
  primary_artist = artists.sample

  Album.create!(
    name: "#{release.name} - #{[ "Single", "EP", "Album", "Deluxe Edition" ].sample}",
    duration_in_minutes: Faker::Number.between(from: 3, to: 75),
    release: release,
    artist: primary_artist,
  )
end

puts "  ✓ Created #{albums.count} albums"

# Create artist_releases (primary artist + featured artists for collaborations)
artist_releases_count = 0

releases.each_with_index do |release, index|
  primary_artist = release.album.artist

  # Always add the primary artist
  ArtistRelease.create!(artist: primary_artist, release: release)
  artist_releases_count += 1

  # 40% of releases have featured artists (collaborations)
  next unless index % 5 < 2

  # Add 1-3 featured artists (different from primary)
  featured_count = Faker::Number.between(from: 1, to: 3)
  featured_artists = artists.reject { |a| a == primary_artist }.sample(featured_count)

  featured_artists.each do |featured_artist|
    ArtistRelease.create!(artist: featured_artist, release: release)
    artist_releases_count += 1
  end
end

puts "  ✓ Created #{artist_releases_count} artist-release associations"

puts "🎵 Seeding complete!"
puts "   Summary:"
puts "   - #{Artist.count} artists"
puts "   - #{Release.count} releases (#{Release.past.count} past, #{Release.upcoming.count} upcoming)"
puts "   - #{Album.count} albums"
puts "   - #{ArtistRelease.count} artist-release associations"
