FactoryBot.define do
  factory :legacy_schema, class: 'legacy/schema' do
    url { Faker::Internet.url }
  end
end
