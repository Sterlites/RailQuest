# app/models/user.rb
# Demonstrates Rails associations, validations, callbacks, and business logic
class User < ApplicationRecord
  # Devise modules for authentication - Rails security best practice
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # ActiveRecord associations - demonstrates relationship modeling
  has_many :game_sessions, dependent: :destroy
  has_many :user_items, dependent: :destroy
  has_many :items, through: :user_items
  has_many :user_quests, dependent: :destroy
  has_many :quests, through: :user_quests
  has_many :combat_logs, dependent: :destroy
  
  # Current active session association
  has_one :current_session, -> { where(active: true) }, 
          class_name: 'GameSession'

  # ActiveRecord validations - data integrity best practices
  validates :username, presence: true, 
                      uniqueness: { case_sensitive: false },
                      length: { minimum: 3, maximum: 20 },
                      format: { with: /\A[a-zA-Z0-9_]+\z/, 
                               message: "only letters, numbers, and underscores allowed" }
  
  validates :level, presence: true, 
                   numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  
  validates :experience, presence: true, 
                        numericality: { greater_than_or_equal_to: 0 }
  
  validates :gold, presence: true, 
                  numericality: { greater_than_or_equal_to: 0 }
  
  validates :health, presence: true, 
                    numericality: { greater_than_or_equal_to: 0 }
  
  validates :max_health, presence: true, 
                        numericality: { greater_than: 0 }
  
  validates :mana, :max_mana, presence: true, 
                              numericality: { greater_than_or_equal_to: 0 }

  # Custom validations - business logic enforcement
  validate :health_cannot_exceed_max_health
  validate :mana_cannot_exceed_max_mana

  # ActiveRecord callbacks - automated business logic
  before_create :set_default_stats
  after_update :check_level_up, if: :saved_change_to_experience?
  after_create :create_starting_session

  # Scopes - reusable query patterns
  scope :by_level, ->(level) { where(level: level) }
  scope :high_level, -> { where('level >= ?', 10) }
  scope :recently_active, -> { joins(:game_sessions)
                                .where('game_sessions.last_action_at > ?', 1.hour.ago) }

  # Business logic methods - encapsulated game mechanics
  def alive?
    health > 0
  end

  def dead?
    !alive?
  end

  def can_afford?(cost)
    gold >= cost
  end

  def spend_gold(amount)
    return false unless can_afford?(amount)
    
    update(gold: gold - amount)
  end

  def gain_experience(amount)
    transaction do
      update!(experience: experience + amount)
      Rails.logger.info "#{username} gained #{amount} experience"
    end
  end

  def take_damage(amount)
    new_health = [health - amount, 0].max
    update(health: new_health)
    
    # Trigger death logic if health reaches 0
    handle_death if new_health == 0
  end

  def heal(amount)
    new_health = [health + amount, max_health].min
    update(health: new_health)
  end

  def rest
    # Full heal and mana restore - demonstrates business logic encapsulation
    update(health: max_health, mana: max_mana)
    Rails.logger.info "#{username} rested and restored health/mana"
  end

  def equipped_items
    user_items.equipped.includes(:item)
  end

  def inventory_items
    user_items.where(equipped: false).includes(:item)
  end

  def total_attack_power
    base_attack = level * 2
    weapon_bonus = equipped_items.joins(:item)
                                .where(items: { item_type: 'weapon' })
                                .sum { |ui| ui.item.properties['attack'] || 0 }
    base_attack + weapon_bonus
  end

  def total_defense
    base_defense = level
    armor_bonus = equipped_items.joins(:item)
                               .where(items: { item_type: 'armor' })
                               .sum { |ui| ui.item.properties['defense'] || 0 }
    base_defense + armor_bonus
  end

  # Method for calculating next level experience requirement
  def experience_to_next_level
    return 0 if level >= 100
    
    (level * 100) - (experience % (level * 100))
  end

  # Active session management
  def current_location
    current_session&.current_location || Location.starting_location
  end

  def move_to_location(location)
    return false unless current_session
    
    current_session.update(
      current_location: location,
      last_action_at: Time.current
    )
  end

  private

  def health_cannot_exceed_max_health
    errors.add(:health, "cannot exceed maximum health") if health > max_health
  end

  def mana_cannot_exceed_max_mana
    errors.add(:mana, "cannot exceed maximum mana") if mana > max_mana
  end

  def set_default_stats
    self.health = max_health if health.nil?
    self.mana = max_mana if mana.nil?
  end

  def check_level_up
    # Calculate required experience for current level
    required_exp = level * 100
    
    if experience >= required_exp
      new_level = level + 1
      update_columns(
        level: new_level,
        max_health: max_health + 10,
        max_mana: max_mana + 5,
        health: max_health + 10, # Full heal on level up
        mana: max_mana + 5
      )
      
      Rails.logger.info "#{username} leveled up to level #{new_level}!"
      
      # Queue background job for level up rewards
      LevelUpRewardJob.perform_later(self)
    end
  end

  def create_starting_session
    GameSession.create!(user: self, current_location: Location.starting_location)
  end

  def handle_death
    Rails.logger.info "#{username} has died!"
    
    # Reset to starting location with reduced gold
    penalty_gold = (gold * 0.1).to_i
    update(
      health: max_health,
      gold: gold - penalty_gold
    )
    
    current_session&.update(current_location: Location.starting_location)
    
    # Queue background job for death processing
    DeathPenaltyJob.perform_later(self, penalty_gold)
  end
end