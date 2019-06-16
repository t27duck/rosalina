# frozen_string_literal: true

require "bot/apixu"

module WeatherContainer
  extend Discordrb::Commands::CommandContainer

  command :weather,
          description: "Get current conditions powered by Apixu",
          usage: "%weather Location|US Zip|CA Zip" do |event, *args|
    location = Array(args).map { |a| a.to_s.strip }.join(" ")
    result = Apixu::CurrentConditions.new.fetch(location)
    if result[:error]
      event.respond(result[:error])
    else
      event.channel.send_embed do |embed|
        embed.title = "Currently in #{result[:location]}"
        embed.add_field(name: "Condition", value: result[:condition], inline: true)
        embed.add_field(name: "Temperature", value: result[:temperature], inline: true)
        embed.add_field(name: "Humidity", value: result[:humidity], inline: true)
        embed.add_field(name: "Wind", value: result[:wind], inline: true)
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: result[:icon])
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
          text: "Powered by Apixu.com", icon_url: "http://cdn.apixu.com/v4/images/logo.png"
        )
      end
    end
  end
end
