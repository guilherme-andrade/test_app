class CitySelectComponent < ViewComponentReflex::Component
  attr_reader :country

  delegate :cities, to: :country

  def initialize(country:)
    @country = country
    @starting_city ||= cities.first
    @ending_city ||= cities.last

    identify_itinerary
    set_city_options
  end

  def select_starting_city
    @starting_city = cities.find(element.value)

    refresh_initinerary_with_selection
  end

  def select_ending_city
    @ending_city = cities.find(element.value)

    refresh_initinerary_with_selection
  end

  def refresh_initinerary_with_selection
    identify_itinerary
    set_city_options
    refresh! '#itinerary'
  end

  def identify_itinerary
    @itinerary = ItineraryCalculator.call(country: @country, start: @starting_city, target: @ending_city).result
    @distance = @itinerary.distance
    @cities = @itinerary.cities
  end

  def set_city_options
    @starting_city_options = cities.where.not(id: @starting_city.id)
    @ending_city_options = cities.where.not(id: @starting_city.id)
  end
end
