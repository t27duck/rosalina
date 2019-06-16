# frozen_string_literal: true

class CreatePostedEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :posted_entries, id: false do |t|
      t.string :slug, null: false, primary_key: true
      t.string :url, null: false

      t.timestamps
    end
  end
end
