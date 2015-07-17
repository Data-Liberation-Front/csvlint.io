When(/^we clean up old files$/) do
  Validation.clean_up(24)
end

Then(/^there should be (\d+) validation$/) do |files|
  Validation.all.count.should == files.to_i
end

Then(/^that validation should not contain a file$/) do
  Validation.first.csv_id.should == nil
end

Then(/^that validation should contain a file$/) do
  Validation.first.csv_id.should_not == nil
end

Then(/^there should be (\d+) stored files in GridFs$/) do |files_no|
  Mongoid::GridFs::File.count.should == files_no.to_i
end
