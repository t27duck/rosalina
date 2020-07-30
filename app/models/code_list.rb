# frozen_string_literal: true

class CodeList < ApplicationRecord
  self.primary_key = :discord_id

  SYSTEM_CODE_MAP = {
    "wii" => { label: "Wii", emoji: "wii" },
    "switch" => { label: "Switch", emoji: "switch" },
    "3ds" => { label: "3DS", emoji: "3ds" },
    "xbl" => { label: "XBL", emoji: "xbox" },
    "psn" => { label: "PSN", emoji: "playstation" },
    "steam" => { label: "Steam", emoji: "steam" },
    "nnid" => { label: "NNID" },
    "mm2" => { label: "MM2 Maker ID", emoji: "Mario" },
    "nhda" => { label: "ACNH Dream Address", emoji: "dreamisland" }
  }.freeze

  validates :discord_id, presence: true

  def system_code_display
    SYSTEM_CODE_MAP.map do |key, settings|
      next if system_codes[key].blank?

      emoji = "#{EmojiMap.map[settings[:emoji]]} " if settings[:emoji]
      label = settings[:label]
      code = system_codes[key]

      "#{emoji}**#{label}**: #{code}"
    end.compact.join("\n").strip.presence
  end
end
