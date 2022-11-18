class History < ApplicationRecord
  belongs_to :user
  belongs_to :destination
  has_one :departure, through: :destination

  validates :moving_distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 42195}

  before_create -> { self.uuid = SecureRandom.uuid }
  before_create -> { self.start_time = DateTime.now }

  scope :with_location, -> { includes(destination: [departure: :location], destination: :location) }
  scope :recent, -> { order(created_at: :desc) }

  scope :list, -> { with_location.recent }
end
