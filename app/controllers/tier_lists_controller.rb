class TierListsController < ApplicationController
  before_action :set_tier_list, only: %i[ show edit update destroy ]

  # GET /tier_lists or /tier_lists.json
  def index
    @tier_lists = TierList.all
  end

  # GET /tier_lists/1 or /tier_lists/1.json
  def show
  end

  # GET /tier_lists/new
  def new
    @tier_list = TierList.new
    @tier_list.custom_fields = [{}] if @tier_list.custom_fields.blank?
  end

  # GET /tier_lists/1/edit
  def edit
    @tier_list = TierList.find(params[:id])

  
    # Ensure each custom field hash is properly initialized as a plain hash
    @tier_list.custom_fields ||= []
    @tier_list.custom_fields = @tier_list.custom_fields.map do |field|
      field.is_a?(Hash) ? field.symbolize_keys : {}
    end
    
  
    Rails.logger.debug "Custom Fields for Edit: #{@tier_list.custom_fields.inspect}"
  end
  
  


  def create
    Rails.logger.debug "Strong Params: #{tier_list_params.inspect}"
    
    # Initialize TierList
    @tier_list = TierList.new(tier_list_params.except(:custom_fields))
    Rails.logger.debug "Initialized TierList: #{@tier_list.inspect}"
    
    # Extract and assign custom_fields
    custom_fields = tier_list_params[:custom_fields]
    Rails.logger.debug "Custom Fields from Strong Params: #{custom_fields.inspect}"
    
    @tier_list.custom_fields = extract_custom_fields(custom_fields)
    Rails.logger.debug "Custom Fields Assigned: #{@tier_list.custom_fields.inspect}"
    
    # Save and respond
    if @tier_list.save
      redirect_to tier_list_url(@tier_list), notice: "Tier list was successfully created."
    else
      Rails.logger.debug "Save Failed: #{@tier_list.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end
  
  
  
  
  
  
  
  

  # PATCH/PUT /tier_lists/1 or /tier_lists/1.json

  def update
    @tier_list = TierList.find(params[:id])
    
    # Extract and assign custom_fields
    custom_fields = tier_list_params[:custom_fields]
    Rails.logger.debug "Custom Fields Before Processing: #{custom_fields.inspect}"
  
    @tier_list.custom_fields = extract_custom_fields(custom_fields) if custom_fields.present?
  
    # Update other attributes
    respond_to do |format|
      if @tier_list.update(tier_list_params.except(:custom_fields))
        format.html { redirect_to tier_list_url(@tier_list), notice: "Tier list was successfully updated." }
        format.json { render :show, status: :ok, location: @tier_list }
      else
        Rails.logger.debug "Update Failed: #{@tier_list.errors.full_messages}"
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tier_list.errors, status: :unprocessable_entity }
      end
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
      params.require(:tier_list).permit(
        :name,
        :short_description,
        :published,
        :created_by_id,
        custom_fields: [:name, :data_type] # Explicitly permit the nested attributes
      )
    end
end
