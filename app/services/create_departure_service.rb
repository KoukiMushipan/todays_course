class CreateDepartureService
  def initialize(user, departure_info, is_saved)
    @user, @departure_info, @is_saved = user, departure_info, is_saved
  end

  def call
    if is_saved
      departure = create_departure
      {departure: departure.attributes_for_session, success: '出発地を保存しました'}
    else
      {departure: departure_info}
    end
  end

  private

  attr_reader :user, :departure_info, :is_saved

  def create_location
    Location.create!(departure_info)
  end

  def create_departure
    location = create_location
    user.departures.create!(location: location, is_saved: is_saved)
  end
end
