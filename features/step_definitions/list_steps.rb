Given(/^I visit the schema list page$/) do
  visit schemas_path
end

Then(/^I should see (\d+) schemas? listed$/) do |count|
  page.all("table tbody tr").count.should eql(count.to_i)
end

Then(/^I should see a paginator$/) do
  page.find('.pagination').should be_present
end