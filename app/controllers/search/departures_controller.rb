class Search::DeparturesController < ApplicationController
  include RequestApiMethods
  include ResponseApiMethods

  before_action :set_new_search_departure, only: [:menu, :input]
  after_action :set_session_search_departure, only: [:from_current_location, :from_saved, :from_address]

  def menu; end

  def saved
    @departures = current_user.departures.saved_list
  end

  def histories
  end

  def input; end

  def fix; end

  def from_current_location
    @search_departure = Search::Departure.new(get_departure_params)

    result = request_reverse_geocoder(@search_departure)

    unless normal_result?(result)
      @error_message = t '.failed_get_current_location'
      return render :menu, status: :unprocessable_entity
    end

    @search_departure.name = t '.get_current_location'
    @search_departure.address = pickup_address(result)

    render :fix, status: :created
  end

  def from_saved
    departure = Departure.find(params[:id])
    @search_departure = departure.set_search_departure

    redirect_to search_terms_path
  end

  def from_address
    @search_departure = Search::Departure.new(input_departure_params)

    result = request_geocoder(@search_departure)

    unless normal_result?(result)
      @error_message = t '.failed_get_location'
      return render :input, status: :unprocessable_entity
    end

    coordinates = pickup_coordinates(result)
    @search_departure.set_coordinates(coordinates)

    if @search_departure.will_save?
      @search_departure = Departure.create_and_set_departure(current_user, @search_departure)
    end

    redirect_to search_terms_path
  end

  private

  def set_new_search_departure
    @search_departure = Search::Departure.new
  end

  def set_session_search_departure
    session[:departure] = @search_departure
  end

  def input_departure_params
    params.require(:search_departure).permit(:name, :address, :is_saved)
  end

  def get_departure_params
    params.require(:search_departure).permit(:latitude, :longitude)
  end
end
