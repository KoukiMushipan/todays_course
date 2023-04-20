FactoryBot.define do
  factory :destination do
    distance { 1000 }
    association :user
    association :location, :for_destination
    association :departure

    trait :commented do
      is_saved { true }
      sequence(:comment, 'destination-comment-1')
    end

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

    trait :another do
      distance { rand(1001..5000) }
      association :location, :random
    end
  end
end
