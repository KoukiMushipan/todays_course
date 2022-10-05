class Departure < ApplicationRecord
  has_many :destinations, dependent: :destroy
  belongs_to :user
  belongs_to :location, dependent: :destroy

  validates :is_saved, inclusion: { in: [true, false] }

  before_create -> { self.uuid = SecureRandom.uuid }

  def attributes_for_session
    {
      uuid: uuid,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      place_id: location.place_id,
      created_at: created_at
    }
  end
end
