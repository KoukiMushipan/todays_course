class DestinationsController < ApplicationController

  def new
    recommendation = session[:recommendations][params[:id].to_i]
    @search_destination = Search::Destination.create_from_recommendation(recommendation)
    session[:destination] = @search_destination.attributes.compact

    gon.routeInfo = {departure: session[:departure], destination: session[:destination]}
  end

  def create
    @search_destination = Search::Destination.new(search_destination_params)
    return render :new, status: :unprocessable_entity unless @search_destination.valid?

    if @search_destination.is_saved
      departure = Departure.set_or_create_by_session(session[:departure])
      session[:departure] = departure.set_search_departure

      destination = Destination.create_destination_by_params(@search_destination, departure)
      @search_destination = destination.set_search_destination
    end
    @search_departure = Search::Departure.new(session[:departure])
    session[:destination] = @search_destination.attributes
  end

  private

  def search_destination_params
    p = params.require(:search_destination).permit(:name, :address, :latitude, :longitude, :distance, :is_saved)
    p.merge(user_id: current_user.id)
  end
end
