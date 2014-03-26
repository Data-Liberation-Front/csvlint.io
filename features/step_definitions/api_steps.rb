When(/^I send a GET request to view the validation$/) do
  steps %Q{
    And I send a GET request to "/validation/#{@validation.id}"
  }
end
