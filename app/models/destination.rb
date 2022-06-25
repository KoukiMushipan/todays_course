# == Schema Information
#
# Table name: destinations
#
#  id           :bigint           not null, primary key
#  distance     :integer          not null
#  is_saved     :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  departure_id :bigint           not null
#  location_id  :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_destinations_on_departure_id  (departure_id)
#  index_destinations_on_location_id   (location_id)
#  index_destinations_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (departure_id => departures.id)
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (user_id => users.id)
#
class Destination < ApplicationRecord
  belongs_to :user
  belongs_to :location, dependent: :destroy
  belongs_to :departure

  def set_search_destination
    Search::Destination.new(id: id, user_id: user_id, name: location.name, address: location.address,
                          latitude: location.latitude, longitude: location.longitude,
                          distance: distance, is_saved: is_saved)
  end

  def self.create_destination_by_params(destination_params, departure)
    location_parameter = destination_params.slice(:name, :address, :latitude, :longitude)
    location = Location.new(location_parameter)

    destination_parameter = destination_params.slice(:user_id, :distance, :is_saved)
    marge_params = destination_params.merge(location: location, departure: @departure)
    create!(marge_params)
  end
end
