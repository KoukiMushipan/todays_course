class HistoriesController < ApplicationController
  before_action :check_departure_session, only: %i[create]
  before_action :check_destination_session, only: %i[create]
  before_action :check_course_params, only: %i[create]

  def new
    destination = current_user.destinations.find_by(uuid: params[:destination])
    session[:destination] = destination.attributes_for_session if destination
    check_destination_session_and_set_destination_info

    destination ||= current_user.destinations.find_by(uuid: session[:destination][:uuid])
    departure = destination&.departure
    session[:departure] = departure.attributes_for_session if departure
    check_departure_session_and_set_departure_info

    gon.locationInfo = {departure: @departure_info, destination: @destination_info}
  end

  def create
    history = CreateHistoryService.new(current_user, session[:departure], session[:destination], params[:course]).call
    redirect_to new_history_path if !history
    redirect_to history_path(history.uuid)
  end

  def show
    @history = current_user.histories.find_by(uuid: params[:id])
  end
end
