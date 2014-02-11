When(/^I go to the homepage$/) do
  visit root_url
end

When(/^I enter "(.*?)" in the "(.*?)" field$/) do |text, field|
  instance_variable_set("@#{field}", text)
  fill_in field, with: text
end

When(/^I press "(.*?)"$/) do |name|
  click_button name
end

When(/^I attach the file "(.*?)" to the file field$/) do |file|
  attach_file(:file, File.join(Rails.root, 'fixtures', 'csvs', file))
end
