# frozen_string_literal: true

class CreateArtistReleases < ActiveRecord::Migration[8.1]
  def change
    create_table :artist_releases do |t|
      t.references :artist, null: false, foreign_key: true
      t.references :release, null: false, foreign_key: true

      t.timestamps
    end

    add_index :artist_releases, [ :artist_id, :release_id ], unique: true
  end
end
