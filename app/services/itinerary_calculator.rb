class ItineraryCalculator # < BaseService that would handle errors, and set the call method
  ItineraryCalculationFailure = Class.new(StandardError)
  Itinerary = Struct.new(:cities, :distance)

  # the class call method that should be in the BaseService
  def self.call(*args)
    service = new(*args)
    service.call
    service
  end


  attr_reader :country, :start, :target, :result, :errors

  delegate :cities, to: :country

  private

  def initialize(country:, start:, target:)
    @country = country
    @start = start
    @target = target
    @errors = []
    @result = Itinerary.new([], 0)
  end

  def call
    # validate_cities
    calculate_result # should return a result
  rescue ItineraryCalculationFailure => e
    @errors << e
    @result = Itinerary.new([], 0)
  end

  def success?
    errors.any?
  end

  def validate_cities
  raise ItineraryCalculationFailure, 'Cities invalid' unless [start, target].all?(:persisted)
  end

  # incomplete, would need refactoring
  def calculate_result
    current_city = start
    target_city = target

    visited = []
    unvisited = cities

    # init tentative_distances
    tentative_distances = {}
    unvisited.each { |c| tentative_distances[c] = 100000 }
    tentative_distances[current_city] = 0

    while current_city != target_city
      current_city.neighbors.each do |neighbor|
        distance = current_city.road_to(neighbor)&.distance
        next if distance.nil?

        full_distance = distance + tentative_distances[current_city]
        tentative_distances[neighbor] = full_distance if full_distance < tentative_distances[neighbor]
      end

      # update visited nodes
      unvisited = unvisited.where.not(id: current_city.id)
      visited << current_city

      # Find the city with the smallest tentative value
      current_city = tentative_distances.reject { |k, _| visited.include?(k) }.min_by{|k, v| v}.first
    end

    @result.cities = visited.push(current_city)
    @result.distance = tentative_distances[target_city]
  end
end

