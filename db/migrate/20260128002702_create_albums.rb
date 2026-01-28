# frozen_string_literal: true

class CreateAlbums < ActiveRecord::Migration[8.1]
  def change
    create_table :albums do |t|
      t.string :name, null: false, limit: 255
      t.integer :duration_in_minutes, null: false
      t.references :release, null: false, foreign_key: true, index: { unique: true }
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
