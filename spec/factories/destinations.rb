FactoryBot.define do
  factory :destination do
    distance { 1000 }
    association :user
    association :location
    association :departure
  end
end
