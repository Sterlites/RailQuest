# db/migrate/004_create_items.rb
class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.text :description
      t.string :item_type # weapon, armor, consumable, quest_item
      t.integer :value, default: 0 # Gold value
      t.json :properties # Stats, effects, etc.
      t.boolean :consumable, default: false
      t.boolean :equippable, default: false
      t.string :equipment_slot # head, chest, weapon, etc.
      
      t.timestamps
    end
    
    add_index :items, :name, unique: true
    add_index :items, :item_type
  end
end