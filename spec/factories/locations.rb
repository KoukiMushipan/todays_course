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
      latitude { '35.675888' }
      longitude { '139.744858' }
      address { '東京都千代田区永田町1丁目7-1' }
      place_id { 'ChIJibDhsomLGGARkIZSXvrUx0g' }
    end

    trait :random do
      latitude { Faker::Address.latitude }
      longitude { Faker::Address.longitude }
      address { random_address }
      place_id { Faker::Alphanumeric.alphanumeric(number: 27) }
    end
  end
end

def random_address
  state = Faker::Address.state
  city = Faker::Address.city
  street_name = Faker::Address.street_name
  number = "#{rand(1..9)}-#{rand(1..99)}"

  state + city + street_name + number
end
