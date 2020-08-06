# frozen_string_literal: true


#     Use:
#
#       ItineraryCalculator.call(country:, start:, target:)
#
#
#     Arguments:
#
#       country   => [Country]
#       start     => [City]
#       target    => [City]
#
#
#     Returns:
#
#       self      => [ItineraryCalculator]
#
#
#     Public Methods:
#
#       #result     => [Itinerary] (which makes available Itinerary#cities, Itinerary#distance)
#       #success?   => [Boolean]
#       #errors     => [Array] (of Strings)
#


class ItineraryCalculator < BaseService
  ItineraryCalculationFailure = Class.new(StandardError)
  Itinerary = Struct.new(:cities, :distance)

  def call
    validate_cities
    build_matrix
    assign_shortest_distance
    assign_itinerary_cities
  rescue ItineraryCalculationFailure => e
    @errors << e
    @result = Itinerary.new([], 0)
  end

  private

    def initialize(country:, start:, target:)
      @country            = country
      @starting_city      = start
      @target_city        = target
      @current_city       = start
      @unvisited          = country.cities
      @visited            = []
      @distance_matrix    = initial_matrix
      @errors             = []
      @result             = Itinerary.new([], 0)
    end


    #   Checks if the cities are indeed city objects and stored in DB. Otherwise the service fails to execute.

    def validate_cities
      return if [@starting_city, @target_city].all? { |city| city.is_a?(City) && city.persisted? }

      raise ItineraryCalculationFailure, 'Cities invalid.'
    end


    #   Sets the result.distance to the :shortest_distance_to_start recorded in target_city

    def assign_shortest_distance
      @result.distance = @distance_matrix.dig(@target_city, :shortest_distance_to_start)
    end


    #   Builds the result.cities array with all the cities visited during the shortest path.
    #   1. Recursively picks up all the previous_cities, starting from the target_city all the way to the starting_city
    #   2. Adds them to the result
    #   3. Reverses the result cities array to start from the starting_city

    def assign_itinerary_cities
      previous_city = @target_city
      @result.cities << @target_city

      while previous_city != @starting_city
        previous_city = @distance_matrix.dig(previous_city, :previous_city)
        @result.cities << previous_city
      end

      @result.cities.reverse!
    end


    #   Builds a @distance_matrix (Hash) that records a :shortest_distance_to_start and :previous_city.
    #   1. Starts by setting the
    #   3. Reverses the result cities array to start from the starting_city

    def build_matrix
      assign_distance_from_starting_city_to_start

      while @current_city != @target_city
        record_neighboring_distances
        mark_current_city_as_visited
        assign_new_current_city

        break unless @current_city
      end
    end


    #   Iterates over each of the current_city.neighbors, and finds the shortest_distance_to_start for each of them,
    #   unless it's been visited.
    #   1. Iterates over current_city.neighbors.
    #   2. Skips the neighbor if has been visited.
    #   3. Finds the road distance from the current_city to the neighbor.
    #   4. Skips the neighbor if the road's distance can't be found.
    #   5. Calculates the full_distance from the neighbor to the starting_city.
    #   6. If this full_distance is lower than the previous shortest_distance_to_start recorded:
    #      6.1. Overwrite the old shortest_distance_to_start.
    #      6.2. Record the current city has the best previous_city.

    def record_neighboring_distances
      @current_city.neighbors.each do |neighbor|
        next if @visited.include?(neighbor)

        road = @current_city.road_to(neighbor)
        distance_to_neighbor = road&.distance
        next if distance_to_neighbor.nil?

        full_distance = distance_to_neighbor + distance_from_current_city_to_start

        if full_distance < @distance_matrix.dig(neighbor, :shortest_distance_to_start)
          @distance_matrix[neighbor][:shortest_distance_to_start] = full_distance
          @distance_matrix[neighbor][:previous_city] = @current_city
        end
      end
    end


    #   Adds the current city to the list of visited cities, and removes it from the unvisited.

    def mark_current_city_as_visited
      @unvisited = @unvisited - [@current_city]
      @visited << @current_city
    end


    #   Sets the starting_city's shortest_distance_to_start (to itself) to 0.

    def assign_distance_from_starting_city_to_start
      @distance_matrix[@starting_city][:shortest_distance_to_start] = 0
    end


    #   Returns this shortest_distance_to_start for the current_city.

    def distance_from_current_city_to_start
      @distance_matrix.dig(@current_city, :shortest_distance_to_start)
    end


    #   Find the unvisited which the smallest of all shortest_distance_to_start and assigns it as the new current_city.
    #   This is only possible because visited cities have lower shortest_distance_to_start than unvisited ones (still infinite).

    def assign_new_current_city
      @current_city =  @distance_matrix.reject { |city, _matrix_values| @visited.include?(city) }
                                      .min_by { |city, matrix_values| matrix_values.dig(:shortest_distance_to_start) }
                                      &.first
    end


    #   Builds the empty @distance_matrix (Hash), which assumes that:
    #   1. The shortest_distance_to_start is "infinite" at the start for every city.
    #   2. The previous_city visited before finding the shortest_distance_to_start is unknown.

    def initial_matrix
      {}.tap do |matrix|
        @country.cities.each do |city|
          matrix[city] = {
            shortest_distance_to_start: 1_000_000,
            previous_city: nil
          }
        end
      end
    end
end

