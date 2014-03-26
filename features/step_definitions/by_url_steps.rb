Given(/^I have already validated the URL "(.*?)"$/) do |url|
  @url = url
  @validation = Validation.create_validation(@url)
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
