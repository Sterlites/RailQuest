# db/migrate/005_create_user_items.rb
class CreateUserItems < ActiveRecord::Migration[7.0]
  def change
    create_table :user_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.boolean :equipped, default: false
      
      t.timestamps
    end
    
    add_index :user_items, [:user_id, :item_id]
    add_index :user_items, [:user_id, :equipped]
  end
end