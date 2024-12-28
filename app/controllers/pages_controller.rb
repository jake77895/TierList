class PagesController < ApplicationController
  before_action :find_page, only: [:show, :edit, :update, :destroy, :tier_lists, :associate_tier_list, :dissociate_tier_list]

  def bank_view
    @page = Page.find_by(id: params[:id])

    if @page.nil?
      render plain: "Page not found", status: :not_found
      return
    end

    # Generate the link back to the original page
    @bank_link = page_path(@page.id)
  end

  # List all top-level pages
  def index
    @pages = Page.roots # Fetch only top-level pages
  end

  # Show a page and its subpages
  def show
    @page = Page.find_by(id: params[:id])

    if @page.nil?
      render plain: "Page not found", status: :not_found
      return
    end

    @subpages = @page.children

    # Check if the current page has a special section
    @show_special_section = ::BANK_LIST.include?(@page.name.downcase)
    @bank_link = @show_special_section ? url_for(controller: 'pages', action: 'show', id: @page.id) : nil
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
  
    # Fetch associated tier lists
    associated_ids = @page.tier_lists.pluck(:id)
    @associated_tier_lists = @page.tier_lists
  
    # Set up Ransack for unassociated tier lists (searchable on limited attributes)
    @q = TierList
          .select(:id, :name, :category1, :category2, :published, :created_by_id) # Limited attributes for searching
          .where.not(id: associated_ids)
          .ransack(params[:q])
  
    # Fetch the full records for the filtered tier lists
    unassociated_ids = @q.result.pluck(:id) # Fetch IDs of filtered records
    @unassociated_tier_lists = TierList.where(id: unassociated_ids) # Fetch full records

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
