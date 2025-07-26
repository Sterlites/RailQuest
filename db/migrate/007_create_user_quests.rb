# db/migrate/007_create_user_quests.rb
class CreateUserQuests < ActiveRecord::Migration[7.0]
  def change
    create_table :user_quests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quest, null: false, foreign_key: true
      t.string :status, default: 'active' # active, completed, failed
      t.json :progress # Current progress on objectives
      t.datetime :started_at
      t.datetime :completed_at
      
      t.timestamps
    end
    
    add_index :user_quests, [:user_id, :quest_id], unique: true
    add_index :user_quests, [:user_id, :status]
  end
end