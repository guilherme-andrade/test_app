class Country < ApplicationRecord

  ROADS_SCOPE = lambda do |country|
    unscope(:where).where(starting_city: country.cities).or(where(ending_city: country.cities))
  end

  has_many :cities
  has_many :roads, ROADS_SCOPE

  # just for the link in the home page, not really best practice
  def self.belgium
    find_by_name('Belgium')
  end

  def to_param
    name
  end
end
