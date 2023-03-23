class DestinationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :comment, :string
  attribute :distance, :integer
  attribute :is_saved, :boolean
  attribute :is_published_comment, :boolean

  validates :name, presence: true, length: { maximum: 50 }
  validates :comment, length: { maximum: 255 }
  validates :distance, presence: true, numericality: { only_integer: true, in: 1..21_097 }
  validates :is_saved, inclusion: { in: [true, false] }
  validates :is_published_comment, inclusion: { in: [true, false] }

  def attributes_for_session(candidate)
    { name:, distance: }.merge!(candidate[:fixed])
  end
end
