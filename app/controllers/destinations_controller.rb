class DestinationsController < ApplicationController
  include DepartureMethods
  include DestinationMethods

  def new
    recommendation = session[:recommendations][params[:id].to_i]
    @destination = Search::Destination.create_from_recommendation(recommendation)
    session[:destination] = @destination

    gon.routeInfo = {departure: session[:departure], destination: session[:destination]}
  end

  def create
    case search_destination_params[:is_saved]
    when '1'
      @departure = set_departure(current_user, session[:departure])
      @destination = new_destination_by_params(@departure)
      @destination.save
    when '0'
      session[:destination] = Search::Destination.new(search_destination_params)
    end
  end

  private

  def search_destination_params
    params.require(:search_destination).permit(:name, :address, :latitude, :longitude, :distance, :is_saved)
  end
end
