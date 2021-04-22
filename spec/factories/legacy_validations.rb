FactoryBot.define do
  factory :legacy_validation, class: 'legacy/validation' do
    url { Faker::Internet.url }
  end
end
