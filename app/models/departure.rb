class Departure < ApplicationRecord
  has_many :destinations, dependent: :destroy
  belongs_to :user
  belongs_to :location, dependent: :destroy

  validates :is_saved, inclusion: { in: [true, false] }

  before_create -> { self.uuid = SecureRandom.uuid }

  scope :saved, -> { where(is_saved: true) }
  scope :with_location, -> { includes(:location) }
  scope :recent, -> { order(created_at: :desc) }

  scope :saved_list, -> { saved.with_location.recent }

  def attributes_for_session
    {
      uuid: uuid,
      name: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      place_id: location.place_id,
      created_at: created_at
    }
  end
end
