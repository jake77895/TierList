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
  end

  # GET /tier_lists/1/edit
  def edit
  end

  # POST /tier_lists or /tier_lists.json
  def create
    @tier_list = TierList.new(tier_list_params)

    @tier_list.created_by_id = current_user.id

    respond_to do |format|
      if @tier_list.save
        format.html { redirect_to tier_list_url(@tier_list), notice: "Tier list was successfully created." }
        format.json { render :show, status: :created, location: @tier_list }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tier_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tier_lists/1 or /tier_lists/1.json
  def update
    respond_to do |format|
      if @tier_list.update(tier_list_params)
        format.html { redirect_to tier_list_url(@tier_list), notice: "Tier list was successfully updated." }
        format.json { render :show, status: :ok, location: @tier_list }
      else
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

    # Only allow a list of trusted parameters through.
    def tier_list_params
      params.require(:tier_list).permit(:name, :created_by_id, :short_description, :custom_fields, :published)
    end
end
