class DeparturesController < ApplicationController
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

  private

  def departure_form_params
    params.require(:departure_form).permit(:name, :address, :is_saved)
  end

  def set_saved_departures_and_histories
    @departures = current_user.departures.saved_list
    @histories = current_user.histories.finished_list
  end
end
