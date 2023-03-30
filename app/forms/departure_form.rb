class DepartureForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :address, :string
  attribute :is_saved, :boolean

  validates :name, presence: true, length: { maximum: 50 }
  validates :address, presence: true, length: { maximum: 255 }
  validates :is_saved, inclusion: { in: [true, false] }, on: :check_is_saved
  validate :address_format_check

  private

  def address_format_check
    return if address.blank?

    errors.add(:address, 'は〇丁目〇〇や、〇-〇〇といった形で正確に記入してください') unless address.match(/.+[\d１-９]{1,4}[-ー丁−]{1}.{0,2}[\d０-９].*/)
  end
end
