class City < ApplicationRecord
  belongs_to :country

  has_many :roads_starting, class_name: 'Road', foreign_key: 'starting_city_id'
  has_many :roads_ending, class_name: 'Road', foreign_key: 'ending_city_id'

  has_many :end_neighbors, through: :roads_starting, source: :ending_city
  has_many :start_neighbors, through: :roads_ending, source: :starting_city

  def roads
    roads_starting.or(roads_ending).distinct
  end

  def neighbors
    end_neighbors.or(end_neighbors)
  end

  def road_to(neighbor)
    roads.find_by(ending_city_id: neighbor.id)
  end

  # def neighbors
  #   City.find(roads.pluck(:starting_city_id)).or(City.find(:ending))
  # end
end
