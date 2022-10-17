class Search::DestinationsController < ApplicationController
  def index
  end

  def new
    departure = Departure.find_by(uuid: params[:departure])
    if departure
      @departure_info, session[:departure] = Array.new(2, departure.attributes_for_session)
    elsif session[:departure]
      @departure_info = session[:departure]
    else
      redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"}
    end
  end

  def create
  end
end
