class Search::DestinationsController < ApplicationController
  include RequestApiMethods
  include ResponseApiMethods

  def terms
    @search_term = Search::Term.new
  end

  def ready_recommend
    @search_term = Search::Term.new(search_term_params)
    return render :terms, status: :unprocessable_entity unless @search_term.valid?

    session[:terms] = @search_term.attributes
    redirect_to search_candidates_path(I18n.l(Time.now).delete(' '))
  end

  def candidates
    search_destination = Search::Destination.new(session[:terms])
    url = search_destination.create_local_search_url(session[:departure])
    results = request_api(url)

    recommendations = Search::Recommend.set_locations(results)
    calc_distance_and_set(recommendations, search_destination.radius)

    sort_pop_set(recommendations)
    gon.searchInfo = {departure: session[:departure], terms: session[:terms], recommendations: session[:recommendations]}
  end

  private

  def search_term_params
    params.require(:search_term).permit(:radius, :gc)
  end
end
