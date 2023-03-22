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
    location = Location.create!(departure_info.except(:is_saved))
    user.departures.create!(location:)
  end

  def create_destination(departure)
    location = Location.create!(destination_info.select { |k, _v| Location.attribute_names.map(&:to_sym).include?(k) })
    comment = destination_info[:comment]
    distance = destination_info[:distance]

    user.destinations.create!(location:, departure:, comment:, distance:)
  end

  def prepare_location_flexibly
    if destination_info[:uuid]
      user.destinations.find_by!(uuid: destination_info[:uuid])
    elsif departure_info[:uuid]
      departure = user.departures.find_by!(uuid: departure_info[:uuid])
      create_destination(departure)
    else
      departure = create_departure
      create_destination(departure)
    end
  end

  def create_history(destination)
    case course_type
    when 'one_way'
      history = user.histories.create!(destination:, moving_distance: destination.distance)
      { history:, success: 'スタートしました(片道)' }
    when 'round_trip'
      history = user.histories.create!(destination:, moving_distance: (destination.distance * 2))
      { history:, success: 'スタートしました(往復)' }
    end
  end
end
