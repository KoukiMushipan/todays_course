class Departure < ApplicationRecord
  has_many :destinations, dependent: :destroy
  belongs_to :user
  belongs_to :location, dependent: :destroy

  validates :is_saved, inclusion: { in: [true, false] }

  before_create -> { self.uuid = SecureRandom.uuid }
end
