Then(/^I should see a page of validation results$/) do
  page.body.should include("Validation Results")
end

Then(/^I should see my URL$/) do
  page.body.should include(@url)
end