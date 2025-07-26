# app/controllers/inventory_controller.rb
# RESTful controller for inventory management
class InventoryController < ApplicationController
  def index
    authorize :inventory, :show?
    
    @inventory_items = policy_scope(current_user.inventory_items.includes(:item))
    @equipped_items = policy_scope(current_user.equipped_items.includes(:item))
    
    # Group items by type for better UI
    @grouped_inventory = @inventory_items.group_by { |ui| ui.item.item_type }
  end

  def show
    @user_item = current_user.user_items.find(params[:id])
    authorize @user_item, :show?
  end
end