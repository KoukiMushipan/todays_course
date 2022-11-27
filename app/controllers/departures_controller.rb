class DeparturesController < ApplicationController
  before_action :set_departure_and_location, only: %i[show edit update destroy]

  def index
    @departures = current_user.departures.saved_list
    @destinations = current_user.destinations.saved_list
  end

  def new
    @departure_form = DepartureForm.new
    set_saved_departures_and_histories
  end

  def create
    @departure_form = DepartureForm.new(departure_form_params)
    result = RequestGeocodeService.new(@departure_form).call

    if result.include?(:error)
      set_saved_departures_and_histories
      flash.now[:error] = result[:error]
      return render :new, status: :unprocessable_entity
    end

    result_of_create_departure = CreateDepartureService.new(current_user, result, @departure_form.is_saved).call
    session[:departure] = result_of_create_departure[:departure]
    redirect_to new_search_path, flash: {success: result_of_create_departure[:success]}
  end

  def show; end

  def edit; end

  def update
    if @location.update(location_params)
      redirect_to departure_path(@departure.uuid), flash: {success: '出発地を更新しました'}
    else
      flash.now[:error] = '入力情報に誤りがあります'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @departure.update!(is_saved: false)
    flash.now[:error] = '出発地を保存済みから削除しました'
    render turbo_stream: turbo_stream.replace(@departure, partial: 'shared/toast')
  end

  private

  def set_saved_departures_and_histories
    @departures = current_user.departures.saved_list
    @histories = current_user.histories.finished_list
  end

  def set_departure_and_location
    @departure = current_user.departures.find_by!(uuid: params[:id])
    @location = @departure.location
  end

  def departure_form_params
    params.require(:departure_form).permit(:name, :address, :is_saved)
  end

  def location_params
    params.require(:location).permit(:name, :address)
  end
end
