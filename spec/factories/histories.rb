FactoryBot.define do
  factory :history do
    moving_distance { 2000 }
    start_time { Time.zone.now }
    end_time { Time.zone.now.since(1.hour) }
    association :user
    association :destination

    trait :commented do
      sequence(:comment, 'history-comment-1')
    end

    trait :not_finished do
      end_time { nil }
    end

    trait :another do
      moving_distance { rand(2001..10_000) }
      start_time { Time.zone.now.ago(3.hours) }
      end_time { Time.zone.now.ago(1.hour) }
      association :destination, :another
    end
  end
end
