require 'stored_csv'
require File.join(Rails.root, 'spec', 'fixture_helpers')

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
end

When(/^I attach the file "(.*?)" to the "(.*?)" field$/) do |file, field_name|
  @file = file
  if field_name == "schema_file"
    attach_file(field_name.to_sym, File.join(Rails.root, 'fixtures', @file))
  else
    filename = @file.split("/").last
    first(:xpath, "//input[@name='file_ids[]']", visible: false).set(mock_upload(filename))
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

Given(/^Javascript is enabled$/) do
  find('#no_js').set("")
end

When(/^I access my page of validation results$/) do
  visit('/package/'+ Legacy::Package.first.id)
end
