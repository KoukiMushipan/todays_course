class HistoriesController < ApplicationController
  def new
    destination = current_user.destinations.find_by(uuid: params[:destination])
    session[:destination] = destination.attributes_for_session if destination
    redirect_to new_destination_path, flash: {error: '目的地が設定されていません'} if !session[:destination]

    destination ||= current_user.destinations.find_by(uuid: session[:destination][:uuid])
    @destination_info = session[:destination]

    departure = destination&.departure
    session[:departure] = departure.attributes_for_session if departure
    redirect_to new_search_departure_path, flash: {error: "出発地が設定されていません"} if !session[:departure]

    @departure_info = session[:departure]
    gon.locationInfo = {departure: @departure_info, destination: @destination_info}
  end
end
