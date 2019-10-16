# frozen_string_literal: true

require "json"
require "rest-client"

module Weatherstack
  module Errors
    class InvalidKey < StandardError; end
    class Request < StandardError
      def initialize(code, message)
        super "#{code}: #{message}"
      end
    end
  end

  class CurrentConditions
    USA_TERMS = ["United States of America", "USA", "US", "USA United States of America"].freeze

    def fetch(search_term)
      return { error: "No location given" } if search_term.to_s.empty?

      term = search_term.to_s.downcase
      result = client.current(term)
      parse(result)
    rescue StandardError => e
      raise
      # Rails.logger.error("Error for bot weather API: #{e.message}")
      error = "Unable to get weather"
      search_options = "city name (with optional region and country), US zip code, Canada postal code, UK postcode, etc"
      { error: "#{error}. You can search by #{search_options}." }
    end

    private

    def parse(body)
      location = body["location"]["name"].to_s
      country = body["location"]["country"]
      location += if USA_TERMS.include?(country)
                    ", #{body['location']['region']}"
                  else
                    ", #{country}"
                  end

      temp_f = body['current']['temperature'].to_i
      temp_c = ((temp_f.to_f - 32) * 5 / 9).to_i

      wind_mph = body['current']['wind_speed'].to_i
      wind_kph = (wind_mph * 1.609344).to_i

      condition = body["current"]["weather_descriptions"].join(", ").to_s
      icon = body["current"]["weather_icons"].first.to_s
      temperature = "#{temp_f}F (#{temp_c}C)"
      humidity = "#{body['current']['humidity']}%"
      wind = "#{body['current']['wind_dir']} at #{wind_mph}MPH (#{wind_kph}KPH)"
      pressure = "#{body['current']['pressure']}MB"
      uv_index = body["current"]["uv_index"].to_s
      observation_time = "#{body['current']['observation_time']} UTC"
      cloudcover = "#{body['current']['cloudcover']}%"
      {
        location: location,
        condition: condition,
        temperature: temperature,
        humidity: humidity,
        wind: wind,
        pressure: pressure,
        uv_index: uv_index,
        cloudcover: cloudcover,
        observation_time: observation_time
        icon: icon
      }
    end

    def client
      @client ||= Weatherstack::Client.new
    end
  end

  class Client
    attr_reader :key

    BASE_URL = "http://api.weatherstack.com/"

    def initialize(key = nil)
      @key = key || ENV["WEATHERSTACK_KEY"]

      raise Errors::InvalidKey unless @key
    end

    def url(endpoint)
      "#{BASE_URL}/#{endpoint}"
    end

    def request(endpoint, params = {})
      params["access_key"] = @key
      result = JSON.parse(RestClient.get(url(endpoint), params: params))

      raise Errors::Request.new(result["error"]["code"], result["error"]["info"]) if result["error"]

      result
    end

    def current(query)
      request(:current, query: query, units: "f")
    end
  end
end
