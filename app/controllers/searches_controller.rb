class SearchesController < ApplicationController
  before_action :check_departure_session_and_set_departure_info, only: %i[index create]
  before_action :check_search_term_session, only: %i[index]
  before_action :check_candidates_session, only: %i[index]

  def index
    @results = session[:results]
    departure_location = Location.new(latitude: @departure_info[:latitude], longitude: @departure_info[:longitude])

    @commented_destinations_info = departure_location.search_nearby_published_comment_info(session[:search_term]["radius"], current_user)
    session[:commented_destinations] = @commented_destinations_info
    @my_destinations_info = departure_location.search_nearby_own_info(session[:search_term]["radius"], current_user)

    place_id_arr = []
    [@my_destinations_info, @commented_destinations_info, @results].each do |r|
      r.delete_if {|result| place_id_arr.include?(result[:fixed][:place_id])}
      place_id_arr += r.map {|d| d[:fixed][:place_id]}
    end

    gon.searchInfo = {results: @results, commented_destinations: @commented_destinations_info, my_destinations_info: @my_destinations_info, departure: @departure_info, search_term: session[:search_term]}
  end

  def new
    departure = current_user.departures.find_by(uuid: params[:departure])
    session[:departure] = departure.attributes_for_session if departure
    return if check_departure_session_and_set_departure_info

    @search_term_form = SearchTermForm.new
  end

  def create
    @search_term_form = SearchTermForm.new(search_term_form_params)
    results = RequestNearbyService.new(@departure_info, @search_term_form).call

    if results.include?(:error)
      flash.now[:error] = results[:error]
      return render :new, status: :unprocessable_entity
    end

    session[:results], session[:search_term] = results, @search_term_form.attributes
    redirect_to searches_path
  end

  private

  def search_term_form_params
    params.require(:search_term_form).permit(:radius, :type)
  end
end
