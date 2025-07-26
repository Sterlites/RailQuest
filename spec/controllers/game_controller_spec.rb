# spec/controllers/game_controller_spec.rb
# Controller testing with authorization and complex scenarios
require 'rails_helper'

RSpec.describe GameController, type: :controller do
  let(:user) { create(:user) }
  let(:location) { create(:location, :starting_location) }
  let(:game_session) { create(:game_session, user: user, current_location: location) }

  before do
    sign_in user
    allow(user).to receive(:current_session).and_return(game_session)
  end

  describe 'GET #show' do
    it 'renders the game interface' do
      get :show
      expect(response).to have_http_status(:success)
      expect(assigns(:location)).to eq(location)
      expect(assigns(:user)).to eq(user)
    end

    it 'requires authentication' do
      sign_out user
      get :show
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'PATCH #move' do
    let(:destination) { create(:location, name: 'Forest') }

    before do
      location.update(exits: { 'north' => destination.id })
    end

    context 'with valid direction' do
      it 'moves user to new location' do
        patch :move, params: { direction: 'north' }
        expect(user.reload.current_location).to eq(destination)
        expect(response).to redirect_to(game_path)
        expect(flash[:notice]).to include('You move north')
      end
    end

    context 'with invalid direction' do
      it 'does not move user and shows error' do
        patch :move, params: { direction: 'south' }
        expect(user.reload.current_location).to eq(location)
        expect(flash[:alert]).to include("You can't go south")
      end
    end

    context 'when user level is too low' do
      let(:high_level_location) { create(:location, :high_level) }

      before do
        location.update(exits: { 'north' => high_level_location.id })
      end

      it 'prevents access and shows error' do
        patch :move, params: { direction: 'north' }
        expect(user.reload.current_location).to eq(location)
        expect(flash[:alert]).to include('You need to be level')
      end
    end
  end

  describe 'PATCH #take_item' do
    let(:item) { create(:item) }

    before do
      location.add_item(item, 1)
    end

    it 'adds item to user inventory' do
      expect {
        patch :take_item, params: { item_id: item.id }
      }.to change { user.user_items.count }.by(1)

      expect(user.user_items.last.item).to eq(item)
      expect(flash[:notice]).to include("You take the #{item.name}")
    end

    it 'removes item from location' do
      patch :take_item, params: { item_id: item.id }
      location.reload
      expect(location.items[item.id.to_s]).to be_nil
    end

    context 'when item is not in location' do
      it 'shows error message' do
        patch :take_item, params: { item_id: 999 }
        expect(flash[:alert]).to include('That item is not here')
      end
    end
  end

  describe 'PATCH #use_item' do
    let(:healing_potion) { create(:item, :healing_potion) }
    let(:user_item) { create(:user_item, user: user, item: healing_potion, quantity: 2) }

    before do
      user.update(health: 50, max_health: 100)
    end

    it 'uses consumable item and applies effect' do
      expect {
        patch :use_item, params: { user_item_id: user_item.id }
      }.to change { user.reload.health }.by(30)

      expect(user_item.reload.quantity).to eq(1)
      expect(flash[:notice]).to include("You use the #{healing_potion.name}")
    end

    it 'destroys user_item when quantity reaches 0' do
      user_item.update(quantity: 1)
      
      expect {
        patch :use_item, params: { user_item_id: user_item.id }
      }.to change { UserItem.count }.by(-1)
    end

    context 'with non-consumable item' do
      let(:weapon) { create(:item, :weapon) }
      let(:weapon_item) { create(:user_item, user: user, item: weapon) }

      it 'shows error message' do
        patch :use_item, params: { user_item_id: weapon_item.id }
        expect(flash[:alert]).to include("You can't use that item")
      end
    end
  end

  describe 'PATCH #equip_item' do
    let(:weapon) { create(:item, :weapon) }
    let(:user_item) { create(:user_item, user: user, item: weapon) }

    it 'equips the item' do
      patch :equip_item, params: { user_item_id: user_item.id }
      expect(user_item.reload.equipped).to be true
      expect(flash[:notice]).to include("You equip the #{weapon.name}")
    end

    it 'unequips items in the same slot' do
      old_weapon = create(:item, :weapon, name: 'Old Sword')
      old_user_item = create(:user_item, user: user, item: old_weapon, equipped: true)

      patch :equip_item, params: { user_item_id: user_item.id }
      
      expect(old_user_item.reload.equipped).to be false
      expect(user_item.reload.equipped).to be true
    end

    context 'when user level is too low' do
      let(:high_level_weapon) { create(:item, :weapon, properties: { 'required_level' => 10 }) }
      let(:high_level_user_item) { create(:user_item, user: user, item: high_level_weapon) }

      it 'prevents equipping and shows error' do
        patch :equip_item, params: { user_item_id: high_level_user_item.id }
        expect(high_level_user_item.reload.equipped).to be false
        expect(flash[:alert]).to include("You don't meet the requirements")
      end
    end
  end

  describe 'PATCH #rest' do
    before do
      user.update(health: 50, mana: 25, max_health: 100, max_mana: 50)
    end

    context 'in safe zone' do
      before do
        location.update(safe_zone: true)
      end

      it 'restores health and mana' do
        patch :rest
        user.reload
        expect(user.health).to eq(user.max_health)
        expect(user.mana).to eq(user.max_mana)
        expect(flash[:notice]).to include('You rest and feel refreshed')
      end
    end

    context 'not in safe zone' do
      it 'prevents resting and shows error' do
        patch :rest
        expect(flash[:alert]).to include("You can't rest here")
      end
    end
  end

  describe 'PATCH #combat' do
    it 'initiates combat with random enemy' do
      expect(CombatService).to receive(:new).with(user, anything).and_call_original
      expect_any_instance_of(CombatService).to receive(:execute_combat).and_return({
        outcome: 'victory',
        message: 'You defeated the enemy!',
        experience_gained: 25,
        gold_gained: 10
      })

      patch :combat
      expect(flash[:notice]).to include('Victory!')
    end

    it 'handles combat defeat' do
      expect_any_instance_of(CombatService).to receive(:execute_combat).and_return({
        outcome: 'defeat',
        message: 'You were defeated!',
        experience_gained: 0,
        gold_gained: 0
      })

      patch :combat
      expect(flash[:alert]).to include('Defeat!')
    end
  end

  describe 'authorization' do
    it 'redirects dead users to death path' do
      user.update(health: 0)
      get :show
      expect(response).to redirect_to(death_path)
    end

    it 'allows alive users to access game' do
      user.update(health: 50)
      get :show
      expect(response).to have_http_status(:success)
    end
  end
end