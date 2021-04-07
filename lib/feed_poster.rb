# frozen_string_literal: true

require "discordrb/webhooks"
require "feedjira"
require "net/http"

class FeedPoster
  FEEDS = {
    "topstories" => {
      url: "https://gonintendo.com/feeds/topstories.xml",
      username: "GoNintendo Top Stories",
      webhook: ENV["ROSALINA_TOP_STORY_WEBHOOK"],
      icon: "https://i.imgur.com/66AN7p9.jpg"
    },
    "allnews" => {
      url: "https://gonintendo.com/feeds/all.xml",
      username: "New Posts on GoNintendo",
      webhook: ENV["ROSALINA_ALL_NEWS_WEBHOOK"],
      icon: "https://i.imgur.com/66AN7p9.jpg"
    },
    "nintendoeverything" => {
      url: "https://nintendoeverything.com/feed",
      username: "New Posts on NintendoEverything.com",
      webhook: ENV["ROSALINA_ALL_NEWS_WEBHOOK"],
      icon: "https://nintendoeverything.com/wp-content/uploads/cropped-OLmaPV3Y_400x400-1-32x32.jpg"
    },
    "mynintendonews" => {
      url: "https://mynintendonews.com/feed/",
      username: "New Posts on MyNintendoNews.com",
      webhook: ENV["ROSALINA_ALL_NEWS_WEBHOOK"],
      icon: "https://i2.wp.com/mynintendonews.com/wp-content/uploads/2021/02/toad.jpg"
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
    Feedjira.parse(make_feed_request(FEEDS[@key][:url]))
  end

  def make_feed_request(request_url, limit = 5)
    raise ArgumentError, "too many HTTP redirects" if limit <= 0

    uri = URI.parse(request_url)
    req = Net::HTTP::Get.new(uri.request_uri)
    req["Accept-Language"] = "*"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = 5
    http.read_timeout = 5
    response = http.start { http.request(req) }

    case response
    when Net::HTTPSuccess
      response.body
    when Net::HTTPRedirection
      location = response["location"]
      make_request(location, limit - 1)
    end
  end

  def client
    @client ||= Discordrb::Webhooks::Client.new(url: FEEDS[@key][:webhook])
  end

  def post(entry)
    sleep 1
    client.execute do |builder|
      builder.username = FEEDS[@key][:username]
      builder.add_embed do |embed|
        embed.title = entry.title
        embed.url = entry.url
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(
          text: "posted by #{entry.author}",
          icon_url: FEEDS[@key][:icon]
        )
      end
    end
  end
end
