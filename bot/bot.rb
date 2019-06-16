# frozen_string_literal: true

raise "ROSALINA_BOT_TOKEN not set" unless ENV["ROSALINA_BOT_TOKEN"]

require "bundler"
Bundler.require(:default, :bot)

require_relative "includes/apixu"
require_relative "includes/pokedex"

prefix = "%"
bot = Discordrb::Commands::CommandBot.new(token: ENV["ROSALINA_BOT_TOKEN"], prefix: prefix)

bot.command(:ping, description: "Responds with 'Pong'", usage: "#{prefix}ping") do |event|
  event.respond("Pong")
end

description = "Enter a national dex id and get Pokemon info"
usage = "#{prefix}pokedex national_dex_id"
bot.command(:pokedex, description: description, usage: usage) do |event, national_dex_id|
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

if ENV["APIXU_KEY"]
  description = "Get current conditions powered by Apixu"
  usage = "#{prefix}weather Location|US Zip|CA Zip"
  bot.command(:weather, description: description, usage: usage) do |event, *args|
    location = Array(args).map { |a| a.to_s.strip }.join(" ")
    result = Apixu::CurrentConditions.new.fetch(location)
    if result[:error]
      event.respond(result[:error])
    else
      event.channel.send_embed do |embed|
        embed.title = "Currently in #{result[:location]}"
        embed.add_field(name: "Condition", value: result[:condition], inline: true)
        embed.add_field(name: "Temperature", value: result[:temperature], inline: true)
        embed.add_field(name: "Humiditiy", value: result[:humidity], inline: true)
        embed.add_field(name: "Wind", value: result[:wind], inline: true)
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: result[:icon])
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
          text: "Powered by Apixu.com", icon_url: "http://cdn.apixu.com/v4/images/logo.png"
        )
      end
    end
  end
end

bot.run
