class Search::DeparturesController < ApplicationController
  include ApiMethods

  def menu
    @search_departure = Search::Departure.new
  end

  def saved
    @departures = Departure.where(user: current_user, is_saved: true).includes(:location)
  end

  def histories
  end

  def input
    @search_departure = Search::Departure.new
  end

  def from_current_location
    search_departure = Search::Departure.new(get_departure_params)

    url = search_departure.create_reverse_geocoder_url
    result = request_api(url)

    search_departure.name = '現在地取得'
    search_departure.address = pickup_address(result)

    session[:departure] = search_departure
    redirect_to search_terms_path
  end

  def from_saved
    departure = Departure.find(params[:id])
    search_departure = departure.set_search_departure

    session[:departure] = search_departure
    redirect_to search_terms_path
  end

  def from_address
    @search_departure = Search::Departure.new(input_departure_params)

    url = @search_departure.create_geocoder_url
    result = request_api(url)

    coordinates = pickup_coordinates(result)
    @search_departure.name = '未設定' if @search_departure.name.blank?
    @search_departure.set_coordinates(coordinates)

    session[:departure] = @search_departure
    redirect_to search_terms_path
  end

  private

  def input_departure_params
    params.require(:search_departure).permit(:name, :address, :is_saved)
  end

  def get_departure_params
    params.require(:search_departure).permit(:latitude, :longitude)
  end
end
