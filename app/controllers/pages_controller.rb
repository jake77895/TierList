class PagesController < ApplicationController
  before_action :find_page, only: [:show, :edit, :update, :destroy, :tier_lists]

  # List all top-level pages
  def index
    @pages = Page.roots # Fetch only top-level pages
  end

  # Show a page and its subpages
  def show
    @page = Page.find(params[:id]) # The current page
    @subpages = @page.children     # Subpages of the current page
    # @page.children is available because of acts_as_tree
  end

  # Form for new page or subpage
  def new
    @page = Page.new(parent_id: params[:parent_id]) # Support for subpages
  end

  # Create a new page
  def create
    @page = Page.new(page_params)
    @page.creator = current_user

    if @page.save
      redirect_to @page, notice: 'Page was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Form for editing a page
  def edit; end

  # Update a page
  def update
    if @page.update(page_params)
      redirect_to @page, notice: 'Page was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Delete a page
  def destroy
    @page.destroy
    redirect_to pages_path, notice: 'Page was successfully deleted.'
  end

  def tier_lists
    @associated_tier_lists = @page.tier_lists
    @unassociated_tier_lists = TierList.where.not(id: @associated_tier_lists.pluck(:id))
  end

  def associate_tier_list
    @page = Page.find(params[:page_id])
    @tier_list = TierList.find(params[:tier_list_id])

    if @page.tier_lists << @tier_list
      redirect_to tier_lists_page_path(@page), notice: 'Tier list successfully added to the page.'
    else
      redirect_to tier_lists_page_path(@page), alert: 'Failed to add the tier list.'
    end
  end

  def dissociate_tier_list
    @page = Page.find(params[:page_id])
    @tier_list = TierList.find(params[:tier_list_id])

    if @page.tier_lists.destroy(@tier_list)
      redirect_to tier_lists_page_path(@page), notice: 'Tier list successfully removed from the page.'
    else
      redirect_to tier_lists_page_path(@page), alert: 'Failed to remove the tier list.'
    end
  end

  private

  def find_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:name, :short_description, :about, :parent_id, :profile_photo, :cover_photo)
  end
end
