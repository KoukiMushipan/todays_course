class GuestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string, default: 'Home'
  attribute :address, :string
  attribute :radius, :integer
  attribute :type, :string

  validates :name, length: { maximum: 50 }
  validates :address, presence: true, length: { maximum: 255 }
  validates :radius, presence: true, numericality:  { only_integer: true, in: 1_000..5_000 }
  validates :type, presence: true, inclusion: { in: Settings.google.place_type.to_h.values }, length: { maximum: 255 }

  def term
    { radius:, type: }
  end
end
