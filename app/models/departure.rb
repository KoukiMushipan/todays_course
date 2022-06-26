# == Schema Information
#
# Table name: departures
#
#  id          :bigint           not null, primary key
#  is_saved    :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_departures_on_location_id  (location_id)
#  index_departures_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (user_id => users.id)
#
class Departure < ApplicationRecord
  has_many :destinations, dependent: :destroy
  has_many :histories, through: :destinations
  belongs_to :user
  belongs_to :location, dependent: :destroy

  scope :saved, -> { where(is_saved: true) }
  scope :with_location, -> { includes(:location) }
  scope :sorted, -> { order(created_at: :desc) }
  scope :saved_list, -> { saved.with_location.sorted }

  def set_search_departure
    Search::Departure.new(id: id, user_id: user_id, name: location.name, address: location.address,
                          latitude: location.latitude, longitude: location.longitude, is_saved: is_saved)
  end

  def self.create_departure_and_location_by_search(search_departure)
    user = User.find(search_departure.user_id)
    location_parameter = search_departure.make_hash_for_location
    location = Location.new(location_parameter)
    user.departures.create!(location: location, is_saved: search_departure.is_saved)
  end

  def self.set_or_new_departure_by_search(search_departure)
    user = User.find(search_departure.user_id)
    if search_departure.id
      user.departures.find(search_departure.id)
    else
      location_parameter = search_departure.make_hash_for_location
      location = Location.new(location_parameter)
      user.departures.new(location: location, is_saved: search_departure.is_saved)
    end
  end
end
