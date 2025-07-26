# db/migrate/006_create_quests.rb
class CreateQuests < ActiveRecord::Migration[7.0]
  def change
    create_table :quests do |t|
      t.string :name, null: false
      t.text :description
      t.json :objectives # Quest objectives and completion status
      t.json :rewards    # Experience, gold, items
      t.integer :required_level, default: 1
      t.boolean :repeatable, default: false
      
      t.timestamps
    end
    
    add_index :quests, :name, unique: true
    add_index :quests, :required_level
  end
end