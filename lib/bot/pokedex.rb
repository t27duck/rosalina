# frozen_string_literal: true

require "yaml"

class Pokedex
  IMG_URL_BASE = "https://raw.githubusercontent.com/PokeAPI/pokeapi/master/data/v2/sprites/pokemon/"

  def self.data
    @data ||= YAML.load_file(Rails.root.join("db", "data", "pokemon.yml"))
  end

  def self.lookup(national_dex_id)
    result = data[national_dex_id.to_i]
    result ||= data.detect { |id, data| data['name'] == national_dex_id.to_s.downcase }
    result = result.last if result.is_a?(Array)

    return { error: "Pokémon not found" } if result.nil?

    species = result["species"]
    species += " Pokémon" unless species.include?("Pokémon")

    {
      name: result["name"].titleize,
      species: species,
      national_dex: result["national_dex"],
      types: result["types"].map(&:titleize).join(", "),
      description: result["descriptions"].sample,
      image_url: "#{IMG_URL_BASE}#{result['national_dex']}.png"
    }
  end
end
