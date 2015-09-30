Then(/^I should see a schema details page$/) do
  page.body.should include("Schema Information")
end

Then(/^I should see (\d+) fields$/) do |count|
  page.all("table#fields tr").count.should eql(count.to_i + 1) # +1 because of header row
end

When(/^I check the "(.*?)" checkbox$/) do |checkbox|
  check checkbox
end

Then(/^I should not see my schema URL$/) do
  page.body.should_not include(@schema_url)
end

Then(/^I should see my schema URL$/) do
  page.body.should include(@schema_url)
end
