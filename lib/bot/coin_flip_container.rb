# frozen_string_literal: true

require "bot/coin_flip"

module CoinFlipContainer
  extend Discordrb::Commands::CommandContainer

  command :'8ball',
          description: "Flip a coin, make a decision.",
          usage: "%flip" do |event, *args|

    event.respond(CoinFlip.flip)
  end
end
