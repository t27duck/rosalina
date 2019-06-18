# frozen_string_literal: true

class PostedEntry < ApplicationRecord
  self.primary_key = :slug

  validates :slug, uniqueness: true, presence: true
  validates :url, presence: true
end
