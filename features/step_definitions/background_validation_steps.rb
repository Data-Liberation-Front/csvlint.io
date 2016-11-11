require 'package_processor'

Then(/^my CSV should be placed in a background job$/) do
  Package.should_receive(:delay).and_call_original
end

When(/^I wait for the ajax request to finish$/) do
  start_time = Time.now
  page.evaluate_script('').class.should_not eql(String) until page.evaluate_script('jQuery.isReady&&jQuery.active==0') or (start_time + 5.seconds) < Time.now do
    sleep 1
  end
end

When(/^the CSV has finished processing$/) do
  Sidekiq::Extensions::DelayedClass.drain
end

When(/^I wait for the package to be created$/) do
  patiently do
    Package.first.should_not be_nil
  end
end

Then(/^I should be redirected to my validation results$/) do
  patiently do
    current_path.should == validation_path(Validation.first)
  end
end
