# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :schema, class: 'legacy/schema' do
    url { Faker::Internet.url }
  end
end
