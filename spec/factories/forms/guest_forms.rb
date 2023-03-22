FactoryBot.define do
  factory :guest_form do
    name { 'guest-form-name' }
    address { '東京都新宿区新宿3丁目38-1' }
    radius { '1000' }
    type { 'convenience_store' }
  end
end
