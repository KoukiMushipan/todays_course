FactoryBot.define do
  factory :departure_form do
    name { 'departure-form-name' }
    address { '東京都新宿区新宿3丁目38-1' }
    is_saved { false }
  end
end
