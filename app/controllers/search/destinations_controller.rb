class Search::DestinationsController < ApplicationController
  def index
    return redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"} if !session[:departure]

    return redirect_to new_search_destination_path, flash: {error: "条件を入力してください"} if !session[:search_term]

    if session[:results]
      @results = session[:results]
      @departure_info = session[:departure]
      gon.searchInfo = {results: @results, departure: @departure_info, search_term: session[:search_term]}
    else
      redirect_to new_search_destination_path, flash: {error: "条件を入力してください"}
    end
  end

  def new
    departure = Departure.find_by(uuid: params[:departure])
    session[:departure] = departure.attributes_for_session if departure

    redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"} if session[:departure]

    @departure_info = session[:departure]
    @search_term = SearchTermForm.new
  end

  def create
    @departure_info = session[:departure]
    return redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"} if !@departure_info

    @search_term = SearchTermForm.new(search_term_params)
    if !@search_term.valid?
      flash.now[:error] = '入力情報に誤りがあります'
      return render :new, status: :unprocessable_entity
    end

    results = RequestNearbyService.new(@departure_info, @search_term.radius, @search_term.type).call
    if !results
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
