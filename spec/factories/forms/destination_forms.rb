FactoryBot.define do
  factory :destination_form do
    name { 'destination-form-name' }
    comment { 'destination-form-comment' }
    distance { 1500 }
    is_saved { false }
    is_published_comment { false }
  end
end
