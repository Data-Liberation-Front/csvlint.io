# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :schema do
    url { Faker::Internet.url }
  end
end
