# frozen_string_literal: true

class CreateReleases < ActiveRecord::Migration[8.1]
  def change
    create_table :releases do |t|
      t.string :name, null: false, limit: 255
      t.datetime :released_at, null: false

      t.timestamps
    end

    add_index :releases, :released_at
  end
end
