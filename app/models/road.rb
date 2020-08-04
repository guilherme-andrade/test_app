class Road < ApplicationRecord
  belongs_to :starting_city, class_name: 'City'
  belongs_to :ending_city, class_name: 'City'

  def destination(start_city)
    cities.where.not(id: start_city.id).first
  end

  def cities
    City.where(id: [starting_city_id, ending_city_id])
  end
end
