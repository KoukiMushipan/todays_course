class Destination < ApplicationRecord
  has_many :histories, dependent: :destroy
  belongs_to :user
  belongs_to :location, dependent: :destroy
  belongs_to :departure

  validates :distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 21097}
  validates :is_saved, inclusion: { in: [true, false] }
end
