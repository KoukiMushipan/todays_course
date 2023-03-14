FactoryBot.define do
  factory :departure do
    uuid { SecureRandom.uuid }
    association :user
    association :location
  end
end
