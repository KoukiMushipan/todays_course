class SearchesController < ApplicationController
  before_action :check_and_set_departure_info_from_session, only: %i[index create]
  before_action :check_search_term_session, only: %i[index]
  before_action :check_candidates_session, only: %i[index]

  def index
    pick_candidates = PickCandidatesService.new(current_user,
                                                session[:results],
                                                @departure_info,
                                                session[:search_term]).call

    @results = pick_candidates[:results]
    @nearby_own_info = pick_candidates[:nearby_own_info]
    @nearby_commented_info = pick_candidates[:nearby_commented_info]
    session[:nearby_commented_info] = @nearby_commented_info

    gon.searchInfo = pick_candidates
  end

  def new
    departure = current_user.departures.find_by(uuid: params[:departure])
    session[:departure] = departure.attributes_for_session if departure
    return if check_and_set_departure_info_from_session

    @search_term_form = SearchTermForm.new
  end

  def create
    @search_term_form = SearchTermForm.new(search_term_form_params)
    return render_new_search('入力情報に誤りがあります') unless @search_term_form.valid?

    results = Api::NearbyService.new(@departure_info, @search_term_form).call
    return render_new_search('目的地が見つかりませんでした') unless results

    session[:results] = results
    session[:search_term] = @search_term_form.attributes.symbolize_keys
    redirect_to searches_path
  end

  private

  def render_new_search(error_message)
    flash.now[:error] = error_message
    render :new, status: :unprocessable_entity
  end

  def search_term_form_params
    params.require(:search_term_form).permit(:radius, :type)
  end
end
