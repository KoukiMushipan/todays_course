class Search::DeparturesController < ApplicationController
  before_action :set_new_search_departure, only: %i[menu input]
  after_action :set_session_search_departure, only: %i[from_current_location from_saved from_input from_fix]

  def menu; end

  def saved
    @departures = current_user.departures.saved_list
  end

  def histories
  end

  def input; end

  def fix
    @search_departure = Search::Departure.new(session[:departure])
  end

  def from_current_location
    @search_departure = Search::Departure.new(get_current_location_params)
    result = @search_departure.request_reverse_geocoder
    return render :menu, status: :unprocessable_entity if @search_departure.errors.present?

    @search_departure.set_current_location_info(result)

    redirect_to search_departure_fix_path
  end

  def from_saved
    departure = Departure.find(params[:id])
    @search_departure = departure.set_search_departure

    redirect_to search_terms_path
  end

  def from_input
    @search_departure = Search::Departure.new_and_valid(input_departure_params)
    result = @search_departure.request_geocoder
    return render :input, status: :unprocessable_entity if @search_departure.errors.present?

    @search_departure.set_coordinates_and_address(result)
    @search_departure.create_departure_and_set if @search_departure.is_saved

    redirect_to search_terms_path
  end

  def from_fix
    @search_departure = Search::Departure.new_and_valid(input_departure_params)
    result = @search_departure.request_geocoder
    return render :fix, status: :unprocessable_entity if @search_departure.errors.present?

    @search_departure.set_coordinates_and_address(result)
    @search_departure.create_departure_and_set if @search_departure.is_saved

    redirect_to search_terms_path
  end

  private

  def set_new_search_departure
    @search_departure = Search::Departure.new
  end

  def set_session_search_departure
    session[:departure] = @search_departure.attributes.compact
  end

  def input_departure_params
    p = params.require(:search_departure).permit(:name, :address, :is_saved)
    p.merge(user_id: current_user.id)
  end

  def get_current_location_params
    p = params.require(:search_departure).permit(:latitude, :longitude).merge(user_id: current_user.id)
    p.merge(user_id: current_user.id, is_saved: false)
  end
end
