# spec/models/user_spec.rb
# Comprehensive model testing demonstrating Rails testing best practices
require 'rails_helper'

RSpec.describe User, type: :model do
  # Test associations
  describe 'associations' do
    it { should have_many(:game_sessions).dependent(:destroy) }
    it { should have_many(:user_items).dependent(:destroy) }
    it { should have_many(:items).through(:user_items) }
    it { should have_many(:user_quests).dependent(:destroy) }
    it { should have_many(:quests).through(:user_quests) }
    it { should have_many(:combat_logs).dependent(:destroy) }
    it { should have_one(:current_session) }
  end

  # Test validations
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_length_of(:username).is_at_least(3).is_at_most(20) }
    it { should allow_value('ValidUser123').for(:username) }
    it { should allow_value('test_user').for(:username) }
    it { should_not allow_value('invalid-user').for(:username) }
    it { should_not allow_value('invalid user').for(:username) }

    it { should validate_presence_of(:level) }
    it { should validate_numericality_of(:level).is_greater_than(0).is_less_than_or_equal_to(100) }

    it { should validate_presence_of(:experience) }
    it { should validate_numericality_of(:experience).is_greater_than_or_equal_to(0) }

    it { should validate_presence_of(:gold) }
    it { should validate_numericality_of(:gold).is_greater_than_or_equal_to(0) }

    it { should validate_presence_of(:health) }
    it { should validate_numericality_of(:health).is_greater_than_or_equal_to(0) }

    it { should validate_presence_of(:max_health) }
    it { should validate_numericality_of(:max_health).is_greater_than(0) }

    describe 'custom validations' do
      it 'validates health cannot exceed max_health' do
        user = build(:user, health: 150, max_health: 100)
        expect(user).not_to be_valid
        expect(user.errors[:health]).to include("cannot exceed maximum health")
      end

      it 'validates mana cannot exceed max_mana' do
        user = build(:user, mana: 75, max_mana: 50)
        expect(user).not_to be_valid
        expect(user.errors[:mana]).to include("cannot exceed maximum mana")
      end
    end
  end

  # Test scopes
  describe 'scopes' do
    let!(:level_5_user) { create(:user, level: 5) }
    let!(:level_10_user) { create(:user, level: 10) }
    let!(:level_15_user) { create(:user, level: 15) }

    describe '.by_level' do
      it 'returns users of specified level' do
        expect(User.by_level(5)).to include(level_5_user)
        expect(User.by_level(5)).not_to include(level_10_user)
      end
    end

    describe '.high_level' do
      it 'returns users level 10 and above' do
        high_level_users = User.high_level
        expect(high_level_users).to include(level_10_user, level_15_user)
        expect(high_level_users).not_to include(level_5_user)
      end
    end
  end

  # Test instance methods
  describe 'instance methods' do
    let(:user) { create(:user, health: 50, max_health: 100) }

    describe '#alive?' do
      it 'returns true when health is above 0' do
        expect(user.alive?).to be true
      end

      it 'returns false when health is 0' do
        user.update(health: 0)
        expect(user.alive?).to be false
      end
    end

    describe '#dead?' do
      it 'returns opposite of alive?' do
        expect(user.dead?).to eq(!user.alive?)
      end
    end

    describe '#can_afford?' do
      it 'returns true when user has enough gold' do
        user.update(gold: 100)
        expect(user.can_afford?(50)).to be true
      end

      it 'returns false when user does not have enough gold' do
        user.update(gold: 30)
        expect(user.can_afford?(50)).to be false
      end
    end

    describe '#spend_gold' do
      before { user.update(gold: 100) }

      it 'reduces gold when user can afford it' do
        expect { user.spend_gold(30) }.to change { user.reload.gold }.from(100).to(70)
      end

      it 'returns true when successful' do
        expect(user.spend_gold(30)).to be true
      end

      it 'does not reduce gold when user cannot afford it' do
        expect { user.spend_gold(150) }.not_to change { user.reload.gold }
      end

      it 'returns false when unsuccessful' do
        expect(user.spend_gold(150)).to be false
      end
    end

    describe '#gain_experience' do
      it 'increases experience' do
        expect { user.gain_experience(50) }.to change { user.reload.experience }.by(50)
      end

      it 'triggers level up when enough experience is gained' do
        user.update(level: 1, experience: 80)
        expect { user.gain_experience(30) }.to change { user.reload.level }.from(1).to(2)
      end
    end

    describe '#take_damage' do
      it 'reduces health by damage amount' do
        expect { user.take_damage(20) }.to change { user.reload.health }.from(50).to(30)
      end

      it 'does not reduce health below 0' do
        user.take_damage(100)
        expect(user.reload.health).to eq(0)
      end

      it 'handles death when health reaches 0' do
        expect(user).to receive(:handle_death)
        user.take_damage(100)
      end
    end

    describe '#heal' do
      it 'increases health by heal amount' do
        expect { user.heal(30) }.to change { user.reload.health }.from(50).to(80)
      end

      it 'does not increase health above max_health' do
        user.heal(100)
        expect(user.reload.health).to eq(user.max_health)
      end
    end

    describe '#rest' do
      before do
        user.update(health: 50, mana: 25, max_health: 100, max_mana: 50)
      end

      it 'restores health to maximum' do
        user.rest
        expect(user.reload.health).to eq(user.max_health)
      end

      it 'restores mana to maximum' do
        user.rest
        expect(user.reload.mana).to eq(user.max_mana)
      end
    end

    describe '#experience_to_next_level' do
      it 'calculates experience needed for next level' do
        user.update(level: 5, experience: 450)
        expect(user.experience_to_next_level).to eq(50) # 500 - 450
      end

      it 'returns 0 for max level users' do
        user.update(level: 100)
        expect(user.experience_to_next_level).to eq(0)
      end
    end

    describe '#total_attack_power' do
      it 'calculates total attack including equipment' do
        user.update(level: 5)
        weapon = create(:item, :weapon, properties: { 'attack' => 15 })
        create(:user_item, user: user, item: weapon, equipped: true)

        expected_attack = (5 * 2) + 15 # base + weapon
        expect(user.total_attack_power).to eq(expected_attack)
      end
    end

    describe '#total_defense' do
      it 'calculates total defense including equipment' do
        user.update(level: 5)
        armor = create(:item, :armor, properties: { 'defense' => 8 })
        create(:user_item, user: user, item: armor, equipped: true)

        expected_defense = 5 + 8 # base + armor
        expect(user.total_defense).to eq(expected_defense)
      end
    end
  end

  # Test callbacks
  describe 'callbacks' do
    describe 'before_create' do
      it 'sets default stats' do
        user = build(:user, health: nil, mana: nil)
        user.save
        expect(user.health).to eq(user.max_health)
        expect(user.mana).to eq(user.max_mana)
      end
    end

    describe 'after_create' do
      it 'creates starting game session' do
        user = build(:user)
        expect { user.save }.to change { GameSession.count }.by(1)
        expect(user.reload.current_session).to be_present
      end
    end

    describe 'after_update' do
      it 'checks for level up when experience changes' do
        user = create(:user, level: 1, experience: 80)
        expect(user).to receive(:check_level_up)
        user.update(experience: 110)
      end
    end
  end
end