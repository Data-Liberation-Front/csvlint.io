Given(/^I have already validated the URL "(.*?)"$/) do |url|
  @url = url
  steps %{
    When I go to the homepage
    And I enter "#{url}" in the "url" field
    And I press "Validate"
  }
end

When(/^I load the validation by URL$/) do
  visit find_by_url_path(url: @url)
end
