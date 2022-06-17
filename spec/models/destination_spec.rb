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
require 'rails_helper'

RSpec.describe Destination, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
