require "spec_helper"

describe Validation do
  
  it "should recheck validations" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = Validation.create_validation("http://example.com/test.csv")
    validation.state.should == "valid"
    mock_file("http://example.com/test.csv", 'csvs/errors.csv')
    validation.update_validation
    validation.state.should == "invalid"
  end
  
end