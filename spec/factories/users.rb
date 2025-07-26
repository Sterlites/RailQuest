# spec/factories/users.rb
# Factory Bot factories for test data
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "TestUser#{n}" }
    password { 'password123' }
    level { 1 }
    experience { 0 }
    gold { 100 }
    health { 100 }
    max_health { 100 }
    mana { 50 }
    max_mana { 50 }

    # Traits for different user states
    trait :high_level do
      level { 10 }
      experience { 950 }
      max_health { 190 }
      max_mana { 95 }
      health { 190 }
      mana { 95 }
    end

    trait :dead do
      health { 0 }
    end

    trait :rich do
      gold { 10000 }
    end

    # After creation callbacks
    after(:create) do |user|
      # Ensure user has a game session
      create(:game_session, user: user) unless user.current_session
    end
  end

  factory :game_session do
    user
    association :current_location, factory: :location
    active { true }
    game_state { {} }
    last_action_at { Time.current }
  end

  factory :location do
    sequence(:name) { |n| "Test Location #{n}" }
    description { "A test location for automated testing." }
    long_description { "This is a longer description of the test location." }
    exits { { 'north' => 1, 'south' => 2 } }
    items { {} }
    npcs { {} }
    safe_zone { false }
    required_level { 1 }

    trait :safe_zone do
      safe_zone { true }
      name { "Safe Haven" }
    end

    trait :high_level do
      required_level { 10 }
      name { "Dangerous Area" }
    end

    trait :starting_location do
      name { "Town Square" }
      safe_zone { true }
      required_level { 1 }
    end
  end

  factory :item do
    sequence(:name) { |n| "Test Item #{n}" }
    description { "A test item for automated testing." }
    item_type { 'consumable' }
    value { 10 }
    properties { {} }
    consumable { true }
    equippable { false }

    trait :weapon do
      item_type { 'weapon' }
      consumable { false }
      equippable { true }
      equipment_slot { 'weapon' }
      properties { { 'attack' => 10 } }
    end

    trait :armor do
      item_type { 'armor' }
      consumable { false }
      equippable { true }
      equipment_slot { 'chest' }
      properties { { 'defense' => 5 } }
    end

    trait :healing_potion do
      name { 'Health Potion' }
      item_type { 'consumable' }
      properties { { 'healing' => 30, 'effect' => 'heal' } }
    end
  end

  factory :user_item do
    user
    item
    quantity { 1 }
    equipped { false }

    trait :equipped do
      equipped { true }
      association :item, factory: [:item, :weapon]
    end
  end

  factory :quest do
    sequence(:name) { |n| "Test Quest #{n}" }
    description { "A test quest for automated testing." }
    objectives { { 'kill_enemy_goblin' => 5 } }
    rewards { { 'experience' => 100, 'gold' => 50 } }
    required_level { 1 }
    repeatable { false }
  end

  factory :user_quest do
    user
    quest
    status { 'active' }
    progress { {} }
    started_at { Time.current }

    trait :completed do
      status { 'completed' }
      completed_at { Time.current }
    end
  end

  factory :combat_log do
    user
    enemy_name { 'Test Enemy' }
    log_data { ['Combat started', 'Victory achieved'].to_json }
    result { 'victory' }
    experience_gained { 25 }
    gold_gained { 10 }
  end
end