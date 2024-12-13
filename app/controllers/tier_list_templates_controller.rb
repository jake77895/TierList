class TierListTemplatesController < ApplicationController
  before_action :set_tier_list_template, only: %i[show edit update destroy]

  def index
    @tier_list_templates = TierListTemplate.all
  end

  def show
    @tier_list_template = TierListTemplate.find(params[:id])
    @tier_list_template.custom_fields = @tier_list_template.custom_fields.map(&:symbolize_keys)

  end

  def new
    @tier_list_template = TierListTemplate.new
    @tier_list_template.custom_fields ||= []
    (10 - @tier_list_template.custom_fields.size).times do
      @tier_list_template.custom_fields << { name: "", data_type: "" }
    end
  end

  def edit
    @tier_list_template.custom_fields ||= []
    (10 - @tier_list_template.custom_fields.size).times do
      @tier_list_template.custom_fields << { name: "", data_type: "" }
    end
  end

  def create
    @tier_list_template = TierListTemplate.new(tier_list_template_params.except(:custom_fields))

    # Extract and assign custom fields
    custom_fields = params[:custom_fields]&.values || [] # Safely access the custom fields
    filtered_fields = custom_fields.reject { |field| field["name"].blank? && field["data_type"].blank? }
    @tier_list_template.custom_fields = filtered_fields.map { |field| field.to_h.symbolize_keys }

    if @tier_list_template.save
      redirect_to @tier_list_template, notice: "Tier List Template was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @tier_list_template.assign_attributes(tier_list_template_params.except(:custom_fields))

    # Extract and assign custom fields
    custom_fields = params[:custom_fields]&.values || []
    filtered_fields = custom_fields.reject { |field| field["name"].blank? && field["data_type"].blank? }
    @tier_list_template.custom_fields = filtered_fields.map { |field| field.to_h.symbolize_keys }

    if @tier_list_template.save
      redirect_to @tier_list_template, notice: "Tier List Template was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tier_list_template.destroy
    redirect_to tier_list_templates_url, notice: "Tier List Template was successfully destroyed."
  end

  private

  def set_tier_list_template
    @tier_list_template = TierListTemplate.find(params[:id])
  end

  def tier_list_template_params
    permitted_params = params.require(:tier_list_template).permit(
      :name,
      :short_description,
      :category1,
      :category2,
      :created_by_id
    )
  
    # Manually permit and process custom_fields if present
    if params[:custom_fields]
      permitted_params[:custom_fields] = params[:custom_fields].permit!.to_h.values
    end
  
    permitted_params
  end
end
