# app/controllers/api/v1/base_controller.rb
# Base API controller with common functionality
class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  before_action :authenticate_api_user
  before_action :set_default_format
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  protected

  def authenticate_api_user
    authenticate_or_request_with_http_token do |token, options|
      @current_user = User.find_by(api_token: token)
    end
  end

  def current_user
    @current_user
  end

  def set_default_format
    request.format = :json
  end

  private

  def not_found(exception)
    render json: { 
      error: 'Resource not found',
      message: exception.message 
    }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { 
      error: 'Validation failed',
      messages: exception.record.errors.full_messages 
    }, status: :unprocessable_entity
  end

  def forbidden
    render json: { 
      error: 'Access denied',
      message: 'You are not authorized to perform this action' 
    }, status: :forbidden
  end
end