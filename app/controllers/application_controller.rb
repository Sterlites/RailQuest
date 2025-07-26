# app/controllers/application_controller.rb
# Base controller with common functionality and security
class ApplicationController < ActionController::Base
  # Rails security best practices
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user_session

  # Pundit authorization integration
  include Pundit::Authorization
  after_action :verify_authorized, except: :index, unless: :skip_authorization?
  after_action :verify_policy_scoped, only: :index, unless: :skip_authorization?

  # Error handling - production-ready approach
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  def set_current_user_session
    return unless user_signed_in?
    
    @current_session = current_user.current_session
    
    # Create session if user doesn't have an active one
    unless @current_session
      @current_session = current_user.game_sessions.create!(
        current_location: Location.starting_location
      )
    end
  end

  def skip_authorization?
    devise_controller? || 
    controller_name == 'home' ||
    action_name == 'welcome'
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  def record_not_found
    flash[:alert] = "The requested resource was not found."
    redirect_to root_path
  end
end