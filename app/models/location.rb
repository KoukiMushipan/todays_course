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
class Location < ApplicationRecord
  has_one :departure, dependent: :destroy
  has_one :destination, dependent: :destroy

  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :address, presence: true

  def address=(param)
    edit_address  = param.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')
    edit_address = edit_address.gsub(/(?<=\d)[‐－―ー−](?=\d)/, "-")
    write_attribute(:address, edit_address)
  end
end
