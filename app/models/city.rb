class City < ApplicationRecord
  belongs_to :country

  ROAD_TO_NEIGHBOR_QUERY = lambda do |city, neighbor|
    <<-SQL
      SELECT "roads"."distance", "roads"."id" FROM "roads"
      JOIN "cities" ON "roads"."starting_city_id" = "cities"."id"
      WHERE "roads"."ending_city_id" = #{city.id} AND "roads"."starting_city_id" = #{neighbor.id}
      UNION
      SELECT "roads"."distance", "roads"."id" FROM "roads"
      JOIN "cities" ON "roads"."ending_city_id" = "cities"."id"
      WHERE "roads"."starting_city_id" = #{city.id} AND "roads"."ending_city_id" = #{neighbor.id}
      LIMIT 1
    SQL
  end

  ROADS_QUERY = lambda do |city|
    <<-SQL
      SELECT "roads".* FROM "roads"
      JOIN "cities" ON "roads"."starting_city_id" = "cities"."id"
      WHERE "roads"."ending_city_id" = #{city.id}
      UNION
      SELECT "roads".* FROM "roads"
      JOIN "cities" ON "roads"."ending_city_id" = "cities"."id"
      WHERE "roads"."starting_city_id" = #{city.id}
    SQL
  end

  # the most efficient way I found to retrieve neighbors
  NEIGHBORS_QUERY = lambda do |city|
    <<-SQL
      SELECT "cities"."id", "cities"."name" FROM "cities"
      JOIN "roads" ON "roads"."starting_city_id" = "cities"."id"
      WHERE "roads"."ending_city_id" = #{city.id}
      UNION
      SELECT "cities"."id", "cities"."name" FROM "cities"
      JOIN "roads" ON "roads"."ending_city_id" = "cities"."id"
      WHERE "roads"."starting_city_id" = #{city.id}
    SQL
  end

  NEIGHBORS_SCOPE = lambda do |city|
    find_by_sql(NEIGHBORS_QUERY.call(city))
  end

  def roads
    query = ROADS_QUERY.call(self)
    Road.find_by_sql(query)
  end

  def road_to(neighbor)
    query = ROAD_TO_NEIGHBOR_QUERY.call(self, neighbor)
    Road.find_by_sql(query)&.first
  end

  def neighbors
    query = NEIGHBORS_QUERY.call(self)
    City.find_by_sql(query)
  end
end
