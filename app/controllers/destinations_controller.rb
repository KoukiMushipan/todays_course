class DestinationsController < ApplicationController
  before_action :check_departure_session, only: %i[new create]
  before_action :check_candidates_session, only: %i[new create]
  before_action :check_candidate_session_for_destination_and_set_candidate, only: %i[new create]
  before_action :set_destination_and_location, only: %i[show edit update destroy]
  before_action :set_route, only: %i[edit update destroy]

  def new
    @destination_form = DestinationForm.new
    gon.locationInfo = {departure: session[:departure], destination: @candidate}
  end

  def create # turbo_frameリクエスト
    @destination_form = DestinationForm.new(destination_form_params)

    if !@destination_form.valid?
      flash.now[:error] = '入力情報に誤りがあります'
      return render :new, status: :unprocessable_entity
    end

    result_of_create_destination = CreateDestinationService.new(current_user, session[:departure], @destination_form, @candidate).call
    session[:destination] = result_of_create_destination[:destination]
    redirect_to new_history_path, flash: {success: result_of_create_destination[:success]}
  end

  def show
    case @route
    when 'moving_page' then redirect_to new_history_path(destination: @destination.uuid)
    when 'saved_page' then render :show
    end
  end

  def edit; end

  def update
    if @location.update(location_and_destination_params)
      case @route
      when 'moving_page' then redirect_to new_history_path(destination: @destination.uuid)
      when 'saved_page' then redirect_to destination_path(@destination.uuid), flash: {success: ' 目的地を更新しました'}
      end
    else
      flash.now[:error] = '入力情報に誤りがあります'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    case @route
    when 'moving_page'
      @destination.destroy!
      flash.now[:error] = '保存済みから削除しました'
      redirect_to searches_path, status: :see_other
    when 'saved_page'
      @destination.update!(is_saved: false)
      flash.now[:error] = '目的地を保存済みから削除しました'
      render turbo_stream: turbo_stream.replace("destination_#{@destination.uuid}", partial: 'shared/toast')
    end
  end

  private

  def set_route
    @route = params[:route]
  end

  def set_destination_and_location
    @destination = current_user.destinations.find_by!(uuid: params[:id])
    @location = @destination.location
  end

  def destination_form_params
    params.require(:destination_form).permit(:name, :comment, :is_published_comment,:distance, :is_saved)
  end

  def location_and_destination_params
    params.require(:location).permit(:name, :address, destination_attributes: [:comment, :is_published_comment, :distance, :id])
  end
end
