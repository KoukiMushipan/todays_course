FactoryBot.define do
  factory :departure_form do
    name { 'departure-form-name' }
    address { '東京都港区芝公園4丁目2-8' }
    is_saved { false }
  end
end
