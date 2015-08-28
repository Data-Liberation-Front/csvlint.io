require "spec_helper"
# require "byebug"

describe Validation, type: :model do

  describe '#expiry_fields' do
    it "should assign a TTL field to any validation formed from an uploaded CSV file" do
      @file = mock_uploaded_file('csvs/valid.csv')
      validation = Validation.create_validation(@file)
      validation.expirable_created_at.should_not == nil
    end


    it "should assign the TTL field as a Mongoid index" do
      @file = mock_uploaded_file('csvs/valid.csv')
      validation = Validation.create_validation(@file)
      # retrieve the mongo collection associated with above created file, ensure that the expirable field is present
      validation.collection.indexes[expirable_created_at: 1].present?.should == true
    end

    it "should have an expiry value of 24 hours" do
      @file = mock_uploaded_file('csvs/valid.csv')
      validation = Validation.create_validation(@file)
      # retrieve the mongo collection associated with above created file, ensure that the expirable field is set to 24 hours
      validation.collection.indexes[expirable_created_at: 1].select{|k,v| k=="expireAfterSeconds"}.has_value?(24.hours.to_i)
    end

  end

  it "should not assign a TTL field to any validation formed from a hyperlinked CSV file" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = Validation.create_validation("http://example.com/test.csv")
    validation.expirable_created_at.should == nil
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
    Timecop.return
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

  it "parse options should be created with validation" do
    @file = mock_uploaded_file('csvs/valid.csv')
    validation = Validation.create_validation(@file)
    validation.parse_options.should_not == nil
  end

  it "should generate parse options for older validations" do
    @file = mock_uploaded_file('csvs/valid.csv')
    validation = Validation.create_validation(@file)
    validation.parse_options = nil
    validation.save
    validation.parse_options.should_not == nil
  end

end
