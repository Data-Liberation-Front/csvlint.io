require "spec_helper"
# require "byebug"

describe Validation, type: :model do

  it "should assign a TTL field to any validation formed from an uploaded CSV" do
    @file = mock_upload('csvs/valid.csv')
    validation = Validation.create_validation(@file)
    # byebug
    puts validation
    validation.expirable_created_at.should_not == nil
  end

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

  it "should not requeue a validation for images if revalidate is set to false" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = Validation.create_validation("http://example.com/test.csv")
    Validation.any_instance.should_not_receive(:delay)
    Validation.fetch_validation(validation.id, "png", false)
  end

  it "should not revalidate for html if revalidate is set to false" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = Validation.create_validation("http://example.com/test.csv")
    Validation.any_instance.should_not_receive(:check_validation)
    Validation.fetch_validation(validation.id, "html", false)
  end

  it "should only create one validation per url" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = Validation.create_validation("http://example.com/test.csv")
    Validation.count.should == 1

    validation = Validation.create_validation("http://example.com/test.csv")
    Validation.count.should == 1
  end

end
