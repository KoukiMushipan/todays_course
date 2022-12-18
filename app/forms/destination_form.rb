class DestinationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :description, :string
  attribute :distance, :integer
  attribute :is_saved, :boolean

  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 65535 }
  validates :distance, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 21097}
  validates :is_saved, inclusion: { in: [true, false] }

  def attributes_for_session(result)
    {name: name, description: description, distance: distance}.merge!(result[:fixed])
  end
end
