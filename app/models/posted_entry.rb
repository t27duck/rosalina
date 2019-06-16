# frozen_string_literal: true

class PostedEntry < ApplicationRecord
  self.primary_key = :slug

  validates :slug, uniqueness: true
end
