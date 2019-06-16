# frozen_string_literal: true

require "yaml"

unless "".respond_to?(:titleize)
  class String
    def titleize
      split(/(\W)/).map(&:capitalize).join
    end
  end
end

class Pokedex
  IMG_URL_BASE = "https://raw.githubusercontent.com/PokeAPI/pokeapi/master/data/v2/sprites/pokemon/"

  def self.data
    @data ||= YAML.load_file(File.join(__dir__, "..", "data", "pokemon.yml"))
  end

  def self.lookup(national_dex_id)
    result = data[national_dex_id.to_i]

    return { error: "Pokemon not found" } if result.nil?

    species = result["species"]
    species += " Pokemon" unless species.include?("Pokémon")

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
