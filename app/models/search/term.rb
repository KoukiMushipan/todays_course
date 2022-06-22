class Search::Term
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :radius, :integer
  attribute :gc, :string

  validates :radius, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1000, less_than_or_equal_to: 5000}
  validates :gc, presence: true
  validate :have_gc?

  def have_gc?
    unless Settings.yahoo.gc.to_h.values.include?(gc)
      error_message = I18n.t('process.failed_select_gc')
      errors.add(:gc, error_message)
    end
  end
end
