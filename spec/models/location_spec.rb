# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  address    :string           not null
#  latitude   :float            not null
#  longitude  :float            not null
#  name       :string           default("未設定"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Location, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
