# app/jobs/item_use_job.rb
# Handle complex item usage effects
class ItemUseJob < ApplicationJob
  queue_as :default

  def perform(user, item)
    Rails.logger.info "#{user.username} used item: #{item.name}"
    
    # Handle special item effects
    handle_special_effects(user, item)
    
    # Update item usage statistics
    update_usage_stats(user, item)
    
    # Check for item-related quest progress
    update_quest_progress(user, item)
  end

  private

  def handle_special_effects(user, item)
    special_effects = item.properties['special_effects'] || []
    
    special_effects.each do |effect|
      case effect
      when 'teleport_to_town'
        teleport_user_to_town(user)
      when 'reveal_map'
        reveal_map_for_user(user)
      when 'temporary_stat_boost'
        apply_temporary_boost(user, item)
      end
    end
  end

  def teleport_user_to_town(user)
    town = Location.starting_location
    user.move_to_location(town)
    Rails.logger.info "#{user.username} teleported to #{town.name}"
  end

  def reveal_map_for_user(user)
    session = user.current_session
    state = session.game_state
    state['map_revealed'] = true
    session.update(game_state: state)
    Rails.logger.info "Map revealed for #{user.username}"
  end

  def apply_temporary_boost(user, item)
    # Temporary stat boosts could be implemented with a separate system
    Rails.logger.info "Applied temporary boost to #{user.username} from #{item.name}"
  end

  def update_usage_stats(user, item)
    session = user.current_session
    state = session.game_state
    
    state['items_used'] ||= {}
    state['items_used'][item.id.to_s] = (state['items_used'][item.id.to_s] || 0) + 1
    
    session.update(game_state: state)
  end

  def update_quest_progress(user, item)
    user.user_quests.active.each do |user_quest|
      quest = user_quest.quest
      progress = user_quest.progress
      
      quest.objectives.each do |objective, required_count|
        if objective == "use_item_#{item.id}"
          progress[objective] = (progress[objective] || 0) + 1
        end
      end
      
      user_quest.update(progress: progress)
    end
  end
end