class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :departures, dependent: :destroy
  has_many :destinations, dependent: :destroy
  has_many :histories, dependent: :destroy

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true, presence: true
  validates :name, length: { maximum: 50 }
end
