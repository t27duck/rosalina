# frozen_string_literal: true

class CreateCodeLists < ActiveRecord::Migration[6.0]
  def change
    create_table :code_lists, id: false do |t|
      t.string :discord_id, null: false, primary_key: true
      t.boolean :public, null: false, default: false
      t.jsonb :system_codes, null: false, default: {}

      t.timestamps
    end
  end
end
