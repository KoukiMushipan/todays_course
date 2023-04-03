FactoryBot.define do
  factory :destination do
    distance { 1000 }
    association :user
    association :location
    association :departure

    trait :published_comment do
      is_saved { true }
      sequence(:comment, 'destination-comment-1')
      is_published_comment { true }
    end

    trait :not_published_comment do
      is_saved { true }
      sequence(:comment, 'destination-comment-1')
      is_published_comment { false }
    end

    trait :random do
      distance { rand(1000..5000) }
      association :departure, :random
      association :location, :random
    end
  end
end
