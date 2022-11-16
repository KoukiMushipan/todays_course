class CreateDestinationService
  def initialize(user, departure_info, destination, result)
    @user, @departure_info, @destination, @result = user, departure_info, destination, result
  end

  def call
    if destination.is_saved
      {destination: create_destination.attributes_for_session, success: '目的地を保存しました'}
    else
      {destination: destination.attributes_for_session(@result)}
    end
  end

  private

  attr_reader :user, :departure_info, :destination, :result

  def create_or_find_departure
    if departure_info[:uuid]
      user.departures.find_by!(uuid: departure_info[:uuid])
    else
      user.departures.create!(location: Location.create!(departure_info), is_saved: destination.is_saved)
    end
  end

  def create_location
    location_info = result[:fixed].merge(name: destination.name)
    Location.create!(location_info)
  end

  def create_destination
    departure = create_or_find_departure
    location = create_location
    user.destinations.create!(departure: departure, location: location, distance: destination.distance, is_saved: destination.is_saved)
  end
end
