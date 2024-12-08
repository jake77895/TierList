class CommentsController < ApplicationController
  before_action :set_tier_list
  before_action :set_comment, only: [:update, :destroy]

  def create
    @comment = @tier_list.comments.new(comment_params)
    @comment.user = current_user
  
    if @comment.save
      redirect_to request.referer || @tier_list, notice: 'Comment was successfully created.'
    else
      redirect_to request.referer || @tier_list, alert: 'Failed to create comment.'
    end
  end
  
  def update
    if @comment.update(comment_params)
      redirect_to request.referer || @tier_list, notice: 'Comment was successfully updated.'
    else
      flash[:alert] = 'Failed to update the comment. Please correct the errors and try again.'
      redirect_to request.referer || @tier_list
    end
  end
  
  def destroy
    @comment.destroy
    redirect_to request.referer || @tier_list, notice: 'Comment was successfully deleted.'
  end

  private

  def set_tier_list
    @tier_list = TierList.find(params[:tier_list_id])
  end

  def set_comment
    @comment = @tier_list.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :item_id)
  end
end
