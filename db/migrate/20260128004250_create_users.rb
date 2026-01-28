# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, limit: 255
      t.string :password_digest, null: false
      t.string :api_token, null: false, limit: 64
      t.string :first_name, null: false, limit: 100
      t.string :last_name, null: false, limit: 100
      t.string :profile_picture_url, limit: 2048

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :api_token, unique: true
  end
end
