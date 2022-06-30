class ApplicationController < ActionController::Base
  # デバッグ用
  before_action :console_show
  before_action :show_not_yet_goal

  private

  def show_not_yet_goal
    @not_yet_goal = current_user.histories.not_yet_goal.first
  end

  def console_show
    console
  end
end
