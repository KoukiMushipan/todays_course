class HistoriesController < ApplicationController
  before_action :check_course_params, only: %i[create]
  before_action :check_departure_session_and_set_departure_info, only: %i[create show]
  before_action :check_destination_session_and_set_destination_info, only: %i[create show]

  def new # destinations#newから遷移の場合、turbo_frameリクエスト
    destination = current_user.destinations.find_by(uuid: params[:destination])
    session[:destination] = destination.attributes_for_session if destination
    return if check_destination_session_and_set_destination_info

    destination ||= current_user.destinations.find_by(uuid: session[:destination][:uuid])
    departure = destination&.departure
    session[:departure] = departure.attributes_for_session if departure
    return if check_departure_session_and_set_departure_info

    gon.locationInfo = {departure: @departure_info, destination: @destination_info}
  end

  def create
    result_of_create_history = CreateHistoryService.new(current_user, @departure_info, @destination_info, params[:course]).call
    redirect_to history_path(result_of_create_history[:history].uuid), flash: {success: result_of_create_history[:success]}
  end

  def show
    @history = current_user.histories.find_by(uuid: params[:id])
    gon.locationInfo = {departure: @departure_info, destination: @destination_info}
  end
end
