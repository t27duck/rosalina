# frozen_string_literal: true

class CoinFlip
  BEGINNINGS = ['You got', 'It landed on'].freeze
  RESULTS = ['heads', 'tails'].freeze
  EMOJI = ['rowlet', 'tails']

  def self.flip
    beginning = BEGINNINGS.sample
    number = rand(2)
    ":coin: #{beginning} #{RESULTS[number]}. #{EmojiMap.map[EMOJI[number]]}"
  end
end
