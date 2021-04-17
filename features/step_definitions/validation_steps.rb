Then(/^I should see a page of validation results$/) do
  page.body.should include("Validation Results")
end

Then(/^I should see my URL$/) do
  page.body.should include(@url)
end

Then(/^I should see the number of rows processed/) do
  page.body.should include("Total Rows Processed")
  # TODO - decide how to incorporate the number returned
  end

Then(/^the number of rows processed should equal (\d+)/) do | row_count|
  page.body.should include("Total Rows Processed = #{row_count}")
  # TODO - decide how to incorporate the number returned
end



Then(/^my file should be persisted in the database$/) do
  Legacy::Validation.count.should == 1
  Legacy::Validation.first.filename.should =~ /#{File.basename(@file)}/
end

Then(/^"(.*?)" should be persisted in the database$/) do |filename|
  Legacy::Validation.count.should == 1
  Legacy::Validation.first.filename.should =~ /#{filename}/
end

Then(/^my file should not be saved in the database$/) do
  Legacy::Validation.count.should == 0
end

Then(/^my url should be persisted in the database$/) do
  Legacy::Validation.count.should == 1
  Legacy::Validation.first.url.should == @url
  filename = File.basename(URI.parse(@url).path)
  Legacy::Validation.first.filename.should == filename
end


Then(/^the database record should have a "(.*?)" of the type "(.*?)"$/) do |category, type|
  result = Marshal.load(Legacy::Validation.first.result)
  result.send(category.pluralize).first.type.should == type.to_sym
end

Then(/^the validation should be updated$/) do
  Legacy::Validation.any_instance.should_receive(:update_attributes).once
end

Then(/^the validation should not be updated$/) do
  Legacy::Validation.any_instance.should_not_receive(:update_attributes)
end

Then(/^I should be given the option to revalidate using a different dialect$/) do
  page.should have_css('#revalidate')
end
