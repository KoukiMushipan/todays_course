FactoryBot.define do
  factory :departure do
    association :user
    association :location

    trait :random do
      association :location, :random
    end
  end
end
