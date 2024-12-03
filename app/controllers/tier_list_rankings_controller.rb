class TierListRankingsController < ApplicationController

  RANK_TO_TIER_MAP = {
    1 => "S",
    2 => "A",
    3 => "B",
    4 => "C",
    5 => "D",
    6 => "F"
}.freeze

  def create
    @tier_list = TierList.find(params[:tier_list_id])
  
    # Find the existing ranking for this item and current user, or initialize a new ranking
    ranking = @tier_list.tier_list_rankings.find_by(item_id: params[:item_id], ranked_by_id: current_user.id)
  
    # If no ranking exists, initialize a new one
    ranking ||= @tier_list.tier_list_rankings.new(item_id: params[:item_id], ranked_by_id: current_user.id)
  
    # Update the rank value
    ranking.rank = params[:rank]

    # Retrieve the current item for fallback use
    current_item = @tier_list.items.find(params[:item_id])
  
    if ranking.save
      # Find the next item to rank
      next_item = @tier_list.items.where('id > ?', params[:item_id]).first
  
      if next_item
        redirect_to rank_item_tier_list_path(@tier_list, next_item.id), notice: "Ranking saved successfully!"
      else
        redirect_to rank_item_tier_list_path(@tier_list, current_item.id), notice: "Ranking saved successfully!"
      end
    else
      redirect_to rank_item_tier_list_path(@tier_list, params[:item_id]),
                  alert: "Failed to save ranking: #{ranking.errors.full_messages.join(', ')}"
    end
  end

  def rank
    @tier_list = TierList.find(params[:id]) # Find the Tier List by ID
    @items = @tier_list.items              # Get all items in the tier list
    @current_item = @items.find_by(id: params[:item_id]) # Find the current item by item_id
  
    @ranked_items = @tier_list.tier_list_rankings.includes(:item).map do |ranking|
      next if ranking.item.nil? # Skip if the associated item is missing
  
      {
        id: ranking.item.id, # Include the unique item ID
        rank: RANK_TO_TIER_MAP[ranking.rank.to_i] || "Unranked", # Map rank or fallback
        name: ranking.item.name || "Unknown Item",               # Handle missing name
        image_url: if ranking.item&.image&.attached?
                     url_for(ranking.item.image)
                   else
                     view_context.asset_path("egg.png") # Provide a default placeholder image
                   end,
        custom_fields: ranking.item.custom_field_values || {}
      }
    end.compact # Remove any `nil` entries from the array
  
    if @current_item.nil?
      redirect_to tier_list_path(@tier_list), alert: "Item not found or no items available to rank."
    end
  end

  def show
    @tier_list = TierList.find(params[:id])
  

  end


  

end
