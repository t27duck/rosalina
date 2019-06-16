# frozen_string_literal: true

module PingContainer
  extend Discordrb::Commands::CommandContainer

  command :ping, description: "Responds with 'Pong'", usage: "#{::BOT_PREFIX}ping" do |event|
    event.respond("Pong")
  end
end
