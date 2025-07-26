# db/migrate/008_create_combat_logs.rb
class CreateCombatLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :combat_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :enemy_name
      t.text :log_data # JSON storage for combat actions
      t.string :result # victory, defeat, fled
      t.integer :experience_gained, default: 0
      t.integer :gold_gained, default: 0
      
      t.timestamps
    end
    
    add_index :combat_logs, [:user_id, :created_at]
    add_index :combat_logs, :result
  end
end