class Road < ApplicationRecord
  belongs_to :starting_city, class_name: 'City'
  belongs_to :ending_city, class_name: 'City'

  has_many :cities, ->(road) { unscope(:where).find(road.start_city_id, road.ending_city_id) }

  def destination(start_city)
    cities.where.not(id: start_city.id).first
  end
end
