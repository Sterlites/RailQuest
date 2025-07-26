# config/initializers/new_relic.rb
# Application monitoring configuration
if Rails.env.production?
  require 'new_relic/agent'
  
  NewRelic::Agent.manual_start
  
  # Custom metrics for game-specific events
  class GameMetrics
    def self.record_user_action(action_type)
      NewRelic::Agent.record_metric("Custom/Game/#{action_type}", 1)
    end
    
    def self.record_combat_outcome(outcome)
      NewRelic::Agent.record_metric("Custom/Combat/#{outcome.capitalize}", 1)
    end
    
    def self.record_level_up(level)
      NewRelic::Agent.record_metric("Custom/LevelUp/Count", 1)
      NewRelic::Agent.record_metric("Custom/LevelUp/AverageLevel", level)
    end
  end
end