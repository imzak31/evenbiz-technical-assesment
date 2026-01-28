# frozen_string_literal: true

require "open-uri"

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Clear existing data in correct order (respecting foreign keys)
ActiveStorage::Attachment.destroy_all
ArtistRelease.destroy_all
Album.destroy_all
Release.destroy_all
Artist.destroy_all
User.destroy_all

puts "  ✓ Cleared existing data"

# Helper to attach images from URLs
def attach_image(record, attachment_name, url, filename)
  record.public_send(attachment_name).attach(
    io: URI.parse(url).open,
    filename: filename,
    content_type: "image/jpeg",
  )
rescue OpenURI::HTTPError, SocketError => e
  puts "    ⚠ Could not attach #{filename}: #{e.message}"
end

# Create test user with known API token for development
test_user = User.create!(
  email: "admin@evenbiz.test",
  first_name: "Admin",
  last_name: "User",
  password: "password123",
  password_confirmation: "password123",
)

# Attach avatar to test user
attach_image(test_user, :avatar, "https://i.pravatar.cc/300?u=admin", "admin_avatar.jpg")

puts "  ✓ Created test user: #{test_user.full_name} (#{test_user.email})"
puts "    API Token: #{test_user.api_token}"

# Create 25 artists with unique names and logos
artists = 25.times.map do |i|
  artist = Artist.create!(name: "#{Faker::Music.band} #{Faker::Music.genre} #{i + 1}")

  # Attach logo using picsum for variety
  attach_image(artist, :logo, "https://picsum.photos/seed/artist#{i}/400/400", "artist_#{i}_logo.jpg")

  artist
end

puts "  ✓ Created #{artists.count} artists with logos"

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

# Create albums (one per release) with covers
albums = releases.each_with_index.map do |release, i|
  primary_artist = artists.sample

  album = Album.create!(
    name: "#{release.name} - #{[ "Single", "EP", "Album", "Deluxe Edition" ].sample}",
    duration_in_minutes: Faker::Number.between(from: 3, to: 75),
    release: release,
    artist: primary_artist,
  )

  # Attach album cover
  attach_image(album, :cover, "https://picsum.photos/seed/album#{i}/600/600", "album_#{i}_cover.jpg")

  album
end

puts "  ✓ Created #{albums.count} albums with covers"

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
puts "   - #{User.count} users (with avatars)"
puts "   - #{Artist.count} artists (with logos)"
puts "   - #{Release.count} releases (#{Release.past.count} past, #{Release.upcoming.count} upcoming)"
puts "   - #{Album.count} albums (with covers)"
puts "   - #{ArtistRelease.count} artist-release associations"
puts "   - #{ActiveStorage::Attachment.count} attachments"
