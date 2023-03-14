FactoryBot.define do
  factory :history do
    uuid { SecureRandom.uuid }
    moving_distance { 2000 }
    start_time { Time.zone.now }
    end_time { Time.zone.now.since(1.hour) }
    association :user
    association :destination
  end
end
