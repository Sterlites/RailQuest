# app/services/quest_service.rb
# Quest completion and management logic
class QuestService < ApplicationService
  def initialize(user, quest)
    @user = user
    @quest = quest
    @user_quest = user.user_quests.find_by(quest: quest)
  end

  def call
    return failure("User quest not found") unless @user_quest
    
    if can_complete?
      complete_quest
      success(rewards: calculate_rewards)
    else
      failure("Quest objectives not completed")
    end
  end

  def can_complete?
    return false unless @user_quest&.status == 'active'
    
    @quest.objectives.all? do |objective, required_count|
      current_progress = @user_quest.progress[objective] || 0
      current_progress >= required_count
    end
  end

  def complete_quest
    rewards = calculate_rewards
    
    ApplicationRecord.transaction do
      # Update quest status
      @user_quest.update!(
        status: 'completed',
        completed_at: Time.current
      )
      
      # Grant rewards
      grant_rewards(rewards)
      
      Rails.logger.info "#{@user.username} completed quest: #{@quest.name}"
    end
    
    # Queue background job for quest completion effects
    QuestCompleteJob.perform_later(@user, @quest, rewards)
  end

  def rewards_text
    rewards = calculate_rewards
    text_parts = []
    
    text_parts << "#{rewards[:experience]} experience" if rewards[:experience] > 0
    text_parts << "#{rewards[:gold]} gold" if rewards[:gold] > 0
    
    rewards[:items].each do |item_data|
      item = Item.find(item_data[:item_id])
      text_parts << "#{item.name} x#{item_data[:quantity]}"
    end
    
    text_parts.join(', ')
  end

  private

  def calculate_rewards
    quest_rewards = @quest.rewards || {}
    
    {
      experience: quest_rewards['experience'] || 0,
      gold: quest_rewards['gold'] || 0,
      items: quest_rewards['items'] || []
    }
  end

  def grant_rewards(rewards)
    # Experience and gold
    @user.gain_experience(rewards[:experience]) if rewards[:experience] > 0
    @user.update(gold: @user.gold + rewards[:gold]) if rewards[:gold] > 0
    
    # Items
    rewards[:items].each do |item_data|
      item = Item.find(item_data[:item_id])
      user_item = @user.user_items.find_or_initialize_by(item: item)
      user_item.quantity += item_data[:quantity]
      user_item.save!
    end
  end
end