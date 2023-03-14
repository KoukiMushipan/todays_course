FactoryBot.define do
  factory :location do
    name { 'location-name' }
    latitude { '35.6896067' }
    longitude { '139.7005713' }
    address { '東京都新宿区新宿3丁目38-1' }
    place_id { 'ChIJH7qx1tCMGGAR1f2s7PGhMhw' }
  end
end
