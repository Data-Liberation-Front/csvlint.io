Then(/^my url should be displayed in the list$/) do
  page.should have_content(@url)
end

Then(/^my url should have a link to the latest report next to it$/) do
  validation = Validation.last
  find('table tbody tr:first td:last a')[:href].should eql(validation_url(validation))
end

Given(/^I visit the list page$/) do
  visit list_url
end

Then(/^I should see (\d+) validations listed$/) do |count|
  page.all("table tbody tr").count.should eql(count.to_i)
end

Then(/^I should see a paginator$/) do
  page.find('.pagination').should be_true
end