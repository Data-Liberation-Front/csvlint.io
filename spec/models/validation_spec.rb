require "spec_helper"

describe Validation do
  
  it "should recheck validations after two hours" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = Validation.create_validation("http://example.com/test.csv")
    validation.state.should == "valid"
    mock_file("http://example.com/test.csv", 'csvs/errors.csv')
    Timecop.freeze(DateTime.now + 2.hours) do
      validation.check_validation
      validation.state.should == "invalid"
    end
  end
  
end