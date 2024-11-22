# Home Controller Routes

class HomeController < ApplicationController

  def index

    @allow_create = current_user.present?

    render({ :template => "navigation_templates/home"}) 

  end

end
