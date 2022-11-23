class CreateHistoryService
  def initialize(user, departure_info, destination_info, course_type)
    @user, @departure_info, @destination_info, @course_type = user, departure_info, destination_info, course_type
  end

  def call
    destination = prepare_location_flexibly
    create_history(destination)
  end

  private

  attr_reader :user, :departure_info, :destination_info, :course_type

  def create_departure
    location = Location.create!(departure_info)
    departure = user.departures.create!(location: location)
  end

  def create_destination
    location = Location.create!(destination_info.select { |k, v| k != :distance })
    user.destinations.create!(location: location, departure: departure, distance: destination_info[:distance])
  end

  def prepare_location_flexibly
    if destination_info[:uuid]
      destination = user.destinations.find_by!(uuid: destination_info[:uuid])
      destination.departure
    elsif departure_info[:uuid]
      departure = user.departures.find_by!(uuid: departure_info[:uuid])
      create_destination
    else
      departure = create_departure
      create_destination
    end
  end

  def create_history(destination)
    case course_type
    when 'one_way'
      history = user.histories.create!(destination: destination, moving_distance: destination.distance)
      {history: history, success: 'スタートしました(片道)'}
    when 'round_trip'
      history = user.histories.create!(destination: destination, moving_distance: (destination.distance * 2))
      {history: history, success: 'スタートしました(往復)'}
    end
  end
end
