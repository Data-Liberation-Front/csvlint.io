Then(/^the url "(.*?)" should be persisted in the database$/) do |url|
  Legacy::Validation.count.should == 1
  Legacy::Validation.first.url.should == url
  filename = File.basename(URI.parse(url).path)
  Legacy::Validation.first.filename.should == filename
end

Then(/^I should be redirected to my package page$/) do
  patiently do
    current_path.should == package_path(Legacy::Package.first)
  end
end

Then(/^my datapackage should be persisited in the database$/) do
  Legacy::Package.count.should == 1
end

When(/^I click on the first report link$/) do
  click_link("View report")
end
