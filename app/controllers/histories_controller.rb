class HistoriesController < ApplicationController
  def new
  end

  def create
    @history = History.set_or_create_place_and_create_history(session[:departure], session[:destination], params[:course])
  end

  def goal
    @history = current_user.histories.find(params[:id])
    @history.update!(end_time: Time.now)
  end
end
