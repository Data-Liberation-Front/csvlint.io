Then(/^my url should be displayed in the list$/) do
  page.should have_content(@url)
end

Then(/^my url should have a link to the latest report next to it$/) do
  validation = Validation.last
  page.all('table tbody tr:first a')[0][:href].should eql(validation_url(validation))
end

Given(/^I visit the list page$/) do
  visit validation_index_path
end

Given(/^I visit the schema list page$/) do
  visit schemas_path
end

Then(/^I should see (\d+) (validations?|schemas?) listed$/) do |count, model|
  page.all("table tbody tr").count.should eql(count.to_i)
end

Then(/^I should see a paginator$/) do
  page.find('.pagination').should be_true
end