class TierListsController < ApplicationController
  before_action :set_tier_list, only: %i[ show edit update destroy ]

  RANK_TO_TIER_MAP = {
    1 => "S",
    2 => "A",
    3 => "B",
    4 => "C",
    5 => "D",
    6 => "F",
  }.freeze

  def your_list
    @tier_list = TierList.find(params[:id])
    # Add any specific logic for "Your List" view
    render "tier_list_rankings/rank"
  end

  def creator_list
    @tier_list = TierList.find(params[:id])

    # Fetch ranked items specific to the creator
    @creator_ranked_items = @tier_list.items.joins(:tier_list_rankings)
      .where(tier_list_rankings: { ranked_by: @tier_list.created_by_id })
      .select("items.*, tier_list_rankings.rank as rank")

    # Define the current item (e.g., the first ranked item for the creator)
    @current_item = @creator_ranked_items.first

    # Set up Ransack for filtering
    @q = @tier_list.items.ransack(params[:q])
    @filtered_items = @q.result # Filtered items based on query
    @field_types = @tier_list.custom_fields.map { |field| [field[:name], field[:data_type]] }

    # Fetch filtered or all ranked items for the creator
    @filtered_ranked_items = @filtered_items.present? ? generate_filtered_creator_ranked_items : generate_creator_ranked_items

    # Fetch ranked items specific to the creator
    @ranked_items = generate_creator_ranked_items || []

    # Pass the rank-to-tier map to the view
    @rank_to_tier_map = RANK_TO_TIER_MAP

    render "tier_list_creator/creator_view"
  end

  def group_list
    @tier_list = TierList.find(params[:id])
    # Add any specific logic for "Group List" view
    render "tier_list_group/show"
  end

  def rank
    @tier_list = TierList.find(params[:id])

    @items = @tier_list.items.with_attached_image.order(updated_at: :desc).map do |item|
      {
        id: item.id,
        name: item.name,
        description: item.description,
        image_url: item.image.attached? ? url_for(item.image) : nil,
      }
    end

    @current_item = @items.first
  end

  def publish
    @tier_list = TierList.find(params[:id])

    if @tier_list.update(published: true)
      first_item = @tier_list.items.first # Select the first item or a specific one
      if first_item
        redirect_to rank_item_tier_list_path(@tier_list, first_item.id), notice: "Published tier list."
      else
        redirect_to @tier_list, alert: "Tier list published, but no items available to rank."
      end
    else
      redirect_to @tier_list, alert: "Failed to publish the tier list."
    end
  end

  # GET /tier_lists or /tier_lists.json
  def index
    @tier_lists = TierList.all
  end

  # GET /tier_lists/1 or /tier_lists/1.json
  def show
    @tier_list = TierList.find(params[:id])
    @tier_list_items = @tier_list.items.order(updated_at: :desc) # Fetch items ordered by `updated_at`
  end

  # GET /tier_lists/new
  def new
    @tier_list = TierList.new
    @tier_list.custom_fields ||= [] # Ensure it's initialized as an array
    (10 - @tier_list.custom_fields.size).times do
      @tier_list.custom_fields << { name: "", data_type: "" }
    end
  end

  # GET /tier_lists/1/edit
  def edit
    @tier_list = TierList.find(params[:id])

    # Ensure `custom_fields` is initialized and has at least 5 entries
    @tier_list.custom_fields ||= []
    (10 - @tier_list.custom_fields.size).times do
      @tier_list.custom_fields << { name: "", data_type: "" }
    end
  end

  def create

    # Initialize TierList
    @tier_list = TierList.new(tier_list_params.except(:custom_fields))
    Rails.logger.debug "Initialized TierList: #{@tier_list.inspect}"

    # Extract and assign custom fields from the separate custom_fields key
    custom_fields = params[:custom_fields]&.values || [] # Safely access values
    Rails.logger.debug "Raw Custom Fields from Params: #{custom_fields.inspect}"

    # Convert each field into a plain hash and filter out blanks
    filtered_fields = custom_fields.reject { |field| field["name"].blank? && field["data_type"].blank? }
    Rails.logger.debug "Filtered Custom Fields: #{filtered_fields.inspect}"

    @tier_list.custom_fields = filtered_fields.map { |field| field.to_h.symbolize_keys }
    Rails.logger.debug "Custom Fields Assigned to TierList: #{@tier_list.custom_fields.inspect}"

    # Save and respond
    if @tier_list.save
      Rails.logger.debug "Save Successful: #{@tier_list.inspect}"
      redirect_to tier_list_url(@tier_list), notice: "Tier list was successfully created."
    else
      Rails.logger.debug "Save Failed: #{@tier_list.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @tier_list = TierList.find(params[:id])

    # Update tier list attributes except custom fields
    @tier_list.assign_attributes(tier_list_params.except(:custom_fields))
    Rails.logger.debug "Updated Tier List Attributes: #{@tier_list.inspect}"

    # Extract and assign custom fields
    custom_fields = params[:custom_fields]&.values || [] # Safely access values
    Rails.logger.debug "Raw Custom Fields from Params: #{custom_fields.inspect}"

    filtered_fields = custom_fields.reject { |field| field["name"].blank? && field["data_type"].blank? }
    Rails.logger.debug "Filtered Custom Fields: #{filtered_fields.inspect}"

    @tier_list.custom_fields = filtered_fields.map { |field| field.to_h.symbolize_keys }
    Rails.logger.debug "Updated Custom Fields Assigned to TierList: #{@tier_list.custom_fields.inspect}"

    # Save and respond
    if @tier_list.save
      Rails.logger.debug "Update Successful: #{@tier_list.inspect}"
      redirect_to tier_list_url(@tier_list), notice: "Tier list was successfully updated."
    else
      Rails.logger.debug "Update Failed: #{@tier_list.errors.full_messages.inspect}"
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tier_lists/1 or /tier_lists/1.json
  def destroy
    @tier_list.destroy!

    respond_to do |format|
      format.html { redirect_to tier_lists_url, notice: "Tier list was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tier_list
    @tier_list = TierList.find(params[:id])
  end

  def extract_custom_fields(fields_param)
    Rails.logger.debug "Extract Custom Fields Called with: #{fields_param.inspect}"

    return [] if fields_param.blank?

    fields_array = if fields_param.is_a?(Array)
        fields_param
      elsif fields_param.is_a?(ActionController::Parameters) || fields_param.is_a?(Hash)
        [fields_param]
      else
        []
      end

    fields_array.map do |field|
      field.is_a?(ActionController::Parameters) ? field.to_h.symbolize_keys : field
    end
  end

  # Only allow a list of trusted parameters through.
  def tier_list_params
    permitted_params = params.require(:tier_list).permit(
      :name,
      :short_description,
      :published,
      :image,
      :created_by_id
    )

    # Manually permit and add custom_fields if present
    if params[:custom_fields]
      permitted_params[:custom_fields] = params[:custom_fields].permit!.to_h.values
    end

    permitted_params
  end

  # Generate all ranked items
  def generate_ranked_items
    @tier_list.tier_list_rankings.includes(:item).map do |ranking|
      next if ranking.item.nil?

      {
        id: ranking.item.id,
        rank: RANK_TO_TIER_MAP[ranking.rank.to_i] || "Unranked",
        name: ranking.item.name || "Unknown Item",
        image_url: ranking.item.image&.attached? ? url_for(ranking.item.image) : view_context.asset_path("egg.png"),
        custom_fields: ranking.item.custom_field_values || {},
      }
    end.compact
  end

  def generate_creator_ranked_items
    @tier_list.items.includes(:tier_list_rankings).map do |item|
      # Fetch the ranking for the creator for this item
      creator_ranking = item.tier_list_rankings.find_by(ranked_by: @tier_list.created_by_id)

      {
        id: item.id,
        rank: creator_ranking ? RANK_TO_TIER_MAP[creator_ranking.rank.to_i] : "Unranked",
        name: item.name || "Unknown Item",
        image_url: item.image&.attached? ? url_for(item.image) : view_context.asset_path("egg.png"),
        custom_fields: item.custom_field_values || {},
      }
    end
  end

  # # Generate filtered ranked items
  # def generate_filtered_ranked_items
  #   @filtered_items.map do |item|
  #     {
  #       id: item.id,
  #       rank: RANK_TO_TIER_MAP[item.tier_list_rankings.first&.rank.to_i] || "Unranked",
  #       name: item.name || "Unknown Item",
  #       image_url: item.image&.attached? ? url_for(item.image) : view_context.asset_path("egg.png"),
  #       custom_fields: item.custom_field_values || {},
  #     }
  #   end.compact
  # end

  def generate_filtered_creator_ranked_items
    @filtered_items.map do |item|
      creator_ranking = item.tier_list_rankings.find_by(ranked_by: @tier_list.created_by_id)
      {
        id: item.id,
        rank: creator_ranking ? RANK_TO_TIER_MAP[creator_ranking.rank.to_i] : "Unranked",
        name: item.name || "Unknown Item",
        image_url: item.image&.attached? ? url_for(item.image) : view_context.asset_path("egg.png"),
        custom_fields: item.custom_field_values || {},
      }
    end.compact
  end
end
