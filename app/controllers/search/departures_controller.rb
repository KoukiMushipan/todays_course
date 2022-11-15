class Search::DeparturesController < ApplicationController
  def new
    @departure_form = DepartureForm.new
    set_saved_departures_and_histories
  end

  def create
    @departure_form = DepartureForm.new(departure_params)
    result = RequestGeocodeService.new(@departure_form).call

    if result[:error]
      set_saved_departures_and_histories
      flash.now[:error] = result[:error]
      return render :new, status: :unprocessable_entity
    end

    if @departure_form.is_saved
      departure = current_user.departures.create!(is_saved: true, location: Location.create!(result))
      redirect_to new_search_destination_path(departure: departure.uuid), flash: {success: "出発地を保存しました"}
    else
      session[:departure] = result
      redirect_to new_search_destination_path
    end
  end

  private

  def departure_params
    params.require(:departure_form).permit(:name, :address, :is_saved)
  end

  def set_saved_departures_and_histories
    @departures = current_user.departures.saved_list
    @histories = current_user.histories.list
  end
end
