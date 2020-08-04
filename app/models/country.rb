class Country < ApplicationRecord
  has_many :cities

  # just for the link in the home page, not really best practice
  def self.belgium
    find_by_name('Belgium')
  end

  def to_param
    name
  end
end
