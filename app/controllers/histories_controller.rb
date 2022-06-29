class HistoriesController < ApplicationController

  def index
    @histories = current_user.histories.for_index
  end

  def new
    @search_departure = Search::Departure.new(session[:departure])
    @search_destination = Search::Destination.new(session[:destination])

    gon.routeInfo = {departure: session[:departure], destination: session[:destination]}
  end

  def create
    @history = History.set_or_create_place_and_create_history(session[:departure], session[:destination], params[:course])
  end

  def edit
    @history = current_user.histories.find(params[:id])
  end

  def update
    @history = current_user.histories.find(params[:id])
    @history.attributes = history_params
    if @history.time_validates && @history.save
      redirect_to histories_path, notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @history = current_user.histories.find(params[:id])
    @history.destroy!
  end

  def goal
    @history = current_user.histories.find(params[:id])
    @history.update!(end_time: Time.now)
  end

  def set
    @history = current_user.histories.find(params[:id])
    search_departure = @history.departure.set_search_departure
    search_destination = @history.destination.set_search_destination

    session[:departure] = search_departure.attributes
    session[:destination] = search_destination.attributes
    redirect_to new_history_path
  end

  private

  def history_params
    params.require(:history).permit(:start_time, :end_time, :moving_distance)
  end
end
