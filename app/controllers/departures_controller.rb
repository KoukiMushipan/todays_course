class DeparturesController < ApplicationController
  before_action :set_departure, only: %i[show edit update destroy set]

  def index
    @departures = Departure.saved_list
  end

  def new
    @search_departure = Search::Departure.new
  end

  def create
    @search_departure = Search::Departure.new(search_departure_params)
    return render :new, status: :unprocessable_entity unless @search_departure.valid?

    result = @search_departure.request_geocoder
    unless result
      flash.now[:alert] = t('process.failed_get_location')
      return render turbo_stream: turbo_stream.update("flash", partial: "shared/flash")
    end

    @search_departure.set_coordinates_and_address(result)
    @departure = Departure.create_departure_and_location_by_search(@search_departure)
  end

  def show
    render partial: 'departure', locals: {departure: @departure}
  end

  def edit
    @search_departure = @departure.set_search_departure
  end

  def update
    @search_departure = @departure.set_search_departure
    @search_departure.attributes = departure_params
    return render :edit, status: :unprocessable_entity unless @search_departure.valid?

    @departure.location.update!(name: @search_departure.name)
    redirect_to @departure
  end

  def destroy
    @departure.update!(is_saved: false)
    render turbo_stream: turbo_stream.remove(@departure), status: :see_other
  end

  def set
    @search_departure = @departure.set_search_departure
    session[:departure] = @search_departure.attributes.compact

    redirect_to search_destination_terms_path
  end

  def cancel
    render turbo_stream: turbo_stream.update(Departure.new, '')
  end

  private

  def search_departure_params
    p = params.require(:search_departure).permit(:name, :address)
    p.merge(user_id: current_user.id, is_saved: true)
  end

  def departure_params
    params.require(:search_departure).permit(:name)
  end

  def set_departure
    @departure = current_user.departures.find(params[:id])
  end
end
