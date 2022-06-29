class Search::DestinationsController < ApplicationController
  def terms
    @search_term = Search::Term.new
    @search_departure = Search::Departure.new(session[:departure])
  end

  def ready_recommend
    @search_term = Search::Term.new(search_term_params)
    return render :terms, status: :unprocessable_entity unless @search_term.valid?

    session[:terms] = @search_term.attributes

    redirect_to search_destination_candidates_path
  end

  def candidates
    @search_term = Search::Term.new(session[:terms])
    results = @search_term.request_local_search(session[:departure])
    return redirect_to search_destination_terms_path, alert: t('process.failed_search_recommendation') unless results

    recommendations = Search::Recommend.create_recommendations(results,  @search_term.radius)
    redirect_to search_destination_terms_path, alert: t('process.failed_matrix') unless recommendations

    session[:recommendations] = recommendations
    gon.searchInfo = {departure: session[:departure], radius: session[:terms]['radius'], recommendations: session[:recommendations]}
  end

  private

  def search_term_params
    params.require(:search_term).permit(:radius, :gc)
  end
end
