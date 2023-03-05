class Destination < ApplicationRecord
  has_many :histories, dependent: :destroy
  belongs_to :user
  belongs_to :location, dependent: :destroy
  belongs_to :departure

  validates :comment, length: { maximum: 255 }
  validates :distance, presence: true, numericality: { only_integer: true, in: 1..21_097 }
  validates :is_saved, inclusion: { in: [true, false] }
  validates :is_published_comment, inclusion: { in: [true, false] }

  before_create -> { self.uuid = SecureRandom.uuid }
  before_create -> { self.comment = nil if comment.blank? || is_saved == false }
  before_create -> { self.is_published_comment = false if comment.blank? || is_saved == false }

  before_update -> { self.comment = nil if comment.blank? || is_saved == false }
  before_update -> { self.is_published_comment = false if comment.blank? || is_saved == false }

  scope :saved, -> { where(is_saved: true) }
  scope :with_location, -> { includes(:location, departure: :location) }
  scope :recent, -> { order(created_at: :desc) }

  scope :saved_list, -> { saved.with_location.recent }

  def attributes_for_session
    attributes_hash = variable_in_attributes.merge(fixed_in_attributes)
    attributes_hash.merge(uuid:, distance:, comment:, is_published_comment:, created_at:)
  end

  def attributes_for_own
    variable = variable_in_attributes.merge(uuid:)
    fixed = fixed_in_attributes.merge(is_published_comment:, created_at:)
    { variable:, fixed: }
  end

  def attributes_for_comment
    variable = variable_in_attributes.merge(uuid: SecureRandom.uuid)
    { variable:, fixed: fixed_in_attributes }
  end

  private

  def variable_in_attributes
    { name: location.name }
  end

  def fixed_in_attributes
    {
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      place_id: location.place_id,
      comment:
    }
  end
end
