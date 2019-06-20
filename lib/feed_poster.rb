# frozen_string_literal: true

require "discordrb/webhooks"
require "feedjira"

class FeedPoster
  FEEDS = {
    "topstories" => {
      url: "https://gonintendo.com/feeds/topstories.xml",
      username: "GoNintendo Top Stories",
      webhook: ENV["ROSALINA_TOP_STORY_WEBHOOK"]
    },
    "allnews" => {
      url: "https://gonintendo.com/feeds/all.xml",
      username: "New Posts on GoNintendo",
      webhook: ENV["ROSALINA_ALL_NEWS_WEBHOOK"]
    }
  }.freeze

  def initialize(key)
    raise "Unknown key '#{key}'" unless FEEDS.key?(key.to_s)

    @key = key.to_s
  end

  def perform(post: true)
    feed.entries.each do |entry|
      next if PostedEntry.where(key: @key, slug: entry.id).exists?

      post(entry) if post

      PostedEntry.create!(key: @key, slug: entry.id, url: entry.url)
    end
  end

  private

  def feed
    Feedjira::Feed.fetch_and_parse(FEEDS[@key][:url])
  end

  def client
    @client ||= Discordrb::Webhooks::Client.new(url: FEEDS[@key][:webhook])
  end

  def post(entry)
    client.execute do |builder|
      builder.username = FEEDS[@key][:username]
      builder.add_embed do |embed|
        embed.title = entry.title
        embed.url = entry.url
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
          text: "posted by #{entry.author}",
          icon_url: "https://i.imgur.com/66AN7p9.jpg"
        )
      end
    end
  end
end
