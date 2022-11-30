class GestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string, default: 'Home'
  attribute :address, :string
  attribute :radius, :integer
  attribute :type, :string

  validates :address, presence: true, length: { maximum: 255 }
  validates :radius, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1000, less_than_or_equal_to: 5000}
  validates :type, presence: true, inclusion: { in: Settings.google.place_type.to_h.values }

  def term
    {radius: radius, type: type}
  end
end
