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

  delegate :name, :latitude, :longitude, :address, :place_id, to: :location

  scope :saved, -> { where(is_saved: true) }
  scope :with_location, -> { includes(:location, departure: :location) }
  scope :recent, -> { order(created_at: :desc) }

  scope :saved_list, -> { saved.with_location.recent }

  def self.create_with_location(user, departure_info, destination_info)
    if departure_info[:uuid]
      departure = user.departures.find_by!(uuid: departure_info[:uuid])
    else
      departure = Departure.create_with_location(user, departure_info)
    end

    location = Location.create_from_info(destination_info)
    create_from_info(user, departure, location, destination_info)
  end

  def self.create_from_info(user, departure, location, destination_info)
    attribute_symboles = destination_info.slice(:comment, :distance, :is_saved, :is_published_comment)
    attributes_for_create = { user:, departure:, location: }.merge(attribute_symboles)
    create!(attributes_for_create)
  end

  def update_with_location(destination_form)
    location.update!(name: destination_form.name)
    destination_params = destination_form.attributes.except('name').compact
    update!(destination_params)
  end

  # destination_info
  def attributes_for_session
    attributes_hash = variable_in_attributes.merge(fixed_in_attributes)
    attributes_hash.merge(uuid:, distance:, comment:, is_published_comment:, created_at:)
  end

  # destination_form
  def attributes_for_form
    { name:, comment:, is_published_comment:, distance: }
  end

  # candidate
  def attributes_for_own
    variable = variable_in_attributes.merge(uuid:)
    fixed = fixed_in_attributes.merge(is_published_comment:, created_at:)
    { variable:, fixed: }
  end

  # candidate
  def attributes_for_comment
    variable = variable_in_attributes.merge(uuid: SecureRandom.uuid)
    { variable:, fixed: fixed_in_attributes }
  end

  private

  def variable_in_attributes
    { name: }
  end

  def fixed_in_attributes
    { latitude:, longitude:, address:, place_id:, comment: }
  end
end
