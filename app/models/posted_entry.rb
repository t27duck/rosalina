# frozen_string_literal: true

class PostedEntry < ApplicationRecord
  validates :slug, :key, :url, presence: true
  validates :key, uniqueness: { scope: :slug }
end
