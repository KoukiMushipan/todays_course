class DestinationsController < ApplicationController

  def new
    recommendation = session[:recommendations][params[:id].to_i]
    @search_destination = Search::Destination.create_from_recommendation(recommendation)
    session[:destination] = @search_destination.attributes.compact

    gon.routeInfo = {departure: session[:departure], destination: session[:destination]}
  end

  def create
    @search_departure = Search::Departure.new(session[:departure])
    @search_destination = Search::Destination.new(search_destination_params)
    return render :new, status: :unprocessable_entity unless @search_destination.valid?

    if @search_destination.is_saved
      departure = Departure.set_or_new_departure_by_search(@search_departure)
      @search_departure = departure.set_search_departure

      destination = Destination.create_destination_by_search(@search_destination, departure)
      @search_destination = destination.set_search_destination
    end
    session[:departure] = @search_departure.attributes
    session[:destination] = @search_destination.attributes
  end

  private

  def search_destination_params
    p = params.require(:search_destination).permit(:name, :distance, :is_saved)
    session_destiantion = session[:destination].slice('address', 'latitude', 'longitude')
    p.merge(user_id: current_user.id).merge(session_destiantion)
  end
end
