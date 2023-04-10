FactoryBot.define do
  factory :location do
    sequence(:name, 'location-name-1')

    trait :for_departure do
      latitude { '35.6896067' }
      longitude { '139.7005713' }
      address { '東京都港区芝公園4丁目2-8' }
      place_id { 'ChIJH7qx1tCMGGAR1f2s7PGhMhw' }
    end

    trait :for_destination do
      latitude { '35.7104881' }
      longitude { '139.8125376' }
      address { '東京都墨田区押上1丁目1-1-2' }
      place_id { 'ChIJYQh5P9aOGGAROVCG_6T_P3Y' }
    end

    trait :random do
      latitude { Faker::Address.latitude }
      longitude { Faker::Address.longitude }
      address { Faker::Address.state + Faker::Address.city + Faker::Address.street_name + "#{rand(1..9)}-#{rand(1..99)}" }
      place_id { Faker::Alphanumeric.alphanumeric(number: 27) }
    end
  end
end
