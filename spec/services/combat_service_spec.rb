# spec/services/combat_service_spec.rb
# Service object testing demonstrating business logic testing
require 'rails_helper'

RSpec.describe CombatService, type: :service do
  let(:user) { create(:user, level: 5, health: 100, max_health: 100) }
  let(:enemy_name) { 'Test Goblin' }
  let(:service) { described_class.new(user, enemy_name) }

  describe '#call' do
    context 'when user is alive' do
      it 'returns successful result' do
        result = service.call
        expect(result.success?).to be true
        expect(result.data).to include(:outcome, :message)
      end

      it 'creates combat log' do
        expect { service.call }.to change { CombatLog.count }.by(1)
        
        combat_log = CombatLog.last
        expect(combat_log.user).to eq(user)
        expect(combat_log.enemy_name).to eq(enemy_name)
      end
    end

    context 'when user is dead' do
      before { user.update(health: 0) }

      it 'returns failure result' do
        result = service.call
        expect(result.failure?).to be true
        expect(result.error).to eq("User is dead")
      end
    end
  end

  describe '#execute_combat' do
    it 'returns combat result data' do
      result = service.execute_combat
      expect(result).to include(:outcome, :message, :experience_gained, :gold_gained)
    end

    context 'when user wins' do
      before do
        # Mock combat to ensure user victory
        allow(service).to receive(:calculate_damage).and_return(50, 1)
      end

      it 'grants experience and gold' do
        initial_exp = user.experience
        initial_gold = user.gold

        result = service.execute_combat
        user.reload

        expect(result[:outcome]).to eq('victory')
        expect(user.experience).to be > initial_exp
        expect(user.gold).to be > initial_gold
      end
    end

    context 'when user loses' do
      before do
        # Mock combat to ensure user defeat
        allow(service).to receive(:calculate_damage).and_return(1, 150)
      end

      it 'does not grant rewards' do
        initial_exp = user.experience
        initial_gold = user.gold

        result = service.execute_combat
        user.reload

        expect(result[:outcome]).to eq('defeat')
        expect(user.experience).to eq(initial_exp)
        expect(user.gold).to eq(initial_gold)
      end
    end
  end

  describe 'private methods' do
    describe '#generate_enemy_stats' do
      it 'generates stats appropriate for user level' do
        enemy_stats = service.send(:generate_enemy_stats)
        
        expect(enemy_stats).to include(:name, :level, :health, :attack, :defense)
        expect(enemy_stats[:name]).to eq(enemy_name)
        expect(enemy_stats[:level]).to be_between(3, 7) # User level ±2
      end
    end

    describe '#calculate_damage' do
      it 'calculates damage with variance' do
        damage = service.send(:calculate_damage, 20, 5)
        expect(damage).to be >= 1
        expect(damage).to be <= 30 # Max possible with variance
      end

      it 'ensures minimum damage of 1' do
        damage = service.send(:calculate_damage, 1, 10)
        expect(damage).to eq(1)
      end
    end
  end
end