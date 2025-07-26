# db/migrate/002_create_game_sessions.rb
class CreateGameSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :game_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :current_location_id, default: 1
      t.text :game_state, default: '{}' # JSON storage for flexible state
      t.boolean :active, default: true
      t.datetime :last_action_at
      
      t.timestamps
    end
    
    add_index :game_sessions, [:user_id, :active]
    add_index :game_sessions, :last_action_at
  end
end