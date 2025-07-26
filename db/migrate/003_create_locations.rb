# db/migrate/003_create_locations.rb
class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.text :description
      t.text :long_description
      t.json :exits # Store available directions and destination IDs
      t.json :items # Available items in this location
      t.json :npcs  # Non-player characters present
      t.boolean :safe_zone, default: false
      t.integer :required_level, default: 1
      
      t.timestamps
    end
    
    add_index :locations, :name, unique: true
    add_index :locations, :required_level
  end
end