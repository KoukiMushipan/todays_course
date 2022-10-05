class Search::DeparturesController < ApplicationController
  def new
    @search_departure = SearchDepartureForm.new

    @departures = current_user.departures.where(is_saved: true).includes(:location).order(created_at: :desc)
    @histories = current_user.histories.includes(destination: [departure: :location], destination: :location).order(created_at: :desc)
  end

  def create
    @search_departure = SearchDepartureForm.new(search_departure_params)
    if !@search_departure.valid?
      flash.now[:error] = '入力情報に誤りがあります'
      render :new, status: :unprocessable_entity
    end

    result = RequestGeocodeService.new(@search_departure.name, @search_departure.address).call
    if !result
      flash.now[:error] = '位置情報の取得に失敗しました'
      render :new, status: :unprocessable_entity
    end

    if @search_departure.is_saved
      departure = current_user.departures.create!(is_saved: true, location: Location.create!(result))
      redirect_to new_search_destination_path(departure: departure.uuid), flash: {success: "出発地を保存しました"}
    else
      session[:departure] = result
      redirect_to new_search_destination_path
    end
  end

  private

  def search_departure_params
    params.require(:search_departure_form).permit(:name, :address, :is_saved)
  end
end
