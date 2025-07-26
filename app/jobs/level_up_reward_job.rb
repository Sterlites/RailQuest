# app/jobs/level_up_reward_job.rb
# Background processing for level up events
class LevelUpRewardJob < ApplicationJob
  queue_as :default

  def perform(user)
    return unless user.persisted?

    Rails.logger.info "Processing level up rewards for #{user.username} (Level #{user.level})"
    
    # Grant level-based rewards
    bonus_gold = user.level * 10
    user.update(gold: user.gold + bonus_gold)
    
    # Special rewards for milestone levels
    if milestone_level?(user.level)
      grant_milestone_rewards(user)
    end
    
    # Notify user about level up (could integrate with notification system)
    create_level_up_notification(user, bonus_gold)
  end

  private

  def milestone_level?(level)
    level % 5 == 0 # Every 5 levels
  end

  def grant_milestone_rewards(user)
    case user.level
    when 5
      grant_item_reward(user, 'Iron Sword')
    when 10
      grant_item_reward(user, 'Chain Mail')
    when 15
      grant_item_reward(user, 'Healing Potion', 3)
    when 20
      grant_item_reward(user, 'Magic Ring')
    end
  end

  def grant_item_reward(user, item_name, quantity = 1)
    item = Item.find_by(name: item_name)
    return unless item

    user_item = user.user_items.find_or_initialize_by(item: item)
    user_item.quantity += quantity
    user_item.save!

    Rails.logger.info "Granted #{quantity}x #{item_name} to #{user.username}"
  end

  def create_level_up_notification(user, bonus_gold)
    # This could integrate with a notification system
    Rails.logger.info "Level up notification for #{user.username}: Level #{user.level}, +#{bonus_gold} gold"
  end
end