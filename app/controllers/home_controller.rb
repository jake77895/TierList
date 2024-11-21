# Home Controller Routes

class HomeController < ApplicationController

  def index

    render({ :template => "navigation_templates/home"}) 

  end

end
