# frozen_string_literal: true

namespace :discord do
  desc "Fetches the top stories feed and posts to Discord"
  task post_top_stories: :environment do
    raise "ROSALINA_TOP_STORY_WEBHOOK not set" unless ENV["ROSALINA_TOP_STORY_WEBHOOK"]

    require "discord-notifier"
    require "feedjira"
    Feedjira.logger.level = Logger::FATAL

    Discord::Notifier.setup do |config|
      config.url = ENV["ROSALINA_TOP_STORY_WEBHOOK"]
      config.username = "GoNintendo Top Stories"
    end

    feed = Feedjira::Feed.fetch_and_parse("https://gonintendo.com/feeds/topstories.xml")

    feed.entries.each do |entry|
      next if PostedEntry.where(slug: entry.id).exists?

      embed = Discord::Embed.new do
        title entry.title
        url entry.url
        footer text: "posted by #{entry.author}", icon_url: "https://i.imgur.com/66AN7p9.jpg"
      end
      Discord::Notifier.message(embed)
      PostedEntry.create!(slug: entry.id, url: entry.url)
    end
  end
end
