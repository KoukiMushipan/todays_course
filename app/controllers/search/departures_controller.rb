class Search::DeparturesController < ApplicationController
  def new
    @departure = DepartureForm.new
    set_saved_departures_and_histories
  end

  def create
    @departure = DepartureForm.new(departure_params)
    if !@departure.valid?
      set_saved_departures_and_histories
      flash.now[:error] = '入力情報に誤りがあります'
      return render :new, status: :unprocessable_entity
    end

    result = RequestGeocodeService.new(@departure.name, @departure.address).call
    if !result
      set_saved_departures_and_histories
      flash.now[:error] = '位置情報の取得に失敗しました'
      return render :new, status: :unprocessable_entity
    end

    if @departure.is_saved
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
