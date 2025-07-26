# app/models/item.rb
# Demonstrates enum-like behavior and complex validations
class Item < ApplicationRecord
  # Constants for item types - Rails convention for enums
  ITEM_TYPES = %w[weapon armor consumable quest_item].freeze
  EQUIPMENT_SLOTS = %w[head chest legs feet weapon shield ring].freeze

  # Associations
  has_many :user_items, dependent: :destroy
  has_many :users, through: :user_items

  # JSON handling
  serialize :properties, JSON

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :item_type, presence: true, inclusion: { in: ITEM_TYPES }
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :equipment_slot, inclusion: { in: EQUIPMENT_SLOTS }, 
                            allow_blank: true
  
  # Custom validations
  validate :equippable_items_must_have_slot
  validate :consumable_items_cannot_be_equippable

  # Scopes
  scope :weapons, -> { where(item_type: 'weapon') }
  scope :armor, -> { where(item_type: 'armor') }
  scope :consumables, -> { where(item_type: 'consumable') }
  scope :quest_items, -> { where(item_type: 'quest_item') }
  scope :equippable, -> { where(equippable: true) }
  scope :valuable, -> { where('value > ?', 100) }

  def properties
    super || {}
  end

  def weapon?
    item_type == 'weapon'
  end

  def armor?
    item_type == 'armor'
  end

  def consumable?
    item_type == 'consumable'
  end

  def quest_item?
    item_type == 'quest_item'
  end

  def attack_power
    properties['attack'] || 0
  end

  def defense_value
    properties['defense'] || 0
  end

  def healing_value
    properties['healing'] || 0
  end

  def mana_value
    properties['mana'] || 0
  end

  def use_effect(user)
    return false unless consumable?
    
    case properties['effect']
    when 'heal'
      user.heal(healing_value)
    when 'mana'
      user.update(mana: [user.mana + mana_value, user.max_mana].min)
    when 'experience'
      user.gain_experience(properties['experience'] || 0)
    end
    
    true
  end

  def can_be_used_by?(user)
    required_level = properties['required_level'] || 1
    user.level >= required_level
  end

  private

  def equippable_items_must_have_slot
    if equippable? && equipment_slot.blank?
      errors.add(:equipment_slot, "must be specified for equippable items")
    end
  end

  def consumable_items_cannot_be_equippable
    if consumable? && equippable?
      errors.add(:base, "items cannot be both consumable and equippable")
    end
  end
end