# app/serializers/user_serializer.rb
# JSON:API compliant serializers
class UserSerializer
  include FastJsonapi::ObjectSerializer
  
  attributes :id, :username, :email, :level, :experience, :gold, 
             :health, :max_health, :mana, :max_mana, :created_at

  attribute :current_location do |user|
    user.current_location&.name
  end

  attribute :total_attack_power do |user|
    user.total_attack_power
  end

  attribute :total_defense do |user|
    user.total_defense
  end

  attribute :experience_to_next_level do |user|
    user.experience_to_next_level
  end

  has_many :equipped_items, serializer: UserItemSerializer
  has_many :active_quests, serializer: UserQuestSerializer
end