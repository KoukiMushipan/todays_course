class DepartureForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :address, :string
  attribute :is_saved, :boolean

  validates :name, presence: true, length: { maximum: 50 }
  validates :address, presence: true, length: { maximum: 255 }
  validates :is_saved, inclusion: { in: [true, false] }, on: :check_save
end
