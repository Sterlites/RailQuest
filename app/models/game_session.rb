# app/models/game_session.rb
# Demonstrates JSON storage, state management, and session handling
class GameSession < ApplicationRecord
  belongs_to :user
  belongs_to :current_location, class_name: 'Location'

  # JSON attribute handling - modern Rails approach for flexible data
  serialize :game_state, JSON

  validates :user_id, uniqueness: { scope: :active, 
                                   message: "can only have one active session" }, 
                     if: :active?

  # Scopes for common queries
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :recent, -> { where('last_action_at > ?', 1.hour.ago) }

  # Callbacks for session management
  before_create :deactivate_other_sessions
  after_update :update_last_action

  def game_state
    super || {}
  end

  def set_state(key, value)
    current_state = game_state
    current_state[key.to_s] = value
    update(game_state: current_state)
  end

  def get_state(key)
    game_state[key.to_s]
  end

  def active_time
    return 0 unless last_action_at && created_at
    
    last_action_at - created_at
  end

  def inactive?
    !active?
  end

  def deactivate!
    update(active: false)
  end

  private

  def deactivate_other_sessions
    return unless active?
    
    user.game_sessions.active.update_all(active: false)
  end

  def update_last_action
    return unless active?
    
    touch(:last_action_at) unless saved_change_to_last_action_at?
  end
end