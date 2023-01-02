class HistoriesController < ApplicationController
  before_action :check_course_params, only: %i[create]
  before_action :check_departure_session_and_set_departure_info, only: %i[create show]
  before_action :check_destination_session_and_set_destination_info, only: %i[create show]
  before_action :set_history, only: %i[show edit update destroy cancel]
  before_action :set_route, only: %i[edit update destroy cancel]

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

  def edit; end

  def update
    if !@history.end_time
      @history.update!(end_time: Time.zone.now)
      return redirect_to history_path(@history.uuid), flash: {success: 'ゴールしました'}, status: :see_other
    end

    if @history.update(history_params)
      flash.now[:success] = '履歴を更新しました'
      case @route
      when 'moving_page' then render :show
      when 'profile_page' then render :cancel
      end
    else
      flash.now[:error] = '入力情報に誤りがあります'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destination = @history.destination

    if @history.end_time
      @history.destroy!
      case @route
      when 'moving_page'
        redirect_to new_history_path(destination: destination.uuid), flash: {success: '履歴を削除しました'}, status: :see_other
      when 'profile_page'
        flash.now[:success] = '履歴を削除しました'
        render turbo_stream: turbo_stream.replace("history_#{@history.uuid}", partial: 'shared/toast')
      end
    else
      @history.destroy!
      redirect_to new_history_path(destination: destination.uuid), status: :see_other
    end
  end

  def cancel
    case @route
    when 'moving_page' then render :show
    when 'profile_page' then render :cancel
    end
  end

  private

  def set_history
    @history = current_user.histories.find_by!(uuid: params[:id])
  end

  def set_route
    @route = params[:route]
  end

  def history_params
    params.require(:history).permit(:start_time, :end_time, :comment, :moving_distance)
  end
end
