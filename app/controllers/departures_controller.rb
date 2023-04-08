class DeparturesController < ApplicationController
  before_action :set_departure_and_location, only: %i[show edit update destroy]

  def index
    @departures = current_user.departures.saved_list
    @destinations = current_user.destinations.saved_list
  end

  def show; end

  def new
    @departure_form = DepartureForm.new
    set_saved_departures_and_histories
  end

  def edit
    @departure_form = DepartureForm.new(@departure.attributes_for_form)
  end

  def create
    @departure_form = DepartureForm.new(departure_form_params)
    return render_new_departure('入力情報に誤りがあります') unless @departure_form.valid?(:check_save)

    result = Api::GeocodeService.new(@departure_form).call
    return render_new_departure('位置情報の取得に失敗しました') unless result

    if result[:is_saved]
      departure = Departure.create_with_location(current_user, result)
      session[:departure] = departure.attributes_for_session
      flash[:success] = '出発地を保存しました'
    else
      session[:departure] = result
    end

    redirect_to new_search_path
  end

  def update
    @departure_form = DepartureForm.new(edit_departure_form_params)
    return render_edit_departure('入力情報に誤りがあります') unless @departure_form.valid?

    if @location.address == @departure_form.address
      @location.update!(edit_departure_form_params)
    else
      result = Api::GeocodeService.new(@departure_form).call
      return render_edit_departure('位置情報の取得に失敗しました') unless result

      @location.update!(result.compact)
    end

    redirect_to departure_path(@departure.uuid), flash: { success: '出発地を更新しました' }
  end

  def destroy
    @departure.update!(is_saved: false)
    flash.now[:success] = '出発地を保存済みから削除しました'
    render turbo_stream: turbo_stream.replace("departure_#{@departure.uuid}", partial: 'shared/toast')
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

  def render_new_departure(error_message)
    set_saved_departures_and_histories
    flash.now[:error] = error_message
    render :new, status: :unprocessable_entity
  end

  def render_edit_departure(error_message)
    flash.now[:error] = error_message
    render :edit, status: :unprocessable_entity
  end

  def departure_form_params
    params.require(:departure_form).permit(:name, :address, :is_saved)
  end

  def edit_departure_form_params
    params.require(:departure_form).permit(:name, :address)
  end
end
