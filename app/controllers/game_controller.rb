# app/controllers/game_controller.rb
# Main game controller demonstrating complex business logic
class GameController < ApplicationController
  before_action :set_game_session
  before_action :check_user_alive, except: [:death, :respawn]

  def show
    authorize @current_session, :show?
    
    @location = @current_session.current_location
    @user = current_user
    @inventory_items = current_user.inventory_items.includes(:item)
  end

  def move
    authorize @current_session, :update?
    
    direction = params[:direction]&.downcase
    current_location = @current_session.current_location
    
    unless current_location.can_go?(direction)
      flash[:alert] = "You can't go #{direction} from here."
      redirect_to game_path and return
    end

    destination = current_location.exit_destination(direction)
    
    unless destination
      flash[:alert] = "That path seems to be blocked."
      redirect_to game_path and return
    end

    unless destination.accessible_by?(current_user)
      flash[:alert] = "You need to be level #{destination.required_level} to enter there."
      redirect_to game_path and return
    end

    if current_user.move_to_location(destination)
      flash[:notice] = "You move #{direction} to #{destination.name}."
      
      # Queue background job for location entry effects
      LocationEntryJob.perform_later(current_user, destination)
    else
      flash[:alert] = "Something went wrong while moving."
    end

    redirect_to game_path
  end

  def take_item
    authorize @current_session, :update?
    
    item_id = params[:item_id]
    location = @current_session.current_location
    
    unless location.items.key?(item_id.to_s)
      flash[:alert] = "That item is not here."
      redirect_to game_path and return
    end

    item = Item.find(item_id)
    
    # Add item to user's inventory
    user_item = current_user.user_items.find_or_initialize_by(item: item)
    user_item.quantity += 1
    
    if user_item.save
      location.remove_item(item, 1)
      flash[:notice] = "You take the #{item.name}."
    else
      flash[:alert] = "You can't take that item."
    end

    redirect_to game_path
  end

  def use_item
    authorize @current_session, :update?
    
    user_item = current_user.user_items.find(params[:user_item_id])
    item = user_item.item
    
    unless item.consumable?
      flash[:alert] = "You can't use that item."
      redirect_to game_path and return
      end

   unless item.can_be_used_by?(current_user)
     flash[:alert] = "You don't meet the requirements to use this item."
     redirect_to game_path and return
   end

   if item.use_effect(current_user)
     user_item.quantity -= 1
     
     if user_item.quantity <= 0
       user_item.destroy
     else
       user_item.save
     end
     
     flash[:notice] = "You use the #{item.name}."
     
     # Queue background job for item use effects
     ItemUseJob.perform_later(current_user, item)
   else
     flash[:alert] = "The item had no effect."
   end

   redirect_to game_path
 end

 def equip_item
   authorize @current_session, :update?
   
   user_item = current_user.user_items.find(params[:user_item_id])
   item = user_item.item
   
   unless item.equippable?
     flash[:alert] = "You can't equip that item."
     redirect_to game_path and return
   end

   unless item.can_be_used_by?(current_user)
     flash[:alert] = "You don't meet the requirements to equip this item."
     redirect_to game_path and return
   end

   # Unequip any item in the same slot
   current_user.user_items.joins(:item)
                          .where(equipped: true, 
                                items: { equipment_slot: item.equipment_slot })
                          .update_all(equipped: false)

   user_item.update(equipped: true)
   flash[:notice] = "You equip the #{item.name}."

   redirect_to game_path
 end

 def unequip_item
   authorize @current_session, :update?
   
   user_item = current_user.user_items.find(params[:user_item_id])
   
   user_item.update(equipped: false)
   flash[:notice] = "You unequip the #{user_item.item.name}."

   redirect_to game_path
 end

 def rest
   authorize @current_session, :update?
   
   location = @current_session.current_location
   
   unless location.safe_zone?
     flash[:alert] = "You can't rest here. Find a safe place first."
     redirect_to game_path and return
   end

   current_user.rest
   flash[:notice] = "You rest and feel refreshed. Health and mana restored!"

   redirect_to game_path
 end

 def combat
   authorize @current_session, :update?
   
   enemy_name = params[:enemy] || generate_random_enemy
   
   # Initiate combat - delegate to service object
   combat_service = CombatService.new(current_user, enemy_name)
   result = combat_service.execute_combat

   case result[:outcome]
   when 'victory'
     flash[:notice] = "Victory! #{result[:message]}"
   when 'defeat'
     flash[:alert] = "Defeat! #{result[:message]}"
   when 'fled'
     flash[:notice] = "You fled from combat."
   end

   redirect_to game_path
 end

 def death
   authorize @current_session, :show?
   
   unless current_user.dead?
     redirect_to game_path and return
   end
 end

 def respawn
   authorize @current_session, :update?
   
   current_user.update(health: current_user.max_health)
   current_user.move_to_location(Location.starting_location)
   
   flash[:notice] = "You have been revived and returned to town."
   redirect_to game_path
 end

 private

 def set_game_session
   @current_session = current_user.current_session
   
   unless @current_session
     @current_session = current_user.game_sessions.create!(
       current_location: Location.starting_location
     )
   end
 end

 def check_user_alive
   if current_user.dead?
     redirect_to death_path
   end
 end

 def generate_random_enemy
   enemies = ['Goblin', 'Orc', 'Skeleton', 'Wolf', 'Bandit']
   enemies.sample
 end
end