FactoryBot.define do
  factory :destination do
    distance { 1000 }
    association :user
    association :location
    association :departure

    trait :random do
      distance { rand(1000..5000) }
      association :departure, :random
      association :location, :random
    end
  end
end
