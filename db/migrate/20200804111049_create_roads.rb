class CreateRoads < ActiveRecord::Migration[6.0]
  def change
    create_table :roads do |t|
      t.references :starting_city, null: false, foreign_key: { to_table: 'cities' }
      t.references :ending_city, null: false, foreign_key: { to_table: 'cities' }
      t.integer :distance

      t.timestamps
    end
  end
end
