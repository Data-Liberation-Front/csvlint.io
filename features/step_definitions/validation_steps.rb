Then(/^I should see a page of validation results$/) do
  page.body.should include("Validation Results")
  page.body.should include(@url)
end