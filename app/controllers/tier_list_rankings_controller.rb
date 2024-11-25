class TierListRankingsController < ApplicationController
  
  def create
    @tier_list = TierList.find(params[:tier_list_id]) # Finds the tier list from the nested route
    ranking = @tier_list.tier_list_rankings.find_or_initialize_by(
      item_id: params[:item_id]
    )

    # Update ranking attributes
    ranking.rank = params[:rank]
    ranking.ranked_by_id = current_user.id

    # Save and handle success or failure
    if ranking.save
      notice = "Ranking saved successfully!"
    else
      alert = "Failed to save ranking: #{ranking.errors.full_messages.join(', ')}"
    end

    # Redirect back to the rank page for the same tier list
    redirect_to rank_tier_list_path(@tier_list), notice: notice, alert: alert
  end

  def rank
    @tier_list = TierList.find(params[:id]) # Finds the tier list by ID
    @items = @tier_list.items
    @current_item = @items.first # Example: Set the first item initially
  end

end
