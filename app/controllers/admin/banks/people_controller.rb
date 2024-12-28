module Admin
  module Banks
    class PeopleController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_admin!

      def index
        @people = Person.all.order(:bank, :level, :name) # Show all people, sorted
        @person = Person.new
      end

      def new
        @person = Person.new
      end

      def create
        @person = Person.new(person_params)
        if @person.save
          redirect_to admin_banks_people_path, notice: 'Person successfully added.'
        else
          render :new
        end
      end

      def edit
        @person = Person.find(params[:id])
      end

      def update
        @person = Person.find(params[:id])
        if @person.update(person_params)
          redirect_to admin_banks_people_path, notice: 'Person successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        @person = Person.find(params[:id])
        @person.destroy
        redirect_to admin_banks_people_path, notice: 'Person successfully deleted.'
      end

      private

      def authorize_admin!
        redirect_to root_path, alert: 'Access Denied!' unless current_user.admin?
      end

      def person_params
        params.require(:person).permit(
          :name, :email, :group, :level, :bank, :undergrad_school, 
          :grad_school, :location, :linkedin, :image
        )
      end
    end
  end
end
