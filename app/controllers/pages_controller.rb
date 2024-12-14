class PagesController < ApplicationController
  before_action :find_page, only: [:show, :edit, :update, :destroy, :tier_lists, :associate_tier_list, :dissociate_tier_list]

  # List all top-level pages
  def index
    @pages = Page.roots # Fetch only top-level pages
  end

  # Show a page and its subpages
  def show
    @subpages = @page.children # Subpages of the current page
  end

  # Form for new page or subpage
  def new
    @page = Page.new(parent_id: params[:parent_id]) # Support for subpages
  end

  # Create a new page
  def create
    @page = Page.new(page_params)
    @page.creator = current_user if current_user # Assign creator if logged in

    if @page.save
      redirect_to @page, notice: 'Page was successfully created.'
    else
      Rails.logger.error "Page Creation Failed: #{@page.errors.full_messages.join(', ')}"
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
      Rails.logger.error "Page Update Failed: #{@page.errors.full_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
    end
  end

  # Delete a page
  def destroy
    if @page.destroy
      redirect_to pages_path, notice: 'Page was successfully deleted.'
    else
      Rails.logger.error "Page Deletion Failed: #{@page.errors.full_messages.join(', ')}"
      redirect_to pages_path, alert: 'Failed to delete the page.'
    end
  end

  # Tier Lists for a Page
  def tier_lists
    Rails.logger.debug "Params: #{params.inspect}"

    # Fetch associated tier lists
    associated_ids = @page.tier_lists.pluck(:id)
    @associated_tier_lists = @page.tier_lists
    Rails.logger.debug "Associated Tier Lists: #{@associated_tier_lists.inspect}"

    # Set up Ransack for unassociated tier lists
    @q = TierList
      .select(:id, :name, :category1, :category2, :published, :created_by_id) # Exclude `custom_fields`
      .where.not(id: associated_ids)
      .ransack(params[:q])
    Rails.logger.debug "Ransack Object: #{@q.inspect}"

    # Fetch unassociated tier lists
    @unassociated_tier_lists = @q.result(distinct: true)
    Rails.logger.debug "Unassociated Tier Lists: #{@unassociated_tier_lists.inspect}"
  end

  # Associate a Tier List with a Page
  def associate_tier_list
    @tier_list = TierList.find(params[:tier_list_id])

    if @page.tier_lists.exists?(id: @tier_list.id)
      redirect_to tier_lists_page_path(@page), alert: 'Tier list is already associated with this page.'
    else
      @page.tier_lists << @tier_list
      redirect_to tier_lists_page_path(@page), notice: 'Tier list successfully added to the page.'
    end
  end

  # Dissociate a Tier List from a Page
  def dissociate_tier_list
    @tier_list = TierList.find(params[:tier_list_id])

    if @page.tier_lists.exists?(id: @tier_list.id)
      @page.tier_lists.destroy(@tier_list)
      redirect_to tier_lists_page_path(@page), notice: 'Tier list successfully removed from the page.'
    else
      redirect_to tier_lists_page_path(@page), alert: 'Tier list is not associated with this page.'
    end
  end

  private

  # Find the page by ID
  def find_page
    @page = Page.find(params[:id] || params[:page_id])
  end

  # Strong parameters for pages
  def page_params
    params.require(:page).permit(:name, :short_description, :about, :parent_id, :profile_photo, :cover_photo)
  end
end
