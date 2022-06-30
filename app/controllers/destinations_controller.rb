class DestinationsController < ApplicationController
  before_action :set_destination, only: %i[show edit update destroy set]

  def index
    @destinations = current_user.destinations.saved_list
  end

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

  def show
    render partial: 'destination', locals: {destination: @destination}
  end

  def edit
    @search_destination = @destination.set_search_destination
  end

  def update
    @search_destination = @destination.set_search_destination
    @search_destination.attributes = destination_params
    return render :edit, status: :unprocessable_entity unless @search_destination.valid?

    @destination.location.update!(name: @search_destination.name)
    @destination.update!(distance: @search_destination.distance)
    render partial: 'destination', locals: {destination: @destination}
  end

  def destroy
    @destination.update!(is_saved: false)
    render turbo_stream: turbo_stream.remove(@destination), status: :see_other
  end

  def set
    search_departure = @destination.departure.set_search_departure
    search_destination = @destination.set_search_destination

    session[:departure] = search_departure.attributes
    session[:destination] = search_destination.attributes
    redirect_to new_history_path
  end

  private

  def search_destination_params
    p = params.require(:search_destination).permit(:name, :distance, :is_saved)
    session_destiantion = session[:destination].slice('address', 'latitude', 'longitude')
    p.merge(user_id: current_user.id).merge(session_destiantion)
  end

  def destination_params
    params.require(:search_destination).permit(:name, :distance)
  end

  def set_destination
    @destination = current_user.destinations.find(params[:id])
  end
end
