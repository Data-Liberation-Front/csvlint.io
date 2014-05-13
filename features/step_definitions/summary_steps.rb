Given(/^that a Summary has been generated$/) do
  @summary = Summary.generate
  @summary.save
end

When(/^I send a GET request to view the statistics$/) do
  steps %Q{
    And I send a GET request to "/statistics"
  }
end

