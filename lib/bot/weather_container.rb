# frozen_string_literal: true

require "bot/weatherstack"

module WeatherContainer
  extend Discordrb::Commands::CommandContainer

  command :weather,
          description: "Get current conditions powered by weatherstack.com",
          usage: "%weather Location|US Zip|CA Zip" do |event, *args|
    location = Array(args).map { |a| a.to_s.strip }.join(" ")
    result = Weatherstack::CurrentConditions.new.fetch(location)
    if result[:error]
      event.respond(result[:error])
    else
      event.channel.send_embed do |embed|
        embed.title = "Currently in #{result[:location]}"
        embed.add_field(name: "Condition", value: result[:condition], inline: true)
        embed.add_field(name: "Temperature", value: result[:temperature], inline: true)
        embed.add_field(name: "Humidity", value: result[:humidity], inline: true)
        embed.add_field(name: "Wind", value: result[:wind], inline: true)
        embed.add_field(name: "Pressure", value: result[:pressure], inline: true)
        embed.add_field(name: "UV Index", value: result[:uv_index], inline: true)
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: result[:icon])
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
          text: "Powered by weatherstack.com"
        )
      end
    end
  end
end
