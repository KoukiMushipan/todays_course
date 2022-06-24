class Search::DestinationsController < ApplicationController
  def terms
    @search_term = Search::Term.new
  end

  def ready_recommend
    @search_term = Search::Term.new(search_term_params)
    return render :terms, status: :unprocessable_entity unless @search_term.valid?

    session[:terms] = @search_term.attributes
    q = l(Time.now, format: :for_reload)
    redirect_to search_candidates_path(q)
  end

  def candidates
    @search_term = Search::Term.new(session[:terms])
    results = @search_term.request_local_search(session[:departure])
    return render :terms, status: :unprocessable_entity unless results

    recommendations = Search::Recommend.create_recommendations(results,  @search_term.radius)
    unless recommendations
      @error_message = t('process.failed_matrix')
      return render :terms, status: :unprocessable_entity
    end

    session[:recommendations] = recommendations
    gon.searchInfo = {departure: session[:departure], radius: session[:terms]['radius'], recommendations: session[:recommendations]}
  end

  private

  def search_term_params
    params.require(:search_term).permit(:radius, :gc)
  end
end
