class Departure < ApplicationRecord
  has_many :destinations, dependent: :destroy
  belongs_to :user
  belongs_to :location, dependent: :destroy

  validates :is_saved, inclusion: { in: [true, false] }

  before_create -> { self.uuid = SecureRandom.uuid }

  delegate :name, :latitude, :longitude, :address, :place_id, to: :location

  scope :saved, -> { where(is_saved: true) }
  scope :with_location, -> { includes(:location) }
  scope :recent, -> { order(created_at: :desc) }

  scope :saved_list, -> { saved.with_location.recent }

  def self.create_with_location(user, departure_info)
    location = Location.create_from_info(departure_info)
    create_from_info(user, location, departure_info)
  end

  def self.create_from_info(user, location, departure_info)
    attribute_symboles = departure_info.slice(:is_saved)
    attributes_for_create = { user:, location: }.merge(attribute_symboles)
    create!(attributes_for_create)
  end

  def attributes_for_session
    { uuid:, name:, latitude:, longitude:, address:, place_id:, created_at: }
  end

  # departure_form
  def attributes_for_form
    { name:, address: }
  end
end
