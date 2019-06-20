# frozen_string_literal: true

class RedoPostedEntries < ActiveRecord::Migration[6.0]
  def up
    drop_table :posted_entries
    create_table :posted_entries do |t|
      t.string :key, null: false
      t.string :slug, null: false
      t.string :url, null: false

      t.timestamps
    end
    add_index :posted_entries, %i[key slug], unique: true
  end

  def down
    drop_table :posted_entries
    create_table :posted_entries, id: false do |t|
      t.string :slug, null: false, primary_key: true
      t.string :url, null: false

      t.timestamps
    end
  end
end
