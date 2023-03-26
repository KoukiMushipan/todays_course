FactoryBot.define do
  factory :location do
    name { 'location-name' }
    latitude { '35.6896067' }
    longitude { '139.7005713' }
    address { '東京都港区芝公園4丁目2-8' }
    place_id { 'ChIJH7qx1tCMGGAR1f2s7PGhMhw' }
  end
end
