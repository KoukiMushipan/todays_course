class Destination < ApplicationRecord
  has_many :histories, dependent: :destroy
  belongs_to :user
  belongs_to :location, dependent: :destroy
  belongs_to :departure

  validates :comment, length: { maximum: 255 }
  validates :distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 21097}
  validates :is_saved, inclusion: { in: [true, false] }
  validates :is_published_comment, inclusion: { in: [true, false] }

  before_create -> { self.uuid = SecureRandom.uuid }
  before_create -> { self.comment = nil if comment.blank? || is_saved == false }
  before_update -> { self.comment = nil if comment.blank? || is_saved == false }
  before_create -> { self.is_published_comment = false if comment.blank? || is_saved == false }
  before_update -> { self.is_published_comment = false if comment.blank? || is_saved == false }

  scope :saved, -> { where(is_saved: true) }
  scope :with_location, -> { includes(:location, departure: :location) }
  scope :recent, -> { order(created_at: :desc) }

  scope :saved_list, -> { saved.with_location.recent }

  def attributes_for_session
    {
      uuid: uuid,
      distance: distance,
      comment: comment,
      name: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      place_id: location.place_id,
      created_at: created_at
    }
  end
end
