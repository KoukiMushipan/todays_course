FactoryBot.define do
  factory :departure do
    association :user
    association :location, :for_departure

    trait :another do
      association :location, :random
    end
  end
end
