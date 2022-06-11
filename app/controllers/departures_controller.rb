class DeparturesController < ApplicationController
  include ApiMethods

  def menu
    @search_departure = SearchDeparture.new
  end

  def saved
    @departures = Departure.where(user: current_user, is_saved: true).includes(:location)
  end

  def histories
  end

  def input
    @search_departure = SearchDeparture.new
  end

  def from_current_location
    search_departure = SearchDeparture.new(search_departure_params)

    url = search_departure.create_reverse_geocoder_url
    result = request_api(url)

    search_departure.name = '現在地取得'
    search_departure.address = extract_address(result)

    session[:departure] = search_departure
    redirect_to search_destination_path
  end

  def from_saved
    departure = Departure.find(params[:departure_id])
    search_departure = departure.set_search_departure

    session[:departure] = search_departure
    redirect_to search_destination_path
  end

  def from_address
    @search_departure = SearchDeparture.new(search_departure_params)

    url = @search_departure.create_geocoder_url
    result = request_api(url)

    coordinates = extract_coordinates(result)
    @search_departure.name = '未設定' if @search_departure.name.blank?
    @search_departure.latitude = coordinates[:latitude]
    @search_departure.longitude = coordinates[:longitude]

    session[:departure] = @search_departure
    redirect_to search_destination_path
  end

  private

  def search_departure_params
    params.require(:search_departure).permit(:latitude, :longitude, :name, :address, :save)
  end
end
