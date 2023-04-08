FactoryBot.define do
  factory :departure do
    association :user
    association :location, :designated

    trait :another do
      association :location, :random
    end
  end
end
