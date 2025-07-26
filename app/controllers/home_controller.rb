# app/controllers/home_controller.rb
# Simple controller demonstrating basic Rails patterns
class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:welcome]
  
  def welcome
    # Landing page for non-authenticated users
    redirect_to dashboard_path if user_signed_in?
  end

  def dashboard
    # User's main game dashboard
    authorize :dashboard, :show?
    
    @user = current_user
    @current_location = @current_session.current_location
    @recent_combat_logs = current_user.combat_logs.recent.limit(5)
    @active_quests = current_user.user_quests.where(status: 'active').includes(:quest)
    @equipped_items = current_user.equipped_items.includes(:item)
  end
end