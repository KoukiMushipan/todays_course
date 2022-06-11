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
  belongs_to :user
  belongs_to :location, dependent: :destroy

  def set_search_departure
    SearchDeparture.new(name: location.name, address: location.address, latitude: location.latitude, longitude: location.longitude, departure_id: id)
  end
end
