class PeopleController < ApplicationController
  def index
    @q = Person.ransack(params[:q]) # Apply Ransack filters
    @people = @q.result(distinct: true) # Get distinct filtered results
    @person = Person.new
    
    # Retrieve the current page based on page_id
    if params[:page_id].present?
      @page = Page.find_by(id: params[:page_id])
    end
  
    @bank_name = params[:page_name] || 'Default Bank Name'
    @bank_groups = Person.groups_for_bank(@bank_name)
    @bank_levels = Person.levels_for_bank(@bank_name)
    @bank_locations = Person.locations_for_bank
  
    # Apply bank filter to already filtered @people
    @people = @people.where(bank: @bank_name)
  
    @page_id = params[:page_id]
  
    # Group people by level
    @people_by_level = @bank_levels.index_with do |level|
      @people.where(level: level)
    end
  
    # Handle "Level Not Specified"
    @unspecified_people = @people.where(level: [nil, ''])
  
    # Load programs data from YAML
    programs_data = Rails.cache.fetch('programs_data', expires_in: 12.hours) do
      YAML.load_file(Rails.root.join('config/data/programs.yml'))
    end
  
    @undergrad_programs = programs_data['undergraduate'] || []
    @grad_programs = programs_data['graduate'] || []
    
    # Filter Undergraduate and Graduate Programs for Filter Dropdowns
    @filtered_undergrad_programs = @people.distinct.pluck(:undergrad_school).reject(&:blank?)
    @filtered_grad_programs = @people.distinct.pluck(:grad_school).reject(&:blank?)

  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(person_params)
  
    if @person.save
      redirect_to people_path(page_id: params[:page_id], page_name: params[:page_name]), notice: 'Person added successfully.'
    else
      @people = Person.all
      @bank_name = params[:page_name] || 'Default Bank Name'
      @bank_groups = Person.groups_for_bank(@bank_name)
      @bank_levels = Person.levels_for_bank(@bank_name)
      @page_id = params[:page_id]
      render :index
    end
  end

  private

  def person_params
    params.require(:person).permit(
      :name,
      :bank,
      :group,
      :level,
      :email,
      :undergrad_school,
      :grad_school,
      :location,
      :linkedin,
      :image
    )
  end
  
  
end
