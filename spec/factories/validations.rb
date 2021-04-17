FactoryBot.define do
  factory :validation, class: 'legacy/validation' do
    url { Faker::Internet.url }
  end
end
