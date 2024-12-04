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

  # Extract unique options for each custom field
  @unique_field_values = @tier_list.items.each_with_object({}) do |item, hash|
    item.custom_field_values.each do |key, value|
      # Normalize value to lowercase and exclude empty strings
      normalized_value = value.to_s.strip.downcase
      next if normalized_value.empty?
  
      hash[key] ||= []
      hash[key] << value.strip unless hash[key].include?(value.strip)
    end
  end
  
  @unique_field_values.transform_values!(&:uniq)

  Rails.logger.debug "Unique Field Values: #{@unique_field_values.inspect}"

  if params[:commit] == "Clear All Filters" # Check if "Clear All Filters" was pressed
    @filtered_items = nil
    flash[:notice] = "All filters cleared. Showing all items."
  else
    # Apply filters only to @filtered_items
    @filtered_items = filter_items(@tier_list.items)
    flash[:alert] = "No items available with the applied filters." if @filtered_items.empty?
  end

  # Ensure the current item is included even if filters exclude it
  # @current_item = if @filtered_items&.any?
  #   @filtered_items.find_by(id: params[:item_id])
  # else
  #   @items.find_by(id: params[:item_id])
  # end

  @current_item = @items.find_by(id: params[:item_id])

  # Clear previous flash messages to avoid overlap
  flash.discard(:notice)
  flash.discard(:alert)

  # Generate ranked items based on filters
  @ranked_items = @tier_list.tier_list_rankings.includes(:item).map do |ranking|
    next if ranking.item.nil? || (@filtered_items.present? && !@filtered_items.include?(ranking.item))

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

  # Pass the filtered items explicitly to the partial
  @filtered_ranked_items = @ranked_items.select { |item| @filtered_items.pluck(:id).include?(item[:id]) } if @filtered_items.present?
  
end




  def show
    @tier_list = TierList.find(params[:id])
  

  end

  private

  def filter_items(items)
    filtered_items = items
    min_conditions = {}
    max_conditions = {}
  
    # Apply filters based on custom_field_values from params
    params.each do |key, value|
      next unless key.start_with?("filter_") && value.present?
  
      field_name = key.gsub("filter_", "").split("_").first

      Rails.logger.debug "Filter params: #{params.inspect}"

      # Apply the appropriate filter based on the parameter type
      if value.is_a?(Array)
        # Ensure case-insensitive match and remove spaces
        filtered_items = filtered_items.where(
          "LOWER(custom_field_values ->> ?) IN (?)",
          field_name,
          value.map { |v| v.downcase.strip }
        )
      elsif key.end_with?("_min")
        # Apply minimum filter for numeric values
        filtered_items = filtered_items.where("custom_field_values ->> ? IS NOT NULL AND CAST(custom_field_values ->> ? AS numeric) >= ?", field_name, field_name, value)
      elsif key.end_with?("_max")
        # Apply maximum filter for numeric values
        if value == ""
          Rails.logger.debug "Skipping max filter for #{field_name} due to empty string value"
          next
        end
        filtered_items = filtered_items.where("custom_field_values ->> ? IS NOT NULL AND CAST(custom_field_values ->> ? AS numeric) <= ?", field_name, field_name, value)
      else
        # Handle exact match for single string values
        filtered_items = filtered_items.where(
          "LOWER(custom_field_values ->> ?) = ?",
          field_name,
          value.downcase.strip
        )
      end
  
      if key.end_with?("_min")
        min_conditions[field_name] = value
        Rails.logger.debug "Min condition for #{field_name}: #{min_conditions[field_name]}"
      elsif key.end_with?("_max")
        # Apply maximum filter for numeric values, ensuring values are greater than or equal to 0
        filtered_items = filtered_items.where(
          "custom_field_values ->> ? IS NOT NULL AND CAST(custom_field_values ->> ? AS numeric) >= 0 AND CAST(custom_field_values ->> ? AS numeric) <= ?",
          field_name, field_name, field_name, value
        )
      else
        Rails.logger.debug "Applying exact match filter for #{field_name} with value: #{value}"
        filtered_items = filtered_items.where("custom_field_values ->> ? = ?", field_name, value)
      end
    end
  
    # Apply min and max conditions after gathering them
    min_conditions.each do |field, min_value|
      min_value = min_value.presence || 0
      Rails.logger.debug "Applying min condition: Field = #{field}, Min Value = #{min_value}"
      filtered_items = filtered_items.where("custom_field_values ->> ? >= ?", field, min_value)
    end
    
    max_conditions.each do |field, max_value|
      Rails.logger.debug "Applying max condition: Field = #{field}, Max Value = #{max_value}"
      filtered_items = filtered_items.where("custom_field_values ->> ? <= ?", field, max_value)
    end

  
    # Return all items if no filters are applied
    filtered_items == items ? items : filtered_items
  end

  
  

 


  

end
