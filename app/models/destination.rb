class Destination < ApplicationRecord
  has_many :histories, dependent: :destroy
  belongs_to :user
  belongs_to :location, dependent: :destroy
  belongs_to :departure

  validates :distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 21097}
  validates :is_saved, inclusion: { in: [true, false] }

  before_create -> { self.uuid = SecureRandom.uuid }

  def attributes_for_session
    {
      uuid: uuid,
      distance: distance,
      name: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      place_id: location.place_id,
      created_at: created_at
    }
  end
end
