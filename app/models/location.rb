class Location < ApplicationRecord
  has_one :departure, dependent: :destroy
  has_one :destination, dependent: :destroy

  accepts_nested_attributes_for :destination

  validates :name, presence: true, length: { maximum: 50 }
  validates :latitude, presence: true, numericality: { in: -90..90 }
  validates :longitude, presence: true, numericality: { in: -180..180 }
  validates :address, presence: true, length: { maximum: 255 }
  validates :place_id, presence: true, length: { maximum: 255 }
  validate :address_format_check

  def self.create_from_info(location_info)
    attribute_symboles = location_info.slice(:name, :latitude, :longitude, :address, :place_id)
    create!(attribute_symboles)
  end

  private

  def address_format_check
    return unless address.present?
    errors.add(:address, 'は〇丁目〇〇や、〇-〇〇といった形で正確に記入してください') unless address.match(/.+[\d１-９]{1,4}[-ー丁−]{1}.{0,2}[\d０-９].*/)
  end
end
