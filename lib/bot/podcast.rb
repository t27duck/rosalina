# frozen_string_literal: true

require "json"
require "rest-client"

class Podcast
  BASE_URL = "https://gonintendo.com/podcast/episode/"

  def fetch(episode_number)
    return { error: "No episode given" } if episode_number.to_s.empty?

    result = JSON.parse(RestClient.get("#{BASE_URL}/#{episode_number}.json"))
    parse(result)
  rescue StandardError => e
    Rails.logger.error("Error for Podcast API: #{e.message}")
    { error: "Unable to get podcast info" }
  end

  private

  def parse(body)
    raise "No podcast key in json" unless body.key?("podcast")

    podcast = body["podcast"]
    {
      title: podcast["title"],
      description: podcast["description"],
      url: podcast["url"],
      pokemon: podcast["pokemon"],
      runtime: podcast["runtime"],
      published_on: podcast["published_on"],
      music_score: podcast["music_score"],
      crew: Array(podcast["crew"]).sort,
      image_url: "https://gonintendo.com/images/podcast/gonintendo-small.png"
    }
  end
end
