class ArticlesController < ApplicationController
  def show
    # The `:id` from the route determines which view to render
    render template: "articles/#{params[:id]}"
  rescue ActionView::MissingTemplate
    # Handle cases where the view doesn't exist
    render template: "articles/not_found", status: :not_found
  end
end
