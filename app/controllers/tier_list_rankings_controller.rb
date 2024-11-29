class TierListRankingsController < ApplicationController

  def create
    @tier_list = TierList.find(params[:tier_list_id])
  
    # Find the existing ranking for this item and current user, or initialize a new ranking
    ranking = @tier_list.tier_list_rankings.find_by(item_id: params[:item_id], ranked_by_id: current_user.id)
  
    # If no ranking exists, initialize a new one
    ranking ||= @tier_list.tier_list_rankings.new(item_id: params[:item_id], ranked_by_id: current_user.id)
  
    # Update the rank value
    ranking.rank = params[:rank]
  
    if ranking.save
      # Find the next item to rank
      next_item = @tier_list.items.where('id > ?', params[:item_id]).first
  
      if next_item
        redirect_to rank_item_tier_list_path(@tier_list, next_item.id), notice: "Ranking saved successfully!"
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
      {
        rank: ranking.rank,
        name: ranking.item.name,
        image_url: ranking.item.image.attached? ? url_for(ranking.item.image) : nil
      }
    end
  
    if @current_item.nil?
      redirect_to tier_list_path(@tier_list), alert: "Item not found or no items available to rank."
    end
  
  end

  def show
    @tier_list = TierList.find(params[:id])
  

  end
  

end
