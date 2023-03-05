class HistoriesController < ApplicationController
  before_action :check_course_params, only: %i[create]
  before_action :check_and_set_departure_info_from_session, only: %i[create]
  before_action :check_and_set_destination_info_from_session, only: %i[create]
  before_action :set_history, only: %i[show edit update destroy cancel]
  before_action :set_route, only: %i[edit update destroy cancel]

  def show
    @departure_info = @history.departure.attributes_for_session
    @destination_info = @history.destination.attributes_for_session
    gon.locationInfo = { departure: @departure_info, destination: @destination_info }
  end

  # destinations#newから遷移の場合、turbo_frameリクエスト
  def new
    destination = current_user.destinations.find_by(uuid: params[:destination])
    session[:destination] = destination.attributes_for_session if destination
    return if check_and_set_destination_info_from_session

    destination ||= current_user.destinations.find_by(uuid: @destination_info[:uuid])
    session[:departure] = destination.departure.attributes_for_session if destination
    return if check_and_set_departure_info_from_session

    gon.locationInfo = { departure: @departure_info, destination: @destination_info }
  end

  def edit; end

  def create
    result = CreateHistoryService.new(current_user, @departure_info, @destination_info, params[:course]).call
    redirect_to history_path(result[:history].uuid), flash: { success: result[:success] }
  end

  def update
    unless @history.end_time
      @history.update!(end_time: Time.zone.now)
      return redirect_to history_path(@history.uuid), flash: { success: 'ゴールしました' }, status: :see_other
    end

    if @history.update(history_params)
      flash.now[:success] = '履歴を更新しました'
      branching_route
    else
      flash.now[:error] = '入力情報に誤りがあります'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    destination = @history.destination
    case @route
    when 'goal_page'
      redirect_to new_history_path(destination: destination.uuid), flash: { success: '履歴を削除しました' }, status: :see_other
    when 'profile_page'
      flash.now[:success] = '履歴を削除しました'
      render turbo_stream: turbo_stream.replace("history_#{@history.uuid}", partial: 'shared/toast')
    when 'moving_page'
      redirect_to new_history_path(destination: destination.uuid), flash: { success: '取り消しました' }, status: :see_other
    end

    @history.destroy!
  end

  def cancel
    branching_route
  end

  private

  def set_history
    @history = current_user.histories.find_by!(uuid: params[:id])
  end

  def set_route
    @route = params[:route]
  end

  def branching_route
    case @route
    when 'goal_page'
      render :show
    when 'profile_page'
      render :cancel
    end
  end

  def history_params
    params.require(:history).permit(:start_time, :end_time, :comment, :moving_distance)
  end
end
