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

  # Ensure the current item is always retrievable
  current_item = @tier_list.items.find_by(id: params[:item_id])

  if ranking.save
    # Find the next item to rank, considering the filtered items
    next_item = @tier_list.items.where('id > ?', params[:item_id]).first

    # Redirect to the next item or stay on the current item with success notice
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
  @tier_list = TierList.find(params[:id])
  @q = @tier_list.items.ransack(params[:q])

  @filtered_items = @q.result
  Rails.logger.debug "Ransack params: #{params[:q].inspect}"
  @items = @tier_list.items

  @current_item = find_current_item
  @field_types = @tier_list.custom_fields.map { |field| [field[:name], field[:data_type]] }
  Rails.logger.debug "Field Types: #{@field_types.inspect}"
  Rails.logger.debug "TierList: #{@tier_list.inspect}"
  Rails.logger.debug "Custom Fields: #{@tier_list.custom_fields.inspect}"
  @ranked_items = generate_ranked_items || []
  @filtered_ranked_items = @filtered_items.present? ? generate_filtered_ranked_items : []


end



  def show
    @tier_list = TierList.find(params[:id])
  

  end



  private

  def find_current_item
    @filtered_items.find_by(id: params[:item_id]) || @tier_list.items.find_by(id: params[:item_id])
  end
  
  def generate_ranked_items
    @tier_list.items.includes(:tier_list_rankings).map do |item|
      # Fetch the ranking for the current user for this item
      user_ranking = item.tier_list_rankings.find_by(ranked_by: current_user)
  
      {
        id: item.id,
        rank: user_ranking ? RANK_TO_TIER_MAP[user_ranking.rank.to_i] : "Unranked",
        name: item.name || "Unknown Item",
        image_url: item.image&.attached? ? url_for(item.image) : view_context.asset_path("egg.png"),
        custom_fields: item.custom_field_values || {}
      }
    end
  end

# Generate filtered ranked items
def generate_filtered_ranked_items
  @filtered_items.map do |item|
    # Fetch the ranking for the current user for this item
    user_ranking = item.tier_list_rankings.find_by(ranked_by: current_user)

    {
      id: item.id,
      rank: user_ranking ? RANK_TO_TIER_MAP[user_ranking.rank.to_i] : "Unranked",
      name: item.name || "Unknown Item",
      image_url: item.image&.attached? ? url_for(item.image) : view_context.asset_path("egg.png"),
      custom_fields: item.custom_field_values || {}
    }
  end.compact
end
  
  

 


  

end
