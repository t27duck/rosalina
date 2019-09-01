# frozen_string_literal: true

require "json"
require "rest-client"

module Apixu
  module Errors
    class InvalidKey < StandardError; end
    class Request < StandardError
      def initialize(code, message)
        super "#{code}: #{message}"
      end
    end
  end

  class CurrentConditions
    def fetch(search_term)
      return { error: "No location given" } if search_term.to_s.empty?

      term = search_term.to_s.downcase
      result = client.current(term)
      parse(result)
    rescue StandardError => e
      Rails.logger.error("Error for bot weather API: #{e.message}")
      error = "Unable to get weather"
      search_options = "city name (with optional region and country), US zip code, Canada postal code, UK postcode, etc"
      fallback = "You can try searching at https://www.apixu.com/weather/"
      { error: "#{error}. You can search by #{search_options}. #{fallback}." }
    end

    private

    def parse(body)
      location = (body["location"]["name"]).to_s
      country = body["location"]["country"]
      location += if ["United States of America", "USA", "US"].include?(country)
                    ", #{body['location']['region']}"
                  else
                    ", #{country}"
                  end

      condition = body["current"]["condition"]["text"]
      icon = "https:#{body['current']['condition']['icon']}"
      temperature = "#{body['current']['temp_f']}F (#{body['current']['temp_c']}C)"
      humidity = "#{body['current']['humidity']}%"
      wind = "#{body['current']['wind_dir']} at #{body['current']['wind_mph']}MPH (#{body['current']['wind_kph']}KPH)"
      {
        location: location,
        condition: condition,
        temperature: temperature,
        humidity: humidity,
        wind: wind,
        icon: icon
      }
    end

    def client
      @client ||= Apixu::Client.new
    end
  end

  class Client
    attr_reader :key

    BASE_URL = "http://api.apixu.com/v1"

    def initialize(key = nil)
      @key = key || ENV["APIXU_KEY"]

      raise Errors::InvalidKey unless @key
    end

    def url(endpoint)
      "#{BASE_URL}/#{endpoint}.json"
    end

    def request(key, params = {})
      params["key"] = @key
      result = JSON.parse(RestClient.get(url(key), params: params))

      if result["error"]
        raise Errors::Request.new(result["error"]["code"], result["error"]["message"])
      else
        result
      end
    end

    def current(query)
      request(:current, q: query)
    end

    def forecast(query, days = 1)
      request(:forecast, q: query, days: days)
    end
  end
end
