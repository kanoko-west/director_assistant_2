FactoryBot.define do
  factory :user do
    name { Faker::Name.initials(number: 2) }
    email { Faker::Internet.email }
    password { 'abc123' }
    password_confirmation { password }
  end
end