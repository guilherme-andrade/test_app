# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

BELGIAN_CITIES = [
  :bruges, :antwerp, :ghent, :mechelen, :brussels, :mons, :namur, :liege,
  :arlon, :tournai
]

BELGIAN_ROADS = {
  [:bruges, :ghent] => 50,
  [:ghent, :tournai] => 80,
  [:tournai, :brussels] => 89,
  [:ghent, :brussels] => 56,
  [:ghent, :antwerp] => 60,
  [:antwerp, :mechelen] => 25,
  [:mechelen, :brussels] => 27,
  [:brussels, :mons] => 80,
  [:mons, :namur] => 91,
  [:mons, :tournai] => 51,
  [:namur, :arlon] => 129,
  [:arlon, :liege] => 123,
  [:liege, :namur] => 65,
  [:liege, :brussels] => 97
}

Road.destroy_all
City.destroy_all
Country.destroy_all

belgium = Country.create(name: 'Belgium')

belgian_cities = BELGIAN_CITIES.map { |name| City.create(country: belgium, name: name.to_s) }

belgian_roads = BELGIAN_ROADS.map do |city_names, distance|
  starting_city, ending_city = City.where(name: city_names)

  Road.create(starting_city: starting_city, ending_city: ending_city, distance: distance)
end
