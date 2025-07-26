# app/jobs/location_entry_job.rb
# Handle location entry effects and events
class LocationEntryJob < ApplicationJob
  queue_as :low

  def perform(user, location)
    Rails.logger.info "#{user.username} entered #{location.name}"
    
    # Random events based on location
    trigger_random_events(user, location)
    
    # Update user statistics
    update_exploration_stats(user, location)
    
    # Check for location-specific quest progress
    update_quest_progress(user, location)
  end

  private

  def trigger_random_events(user, location)
    return if location.safe_zone?
    
    # 20% chance of random encounter
    if rand < 0.2
      trigger_random_encounter(user, location)
    end
    
    # 5% chance of finding treasure
    if rand < 0.05
      trigger_treasure_find(user, location)
    end
  end

  def trigger_random_encounter(user, location)
    # Queue a random combat encounter
    enemies = get_location_enemies(location)
    enemy = enemies.sample
    
    Rails.logger.info "Random encounter triggered: #{user.username} vs #{enemy}"
    # This could trigger combat or other events
  end

  def trigger_treasure_find(user, location)
    treasure_gold = rand(10..50)
    user.update(gold: user.gold + treasure_gold)
    
    Rails.logger.info "#{user.username} found #{treasure_gold} gold in #{location.name}"
  end

  def update_exploration_stats(user, location)
    # Track exploration statistics
    session = user.current_session
    state = session.game_state
    
    state['locations_visited'] ||= []
    state['locations_visited'] << location.id unless state['locations_visited'].include?(location.id)
    
    session.update(game_state: state)
  end

  def update_quest_progress(user, location)
    # Check active quests for location-based objectives
    user.user_quests.active.each do |user_quest|
      quest = user_quest.quest
      progress = user_quest.progress
      
      quest.objectives.each do |objective, required_count|
        if objective.start_with?('visit_location_') && objective.end_with?("_#{location.id}")
          progress[objective] = (progress[objective] || 0) + 1
        end
      end
      
      user_quest.update(progress: progress)
    end
  end

  def get_location_enemies(location)
    # Return appropriate enemies for the location level
    case location.required_level
    when 1..5
      ['Rat', 'Goblin', 'Slime']
    when 6..10
      ['Orc', 'Wolf', 'Bandit']
    when 11..15
      ['Troll', 'Skeleton', 'Dark Elf']
    else
      ['Dragon', 'Demon', 'Lich']
    end
  end
end