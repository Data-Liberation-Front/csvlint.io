When(/^we clean up old files$/) do
  Validation.clean_up(24)
end

Then(/^there should be (\d+) validation$/) do |files|
  Validation.all.count.should == files.to_i
end

Then(/^that validation's file should be deleted$/) do
  expect(FogStorage.new.find_file(Validation.first.filename)).to eq(nil)
end

Then(/^that validation's file should not be deleted$/) do
  expect(FogStorage.new.find_file(Validation.first.filename)).to_not eq(nil)
end

Then(/^the clean up task should have been requeued$/) do
  expect(Sidekiq::Extensions::DelayedClass.jobs.count).to eq(1)
end

Given(/^the clean up job causes an error$/) do
  Validation.stub(:where) { raise StandardError }
end
