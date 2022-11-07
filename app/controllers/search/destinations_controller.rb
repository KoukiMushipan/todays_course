class Search::DestinationsController < ApplicationController
  def index
    @results = session[:results]
    if @results
      @departure_info = session[:departure]
      gon.searchInfo = {results: @results, departure: @departure_info, search_term: session[:search_term]}
    else
      redirect_to new_search_destination_path, flash: {error: "条件を入力してください"}
    end
  end

  def new
    departure = Departure.find_by(uuid: params[:departure])
    if departure
      @departure_info, session[:departure] = Array.new(2, departure.attributes_for_session)
      @search_term = SearchTermForm.new
    elsif session[:departure]
      @departure_info = session[:departure]
      @search_term = SearchTermForm.new
    else
      redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"}
    end
  end

  def create
    @search_term = SearchTermForm.new(search_term_params)

    if !@search_term.valid?
      @departure_info = session[:departure]
      flash.now[:error] = '入力情報に誤りがあります'
      return render :new, status: :unprocessable_entity
    end

    results = RequestNearbyService.new(session[:departure], @search_term.radius, @search_term.type).call
    if !results
      @departure_info = session[:departure]
      flash.now[:error] = '目的地が見つかりませんでした'
      return render :new, status: :unprocessable_entity
    end

    session[:results], session[:search_term] = results, @search_term.attributes
    redirect_to search_destinations_path
  end

  private

  def search_term_params
    params.require(:search_term_form).permit(:radius, :type)
  end
end
