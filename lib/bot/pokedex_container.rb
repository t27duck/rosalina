# frozen_string_literal: true

require "bot/pokedex"

module PokedexContainer
  extend Discordrb::Commands::CommandContainer

  command :pokedex,
          description: "Enter a national dex id or name and get Pokemon info",
          usage: "%pokedex national_dex_id|name" do |event, national_dex_id|
    result = Pokedex.lookup(national_dex_id)
    if result[:error]
      event.respond(result[:error])
    else
      event.channel.send_embed do |embed|
        embed.title = "#{result[:name]} [#{result[:national_dex]}]"
        embed.add_field(name: "Species", value: "The #{result[:species]}", inline: true)
        embed.add_field(name: "Type", value: result[:types], inline: true)
        embed.description = result[:description]
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: result[:image_url])
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Data from pokeapi.co")
      end
    end
  end
end
