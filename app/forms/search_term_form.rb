class SearchTermForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :radius, :integer
  attribute :type, :string

  validates :radius, presence: true, numericality: { only_integer: true, in: 1_000..5_000 }
  validates :type, presence: true, inclusion: { in: Settings.google.place_type.to_h.values }, length: { maximum: 255 }
end
