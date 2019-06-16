# frozen_string_literal: true

module PingContainer
  extend Discordrb::Commands::CommandContainer

  command :ping, description: "Responds with 'Pong'", usage: "%ping" do |event|
    event.respond("Pong")
  end
end
