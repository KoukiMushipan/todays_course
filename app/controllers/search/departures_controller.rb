class Search::DeparturesController < ApplicationController
  include RequestApiMethods
  include ResponseApiMethods

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

    result = request_reverse_geocoder(@search_departure)
    unless normal_result?(result)
      @error_message = t '.failed_get_current_location'
      return render :menu, status: :unprocessable_entity
    end

    @search_departure.name = t '.get_current_location'
    @search_departure.address = pickup_address(result)

    redirect_to search_departure_fix_path
  end

  def from_saved
    departure = Departure.find(params[:id])
    @search_departure = departure.set_search_departure

    redirect_to search_terms_path
  end

  def from_input
    @search_departure = Search::Departure.new(input_departure_params)
    return render :input, status: :unprocessable_entity unless @search_departure.valid?

    result = request_geocoder(@search_departure)
    unless normal_result?(result)
      @error_message = t '.failed_get_location'
      return render :input, status: :unprocessable_entity
    end

    set_coordinates_and_address(@search_departure, result)
    if @search_departure.will_save?
      @search_departure = Departure.create_and_set_departure(current_user, @search_departure)
    end

    redirect_to search_terms_path
  end

  def from_fix
    @search_departure = Search::Departure.new(input_departure_params)
    return render :fix, status: :unprocessable_entity unless @search_departure.valid?

    result = request_geocoder(@search_departure)
    unless normal_result?(result)
      @error_message = t '.failed_get_location'
      return render :fix, status: :unprocessable_entity
    end

    set_coordinates_and_address(@search_departure, result)
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

  def get_current_location_params
    params.require(:search_departure).permit(:latitude, :longitude)
  end
end
