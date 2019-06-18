# frozen_string_literal: true

class EmojiMap
  FILE_PATH = Rails.root.join("config", "emoji_map.yml")
  def self.map
    @map ||= File.exist?(FILE_PATH) ? (YAML.load_file(FILE_PATH) || {}) : {}
  end
end
