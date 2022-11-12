class HistoriesController < ApplicationController
  def new
    destination = current_user.destinations.find_by(uuid: params[:destination])

    if destination
      @destination_info, session[:destination] = Array.new(2, destination.attributes_for_session)
      @departure_info = destination.departure.attributes_for_session
    elsif session[:departure] && session[:destination]
      @departure_info, @destination_info = session[:departure], session[:destination]
    else
      redirect_to new_destination_path, flash: {error: '目的地が設定されていません'}
    end

    gon.locationInfo = {departure: @departure_info, destination: @destination_info}
  end
end
