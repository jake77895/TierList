class TierListRankingsController < ApplicationController

  def create
    # Find or initialize a ranking for the given tier list and item
    ranking = TierListRanking.find_or_initialize_by(
      tier_list_id: params[:tier_list_id],
      item_id: params[:item_id]
    )

    # Update the rank and who ranked it
    ranking.rank = params[:rank]
    ranking.ranked_by_id = current_user&.id # Assuming you have a current_user method

    if ranking.save
      flash[:success] = "Ranking saved successfully!"
    else
      flash[:error] = "Failed to save ranking: #{ranking.errors.full_messages.join(', ')}"
    end

    redirect_to tier_list_path(params[:tier_list_id]) # Redirect to the tier list or wherever needed
  end
  
end
