Given(/^I have already validated the URL "(.*?)"$/) do |url|
  @url = url
  @validation = Legacy::Validation.create_validation(@url)
end

Given(/^I have not already validated the URL "(.*?)"$/) do |url|
  @url = url
  validation = Legacy::Validation.where(:url => @url).first
  expect(validation).to eq(nil)
end

When(/^I load the validation by URL$/) do
  visit root_path(uri: @url)
end

When(/^I load the validation badge by URL in "(.*?)" format$/) do |format|
  visit root_path(uri: @url, format: format)
end

Then(/^I should get a badge in "(.*?)" format$/) do |format|
  page.response_headers['Content-Type'].should =~ /#{format}/
end

Then(/^I should get a (\d+) response$/) do |arg1|
  expect(page.status_code).to eq(arg1.to_i)
end
