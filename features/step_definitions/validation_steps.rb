Then(/^I should see a page of validation results$/) do
  page.body.should include("Validation Results")
end

Then(/^I should see my URL$/) do
  page.body.should include(@url)
end

Then(/^my file should be persisted in the database$/) do
  Validation.count.should == 1
  Validation.first.filename.should == File.basename(@file)
end

Then(/^"(.*?)" should be persisted in the database$/) do |filename|
  Validation.count.should == 1
  Validation.first.filename.should == filename
end


Then(/^my file should be saved in the database$/) do
  Validation.first.csv.class.should == Tempfile
end

Then(/^my url should be persisted in the database$/) do
  Validation.count.should == 1
  Validation.first.url.should == @url
  filename = File.basename(URI.parse(@url).path)
  Validation.first.filename.should == filename
end


Then(/^the database record should have a "(.*?)" of the type "(.*?)"$/) do |category, type|
  result = Marshal.load(Validation.first.result)
  result.send(category.pluralize).first.type.should == type.to_sym
end

Then(/^the validation should be updated$/) do
  Validation.any_instance.should_receive(:update_attributes).once
end

Then(/^the validation should not be updated$/) do
  Validation.any_instance.should_not_receive(:update_attributes)
end

Given(/^it's two weeks in the future$/) do
  Timecop.freeze(2.weeks.from_now)
end

Given(/^it's three hours in the future$/) do
  Timecop.freeze(3.weeks.from_now)
end

Then(/^I should be given the option to revalidate using a different dialect$/) do
  page.should have_css('#revalidate')
end