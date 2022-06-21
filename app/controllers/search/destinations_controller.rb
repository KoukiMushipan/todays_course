class Search::DestinationsController < ApplicationController
  include RequestApiMethods
  include ResponseApiMethods

  def terms
    @search_destination = Search::Destination.new
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

  def ready_recommend
    session[:terms] = Search::Destination.new(search_destination_params)

    redirect_to search_candidates_path(I18n.l(Time.now).delete(' '))
  end

  private

  def search_destination_params
    params.require(:search_destination).permit(:radius, :gc)
  end
end
