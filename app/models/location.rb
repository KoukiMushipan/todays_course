class Location < ApplicationRecord
  has_one :departure, dependent: :destroy
  has_one :destination, dependent: :destroy

  accepts_nested_attributes_for :destination

  validates :name, presence: true, length: { maximum: 50 }
  validates :latitude, presence: true, numericality: { in: -90..90 }
  validates :longitude, presence: true, numericality: { in: -180..180 }
  validates :address, presence: true, length: { maximum: 255 }
  validates :place_id, presence: true, length: { maximum: 255 }

  def self.create_from_info(location_info)
    attribute_symboles = location_info.slice(:name, :latitude, :longitude, :address, :place_id)
    create!(attribute_symboles)
  end
end
