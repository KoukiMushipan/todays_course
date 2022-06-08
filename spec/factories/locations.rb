# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  adress     :string           not null
#  latitude   :float            not null
#  longitude  :float            not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :location do
    name { "MyString" }
    latitude { 1.5 }
    longitude { 1.5 }
    adress { "MyString" }
  end
end
