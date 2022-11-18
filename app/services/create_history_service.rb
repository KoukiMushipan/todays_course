class CreateHistoryService
  def initialize(user, departure_info, destination_info, course_type)
    @user, @departure_info, @destination_info, @course_type = user, departure_info, destination_info, course_type
  end

  def call
    if destination_info[:uuid]
      destination = user.destinations.find_by!(uuid: destination_info[:uuid])
      departure = destination.departure
    elsif departure_info[:uuid]
      departure = user.departures.find_by!(uuid: departure_info[:uuid])
      location = Location.create!(destination_info.select { |k, v| k != :distance })
      destination = user.destinations.create!(location: location, departure: departure, distance: destination_info[:distance])
    else
      departure_location = Location.create!(departure_info)
      departure = user.departures.create!(location: departure_location)
      destination_location = Location.create!(destination_info.select { |k, v| k != :distance })
      destination = user.destinations.create!(location: destination_location, departure: departure, distance: destination_info[:distance])
    end

    case course_type
    when 'one_way'
      user.histories.create!(destination: destination, moving_distance: destination.distance)
    when 'round_trip'
      user.histories.create!(destination: destination, moving_distance: (destination.distance * 2))
    end
  end

  private

  attr_reader :user, :departure_info, :destination_info, :course_type
end
