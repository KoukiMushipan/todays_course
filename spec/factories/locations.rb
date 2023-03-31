FactoryBot.define do
  factory :location do
    sequence(:name, 'location-name-1')
    latitude { '35.6896067' }
    longitude { '139.7005713' }
    address { '東京都港区芝公園4丁目2-8' }
    place_id { 'ChIJH7qx1tCMGGAR1f2s7PGhMhw' }

    trait :random do
      latitude { Faker::Address.latitude }
      longitude { Faker::Address.longitude }
      address { Faker::Address.state + Faker::Address.city + Faker::Address.street_name + "#{rand(1..9)}-#{rand(1..99)}" }
      place_id { Faker::Alphanumeric.alphanumeric(number: 27) }
    end
  end
end
