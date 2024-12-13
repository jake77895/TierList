class TierListTemplatesController < ApplicationController
  before_action :set_tier_list_template, only: %i[show edit update destroy]

  def index
    @tier_list_templates = TierListTemplate.all
  end

  def show
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
    @tier_list_template = TierListTemplate.new(tier_list_template_params)
    custom_fields = params[:custom_fields]&.values || []
    @tier_list_template.custom_fields = custom_fields.reject { |field| field[:name].blank? && field[:data_type].blank? }

    if @tier_list_template.save
      redirect_to @tier_list_template, notice: "Tier List Template was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    custom_fields = params[:custom_fields]&.values || []
    @tier_list_template.custom_fields = custom_fields.reject { |field| field[:name].blank? && field[:data_type].blank? }
    if @tier_list_template.update(tier_list_template_params)
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
    params.require(:tier_list_template).permit(:name, :short_description, :category1, :category2, :created_by_id, custom_fields: [])
  end
end

