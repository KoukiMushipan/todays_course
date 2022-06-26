# == Schema Information
#
# Table name: histories
#
#  id              :bigint           not null, primary key
#  end_time        :datetime
#  moving_distance :integer          not null
#  start_time      :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  destination_id  :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_histories_on_destination_id  (destination_id)
#  index_histories_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (destination_id => destinations.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe History, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
