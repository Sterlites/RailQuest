# app/policies/quest_policy.rb
# Authorization for quest-related actions
class QuestPolicy < ApplicationPolicy
  def show?
    user.present?
  end

  def accept?
    user.present? && user.level >= record.required_level
  end

  def abandon?
    user.present? && user.user_quests.exists?(quest: record, status: 'active')
  end

  def complete?
    user.present? && user.user_quests.exists?(quest: record, status: 'active')
  end

  class Scope < Scope
    def resolve
      scope.all # All quests are visible to all users
    end
  end
end