FactoryBot.define do
  factory :user do
    sequence(:name, 'user-name-1')
    sequence(:email) { |n| "user-email-#{n}@example.com" }
    password { 'user-password' }
    password_confirmation { 'user-password' }
  end
end
