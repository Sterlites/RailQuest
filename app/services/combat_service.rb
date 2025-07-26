# app/services/combat_service.rb
# Complex business logic encapsulation
class CombatService < ApplicationService
  def initialize(user, enemy_name)
    @user = user
    @enemy_name = enemy_name
    @enemy_stats = generate_enemy_stats
    @combat_log = []
  end

  def call
    return failure("User is dead") if @user.dead?
    
    execute_combat_rounds
    
    result = determine_outcome
    log_combat_result(result)
    
    success(result)
  end

  def execute_combat
    call.data
  end

  private

  def generate_enemy_stats
    base_level = [@user.level - 2, 1].max
    level_variance = rand(-1..2)
    enemy_level = [base_level + level_variance, 1].max

    {
      name: @enemy_name,
      level: enemy_level,
      health: enemy_level * 15 + rand(10..30),
      max_health: enemy_level * 15 + rand(10..30),
      attack: enemy_level * 3 + rand(1..5),
      defense: enemy_level * 2 + rand(1..3),
      experience_reward: enemy_level * 10 + rand(5..15),
      gold_reward: enemy_level * 5 + rand(1..10)
    }
  end

  def execute_combat_rounds
    enemy_health = @enemy_stats[:health]
    
    @combat_log << "Combat begins against #{@enemy_name} (Level #{@enemy_stats[:level]})!"
    
    while @user.health > 0 && enemy_health > 0
      # User attacks first
      user_damage = calculate_damage(@user.total_attack_power, @enemy_stats[:defense])
      enemy_health -= user_damage
      @combat_log << "You deal #{user_damage} damage to #{@enemy_name}."
      
      break if enemy_health <= 0
      
      # Enemy attacks back
      enemy_damage = calculate_damage(@enemy_stats[:attack], @user.total_defense)
      @user.take_damage(enemy_damage)
      @combat_log << "#{@enemy_name} deals #{enemy_damage} damage to you."
      
      # Small chance for user to flee each round
      if rand < 0.1 # 10% chance to flee
        @combat_log << "You flee from combat!"
        return { outcome: 'fled', message: combat_summary }
      end
    end

    @final_enemy_health = enemy_health
  end

  def calculate_damage(attack, defense)
    base_damage = attack - (defense / 2)
    variance = rand(0.8..1.2)
    damage = (base_damage * variance).round
    
    [damage, 1].max # Minimum 1 damage
  end

  def determine_outcome
    if @user.dead?
      {
        outcome: 'defeat',
        message: combat_summary,
        experience_gained: 0,
        gold_gained: 0
      }
    elsif @final_enemy_health <= 0
      exp_gained = @enemy_stats[:experience_reward]
      gold_gained = @enemy_stats[:gold_reward]
      
      @user.gain_experience(exp_gained)
      @user.update(gold: @user.gold + gold_gained)
      
      @combat_log << "Victory! You gain #{exp_gained} experience and #{gold_gained} gold."
      
      {
        outcome: 'victory',
        message: combat_summary,
        experience_gained: exp_gained,
        gold_gained: gold_gained
      }
    else
      {
        outcome: 'fled',
        message: combat_summary,
        experience_gained: 0,
        gold_gained: 0
      }
    end
  end

  def combat_summary
    @combat_log.join(' ')
  end

  def log_combat_result(result)
    CombatLog.create!(
      user: @user,
      enemy_name: @enemy_name,
      log_data: @combat_log.to_json,
      result: result[:outcome],
      experience_gained: result[:experience_gained],
      gold_gained: result[:gold_gained]
    )
  end
end