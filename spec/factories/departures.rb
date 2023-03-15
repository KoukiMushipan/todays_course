FactoryBot.define do
  factory :departure do
    association :user
    association :location
  end
end
