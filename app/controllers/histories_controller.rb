class HistoriesController < ApplicationController
  before_action :check_course_params, only: %i[create]
  before_action :check_departure_session_and_set_departure_info, only: %i[create show]
  before_action :check_destination_session_and_set_destination_info, only: %i[create show]
  before_action :set_history, only: %i[show update destroy]

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
    gon.locationInfo = {departure: @departure_info, destination: @destination_info}
  end

  def update
    if @history.end_time

    else
      @history.update!(end_time: DateTime.now)
      redirect_to history_path(@history.uuid), status: :see_other
    end
  end

  def destroy
    if @history.end_time
      @history.destroy!
      redirect_to profile_path, status: :see_other
    else
      destination = @history.destination
      @history.destroy!
      redirect_to new_history_path(destination: destination.uuid), status: :see_other
    end
  end

  private

  def set_history
    @history = current_user.histories.find_by!(uuid: params[:id])
  end
end
