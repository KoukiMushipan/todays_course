class History < ApplicationRecord
  belongs_to :user
  belongs_to :destination
  has_one :departure, through: :destination

  validates :start_time, presence: true
  validates :moving_distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 42195}
end
