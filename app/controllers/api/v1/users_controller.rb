# app/controllers/api/v1/users_controller.rb
# RESTful API controller demonstrating JSON API patterns
class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update]

  def show
    render json: UserSerializer.new(@user).serialized_json
  end

  def update
    if @user.update(user_params)
      render json: UserSerializer.new(@user).serialized_json
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:username, :email)
  end
end