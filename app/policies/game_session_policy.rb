# app/policies/game_session_policy.rb
# Authorization for game session actions
class GameSessionPolicy < ApplicationPolicy
  def show?
    user_owns_session?
  end

  def update?
    user_owns_session? && user.alive?
  end

  private

  def user_owns_session?
    record.user == user
  end

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end
end