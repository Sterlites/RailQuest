# app/controllers/quests_controller.rb
# RESTful controller for quest management
class QuestsController < ApplicationController
  before_action :set_quest, only: [:show, :accept, :abandon, :complete]

  def index
    @available_quests = policy_scope(Quest.where.not(
      id: current_user.user_quests.select(:quest_id)
    )).for_level(current_user.level)
    
    @active_quests = policy_scope(
      current_user.user_quests.active.includes(:quest)
    )
    
    @completed_quests = policy_scope(
      current_user.user_quests.completed.includes(:quest)
    ).recent.limit(10)
  end

  def show
    authorize @quest, :show?
    
    @user_quest = current_user.user_quests.find_by(quest: @quest)
  end

  def accept
    authorize @quest, :accept?
    
    if current_user.level < @quest.required_level
      flash[:alert] = "You need to be level #{@quest.required_level} to accept this quest."
      redirect_to quests_path and return
    end

    if current_user.user_quests.exists?(quest: @quest, status: 'active')
      flash[:alert] = "You already have this quest active."
      redirect_to quests_path and return
    end

    user_quest = current_user.user_quests.build(
      quest: @quest,
      status: 'active',
      progress: @quest.objectives.transform_values { 0 },
      started_at: Time.current
    )

    if user_quest.save
      flash[:notice] = "Quest accepted: #{@quest.name}"
      
      # Queue background job for quest start effects
      QuestStartJob.perform_later(current_user, @quest)
    else
      flash[:alert] = "Unable to accept quest."
    end

    redirect_to quests_path
  end

  def abandon
    authorize @quest, :abandon?
    
    user_quest = current_user.user_quests.find_by(quest: @quest, status: 'active')
    
    unless user_quest
      flash[:alert] = "You don't have this quest active."
      redirect_to quests_path and return
    end

    user_quest.update(status: 'abandoned')
    flash[:notice] = "Quest abandoned: #{@quest.name}"

    redirect_to quests_path
  end

  def complete
    authorize @quest, :complete?
    
    user_quest = current_user.user_quests.find_by(quest: @quest, status: 'active')
    
    unless user_quest
      flash[:alert] = "You don't have this quest active."
      redirect_to quests_path and return
    end

    # Check if quest objectives are completed
    quest_service = QuestService.new(current_user, @quest)
    
    if quest_service.can_complete?
      quest_service.complete_quest
      flash[:notice] = "Quest completed: #{@quest.name}! #{quest_service.rewards_text}"
    else
      flash[:alert] = "Quest objectives not yet completed."
    end

    redirect_to quests_path
  end

  private

  def set_quest
    @quest = Quest.find(params[:id])
  end
end