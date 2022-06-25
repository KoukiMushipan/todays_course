module ShareSearch
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include ActiveModel::Attributes
    include RequestApiMethods
    include ResponseApiMethods

    attribute :id, :integer
    attribute :user_id, :integer
    attribute :name, :string
    attribute :address, :string
    attribute :latitude, :float
    attribute :longitude, :float
    attribute :is_saved, :boolean

    validates :name, length: { maximum: 50 }
    validates :address, presence: true, length: { maximum: 255 }
  end
end
