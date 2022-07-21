class ApplicationController < ActionController::Base
  before_action :show_not_yet_goal

  private

  def show_not_yet_goal
    @not_yet_goal = current_user.histories.not_yet_goal.first
  end
end
