# frozen_string_literal: true

require "bot/podcast"

module PodcastContainer
  extend Discordrb::Commands::CommandContainer

  command :podcast,
          description: "Enter a national dex id and get Pokemon info",
          usage: "%podcast episode_number" do |event, episode_number|
    result = Podcast.new.fetch(episode_number)
    if result[:error]
      event.respond(result[:error])
    else
      event.channel.send_embed do |embed|
        embed.title = result[:title]
        embed.url = result[:url] if result[:url]
        embed.add_field(name: "Runtime", value: result[:runtime], inline: true) if result[:runtime]
        embed.add_field(name: "Published", value: result[:published_on], inline: true) if result[:published_on]
        embed.add_field(name: "Music Score", value: result[:music_score], inline: true) if result[:music_score]
        embed.add_field(name: "Pokemon", value: result[:pokemon], inline: true) if result[:pokemon]
        embed.description = result[:description]
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: result[:image_url])
      end
    end
  end
end
