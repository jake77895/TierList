class ItemsController < ApplicationController
  before_action :set_tier_list
  before_action :set_item, only: %i[show edit update destroy]

  def index
    @items = @tier_list.items
  end

  def show; end

  def new
    @tier_list = TierList.find(params[:tier_list_id])
    @item = @tier_list.items.build
    @custom_fields = @tier_list.custom_fields # Pass the custom fields from the tier list
  end
  
  
  def create
    # Filter items with non-empty names
    items_params = params[:items].values.reject { |item| item[:name].blank? }
    
    
    Rails.logger.debug "Creating items for TierList: #{@tier_list.id}"
    Rails.logger.debug "Valid items: #{items_params}"
  
    items_params.each do |item_data|
      Rails.logger.debug "Processing item: #{item_data.inspect}"
      @tier_list.items.create(item_params(item_data))
    end
  
    Rails.logger.debug "Redirecting to TierList show page"
    redirect_to tier_list_path(@tier_list), notice: "#{items_params.size} items were successfully created."
  rescue StandardError => e
    Rails.logger.debug "Error while creating items: #{e.message}"
    redirect_to tier_list_path(@tier_list), alert: "There was an error creating the items."
  end
  
  
  

  def edit
    @item = @tier_list.items.find(params[:id])
  end

  def update
    if @item.update(item_params)
      redirect_to [@tier_list, @item], notice: "Item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to tier_list_items_url(@tier_list), notice: "Item was successfully destroyed."
  end

  def filter_items

    @tier_list = TierList.find(params[:tier_list_id]) # Find the associated tier list
    @items = @tier_list.items # Start with all items in the tier list

    # Apply filters based on custom_field_values
    params.each do |key, value|
      next unless key.start_with?("filter_") && value.present?
      field_name = key.gsub("filter_", "").split("_").first
      if key.end_with?("_min")
        @items = @items.where("custom_field_values ->> ? >= ?", field_name, value)
      elsif key.end_with?("_max")
        @items = @items.where("custom_field_values ->> ? <= ?", field_name, value)
      else
        @items = @items.where("custom_field_values ->> ? = ?", field_name, value)
      end
    end

    # Render filtered items (adjust as needed)
    respond_to do |format|
      format.html { render :filter_results } # Create a `filter_results.html.erb` view if needed
      format.json { render json: @items }    # For AJAX or API-based responses
    end
  end

  private

  def set_tier_list
    Rails.logger.debug "Params: #{params.inspect}"
    @tier_list = TierList.find(params[:tier_list_id])
    @tier_list_items = @tier_list.items.order(updated_at: :desc)
  end

  def set_item
    @item = @tier_list.items.find(params[:id])
  end

  def item_params(data = nil)
    # Use passed data for multiple items; otherwise, use the standard params[:item]
    data ||= params[:item]
    
    custom_fields = data[:custom_field_values].is_a?(ActionController::Parameters) ? 
                      data[:custom_field_values].to_unsafe_h : 
                      data[:custom_field_values] || {}
  
    data.permit(:name, :description, :image).merge(
      custom_field_values: custom_fields
    )
  end


  
  
end
