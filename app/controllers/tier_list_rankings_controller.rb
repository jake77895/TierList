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

  # Apply the filter logic to set @filtered_items
  @filtered_items = filter_items(@tier_list.items)

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
    next_item = @filtered_items.where('id > ?', params[:item_id]).first

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
  @tier_list = TierList.find(params[:id]) # Find the Tier List by ID
  @items = @tier_list.items              # Get all items in the tier list

  # Apply filters only to @filtered_items
  @filtered_items = filter_items(@tier_list.items)

  Rails.logger.debug "Filtered Items: #{@filtered_items.pluck(:id)}"
  Rails.logger.debug "All Items: #{@items.pluck(:id)}"

  # Use all items if no filters are applied or filtered list is empty
  if params[:commit] == "Clear All Filters" || @filtered_items.empty?
    @filtered_items = @items
    Rails.logger.debug "Cleared Filters: Using all items."
  end

  # Ensure the current item is included even if filters exclude it
  @current_item = @filtered_items.find_by(id: params[:item_id]) || @items.find_by(id: params[:item_id])
  Rails.logger.debug "Current Item: #{@current_item.inspect}"

  # If no items match the filters, show an alert
  flash[:alert] = "No items available with the applied filters." if @filtered_items.empty?

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
  Rails.logger.debug "Ranked Items: #{@ranked_items.inspect}"
end


  def show
    @tier_list = TierList.find(params[:id])
  

  end

  private

  def filter_items(items)
    filtered_items = items
  
    # Apply filters based on custom_field_values from params
    params.each do |key, value|
      next unless key.start_with?("filter_") && value.present?
  
      field_name = key.gsub("filter_", "").split("_").first
      if key.end_with?("_min")
        filtered_items = filtered_items.where("custom_field_values ->> ? >= ?", field_name, value)
      elsif key.end_with?("_max")
        filtered_items = filtered_items.where("custom_field_values ->> ? <= ?", field_name, value)
      else
        filtered_items = filtered_items.where("custom_field_values ->> ? = ?", field_name, value)
      end
    end
  
    # Return all items if no filters are applied
    filtered_items == items ? items : filtered_items
  end


  

end
