# frozen_string_literal: true

namespace :discord do
  desc "Fetches the latest top stories and posts to Discord"
  task post_top_stories: :environment do
    raise "ROSALINA_TOP_STORY_WEBHOOK not set" unless ENV["ROSALINA_TOP_STORY_WEBHOOK"]

    require "feed_poster"
    FeedPoster.new("topstories").perform
  end

  desc "Fetches the latest stories and posts to Discord"
  task post_latest_stories: :environment do
    raise "ROSALINA_ALL_NEWS_WEBHOOK not set" unless ENV["ROSALINA_ALL_NEWS_WEBHOOK"]

    require "feed_poster"
    FeedPoster.new("allnews").perform
    FeedPoster.new("nintendoeverything").perform
  end

  desc "Cleans up posted_entries"
  task clean_posted_entries: :environment do
    require "feed_poster"

    FeedPoster::FEEDS.keys.each do |key|
      PostedEntry.where(key: key).where.not(
        id: PostedEntry.where(key: key).order(created_at: :desc).limit(45)
      )
    end
  end

  desc "Starts the Discord bot"
  task bot: :environment do
    raise "ROSALINA_BOT_TOKEN not set" unless ENV["ROSALINA_BOT_TOKEN"]

    require "discordrb"
    require "bot/codes_container"
    require "bot/ping_container"
    require "bot/weather_container"
    require "bot/podcast_container"
    require "bot/pokedex_container"
    require "bot/sayings_container"
    require "bot/eight_ball_container"
    require "bot/coin_flip_container"

    bot = Discordrb::Commands::CommandBot.new(token: ENV["ROSALINA_BOT_TOKEN"], prefix: "%")
    bot.include! CodesContainer
    bot.include! PingContainer
    bot.include! PodcastContainer
    bot.include! PokedexContainer
    bot.include! SayingsContainer
    bot.include! EightBallContainer
    bot.include! CoinFlipContainer
    bot.include! WeatherContainer if ENV["WEATHERSTACK_KEY"]
    bot.run
  end
end
