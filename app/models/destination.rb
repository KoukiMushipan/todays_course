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
  has_many :histories, dependent: :destroy
  belongs_to :user
  belongs_to :location, dependent: :destroy
  belongs_to :departure

  validates :distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 21097}
  validates :is_saved, inclusion: { in: [true, false] }

  def set_search_destination
    Search::Destination.new(id: id, user_id: user_id, name: location.name, address: location.address,
                          latitude: location.latitude, longitude: location.longitude,
                          distance: distance, is_saved: is_saved)
  end

  def self.create_destination_by_search(search_destination, departure)
    location_parameter = search_destination.make_hash_for_location
    location = Location.new(location_parameter)

    user = User.find(search_destination.user_id)
    destination_parameter = search_destination.make_hash_for_destination
    marge_params = destination_parameter.merge(location: location, departure: departure)
    user.destinations.create!(marge_params)
  end

  def self.set_or_new_destination_by_search(search_destination, departure)
    user = User.find(search_destination.user_id)
    if search_destination.id
      user.destinations.find(search_destination.id)
    else
      location_parameter = search_destination.make_hash_for_location
      location = Location.new(location_parameter)

      destination_parameter = search_destination.make_hash_for_destination
      marge_params = destination_parameter.merge(location: location, departure: departure)
      user.destinations.new(marge_params)
    end
  end
end
