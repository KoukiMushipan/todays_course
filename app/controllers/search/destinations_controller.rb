class Search::DestinationsController < ApplicationController
  before_action :check_departure_session_and_set_departure_info, only: %i[index create]
  before_action :check_search_term_session, only: %i[index]
  before_action :check_results_session, only: %i[index]

  def index
    @results = session[:results]
    gon.searchInfo = {results: @results, departure: @departure_info, search_term: session[:search_term]}
  end

  def new
    departure = Departure.find_by(uuid: params[:departure])
    session[:departure] = departure.attributes_for_session if departure
    check_departure_session_and_set_departure_info

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
    redirect_to search_destinations_path
  end

  private

  def search_term_form_params
    params.require(:search_term_form).permit(:radius, :type)
  end

  def check_departure_session_and_set_departure_info
    redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"} if !session[:departure]
    @departure_info = session[:departure]
  end

  def check_search_term_session
    redirect_to new_search_destination_path, flash: {error: "条件を入力してください"} if !session[:search_term]
  end

  def check_results_session
    redirect_to new_search_destination_path, flash: {error: '目的地の検索が実行されていません'} if !session[:results]
  end
end
