# Home Controller Routes

class HomeController < ApplicationController

  def index

    @allow_create = current_user.present?
    @tier_lists = TierList.where(published: true)

    render({ :template => "navigation_templates/home"}) 

  end

end
