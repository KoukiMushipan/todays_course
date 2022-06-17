module DestinationMethods
  extend ActiveSupport::Concern

  def new_destination_by_params(departure)
    location = Location.new(location_params)
    marge_params = destination_params.merge(location: location, departure: @departure)
    current_user.destinations.new(marge_params)
  end

  private

  def location_params
    location_params = params.require(:search_destination).permit(:name, :address, :latitude, :longitude, :distance, :is_saved)
    location_params.slice(:name, :address, :latitude, :longitude)
  end

  def destination_params
    destination_params = params.require(:search_destination).permit(:name, :address, :latitude, :longitude, :distance, :is_saved)
    destination_params.slice(:distance, :is_saved)
  end
end
