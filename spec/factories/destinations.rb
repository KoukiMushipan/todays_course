FactoryBot.define do
  factory :destination do
    uuid { SecureRandom.uuid }
    distance { 1000 }
    association :user
    association :location
    association :departure
  end
end
