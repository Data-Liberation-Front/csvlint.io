require 'stored_csv'

When(/^I go to the homepage$/) do
  visit root_path
end

When(/^I enter "(.*?)" in the "(.*?)" field$/) do |text, field|
  instance_variable_set("@#{field.downcase.parameterize.underscore}", text)
  if field == "url"
    fill_in "url_0", with: text
  else
    fill_in field, with: text
  end
end

When(/^I enter the CKAN repository "(.*?)" in the url field$/) do |url|
  @url = url
  fill_in "url_0", with: @url
end

When(/^I select "(.*?)" from the "(.*?)" dropdown$/) do |text, field|
  select text, from: field
end

When(/^I press "(.*?)"$/) do |name|
  click_button name
  # save_and_open_page
end

When(/^I attach the file "(.*?)" to the "(.*?)" field$/) do |file, field_name|
  @file = file
  if field_name == "schema_file"
    attach_file(field_name.to_sym, File.join(Rails.root, 'fixtures', @file))
  else
    file_path = File.open(File.join(Rails.root, 'fixtures', file))
    csv = StoredCSV.save(file_path, File.basename(file))
    # inject the file location into the hidden field
    find(:xpath, "//input[@name='files[]']").set(csv.id)
  end
end

Then(/^I should see "(.*?)"$/) do |text|
  page.body.should include(text)
end

Then(/^I should not see "(.*?)"$/) do |text|
  page.body.should_not include(text)
end

Given(/^I click on "(.*?)"$/) do |link|
  click_link link
end

Then(/^I should be redirected to the homepage$/) do
  current_path.should == "/"
end

When(/^I click the "(.*?)" tab$/) do |arg1|
  page.find('a[href="#schemafile"]').click
end
