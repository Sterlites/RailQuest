# app/models/location.rb
# Demonstrates complex business logic and JSON field handling
class Location < ApplicationRecord
  # Associations
  has_many :game_sessions, foreign_key: 'current_location_id'
  has_many :users, through: :game_sessions

  # JSON field handling - Rails 7 approach
  serialize :exits, JSON
  serialize :items, JSON  
  serialize :npcs, JSON

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :required_level, presence: true, 
                            numericality: { greater_than: 0 }

  # Scopes
  scope :safe_zones, -> { where(safe_zone: true) }
  scope :for_level, ->(level) { where('required_level <= ?', level) }
  scope :with_items, -> { where.not(items: [nil, {}]) }
  scope :with_npcs, -> { where.not(npcs: [nil, {}]) }

  # Class methods
  def self.starting_location
    find_by(name: 'Town Square') || first
  end

  def self.random_location_for_level(level)
    for_level(level).sample
  end

  # Instance methods
  def exits
    super || {}
  end

  def items
    super || {}
  end

  def npcs
    super || {}
  end

  def available_exits
    exits.keys
  end

  def can_go?(direction)
    exits.key?(direction.to_s)
  end

  def exit_destination(direction)
    exit_id = exits[direction.to_s]
    return nil unless exit_id
    
    Location.find_by(id: exit_id)
  end

  def accessible_by?(user)
    user.level >= required_level
  end

  def has_items?
    items.present? && items.any?
  end

  def has_npcs?
    npcs.present? && npcs.any?
  end

  def item_list
    return [] unless has_items?
    
    Item.where(id: items.keys).map do |item|
      {
        item: item,
        quantity: items[item.id.to_s] || 1
      }
    end
  end

  def add_item(item, quantity = 1)
    current_items = items
    current_items[item.id.to_s] = (current_items[item.id.to_s] || 0) + quantity
    update(items: current_items)
  end

  def remove_item(item, quantity = 1)
    current_items = items
    current_quantity = current_items[item.id.to_s] || 0
    
    if current_quantity <= quantity
      current_items.delete(item.id.to_s)
    else
      current_items[item.id.to_s] = current_quantity - quantity
    end
    
    update(items: current_items)
  end

  def full_description
    desc = long_description.presence || description
    
    # Add exit information
    if available_exits.any?
      desc += "\n\nExits: #{available_exits.join(', ')}"
    end
    
    # Add item information
    if has_items?
      item_names = item_list.map { |i| "#{i[:item].name} (#{i[:quantity]})" }
      desc += "\n\nItems here: #{item_names.join(', ')}"
    end
    
    # Add NPC information
    if has_npcs?
      desc += "\n\nPeople here: #{npcs.values.join(', ')}"
    end
    
    desc
  end
end