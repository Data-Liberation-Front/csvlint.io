When(/^I send a GET request to view the validation$/) do
  steps %Q{
    And I send a GET request to "/validation/#{@validation.id}"
  }
end

When(/^I send a GET request to view the package$/) do
  steps %Q{
    And I send a GET request to "/package/#{@package.id}"
  }
end

Given(/^I have a package with the following URLs:$/) do |table|
  urls = table.raw.map! { |url| url[0] }
  @package = Package.create
  @package.create_package(urls)
  @package.save
end
