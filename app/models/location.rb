class Location < ApplicationRecord
  has_one :departure, dependent: :destroy
  has_one :destination, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :address, presence: true, length: { maximum: 255 }
end
