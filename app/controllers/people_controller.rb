class PeopleController < ApplicationController
  def index
    @people = Person.all
    @person = Person.new
    

    # Retrieve the current page based on page_id
    if params[:page_id].present?
      @page = Page.find_by(id: params[:page_id])
    end

    @bank_name = params[:page_name] || 'Default Bank Name'
    @bank_groups = Person.groups_for_bank(@bank_name)
    @bank_levels = Person.levels_for_bank(@bank_name)

    # Fetch people filtered by the bank
    @people = Person.where(bank: @bank_name)

    @page_id = params[:page_id]

    @people_by_level = @bank_levels.index_with { |level| @people.where(level: level) }
    # Handle "Level Not Specified"
    @unspecified_people = @people.where(level: [nil, ''])

    Rails.logger.debug "DEBUG: @unspecified_people count = #{@unspecified_people.count}"
    Rails.logger.debug "DEBUG: @unspecified_people = #{@unspecified_people.pluck(:id, :name, :level)}"

    # Load programs data from YAML
    # Use caching to improve performance
    programs_data = Rails.cache.fetch('programs_data', expires_in: 12.hours) do
      YAML.load_file(Rails.root.join('config/data/programs.yml'))
    end
    
    @undergrad_programs = programs_data['undergraduate'] || []
    @grad_programs = programs_data['graduate'] || []


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
    params.require(:person).permit(:name, :bank, :group, :level, :email, :undergrad_school, :grad_school, :image)
  end
  
  
end
