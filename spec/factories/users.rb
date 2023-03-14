FactoryBot.define do
  factory :user do
    name { 'user-name' }
    sequence(:email) { |n| "user-email-#{n}@example.com" }
    password { 'user-password' }
    password_confirmation { 'user-password' }
  end
end
