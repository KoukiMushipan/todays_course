FactoryBot.define do
  factory :guest_form do
    name { 'guest-form-name' }
    address { '東京都港区芝公園4丁目2-8' }
    radius { '1000' }
    type { 'convenience_store' }
  end
end
