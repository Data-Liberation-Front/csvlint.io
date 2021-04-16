require "spec_helper"
# require "byebug"

describe Validation, type: :model do

  describe '#expiry_fields' do
    it "should assign a TTL field to any validation formed from an uploaded CSV file" do
      @file = mock_uploaded_file('csvs/valid.csv')
      validation = described_class.create_validation(@file)
      expect(validation.expirable_created_at).not_to eq(nil)
    end


    it "should assign the TTL field as a Mongoid index" do
      @file = mock_uploaded_file('csvs/valid.csv')
      validation = described_class.create_validation(@file)
      # retrieve the mongo collection associated with above created file, ensure that the expirable field is present
      expect(validation.collection.indexes.get(expirable_created_at: 1).present?).to eq(true)
    end

    it "should have an expiry value of 24 hours" do
      @file = mock_uploaded_file('csvs/valid.csv')
      validation = described_class.create_validation(@file)
      # retrieve the mongo collection associated with above created file, ensure that the expirable field is set to 24 hours
      validation.collection.indexes.get(expirable_created_at: 1).select{|k,v| k=="expireAfterSeconds"}.has_value?(24.hours.to_i)
    end

  end

  it "should not assign a TTL field to any validation formed from a hyperlinked CSV file" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = described_class.create_validation("http://example.com/test.csv")
    expect(validation.expirable_created_at).to eq(nil)
  end

  it "should recheck validations after two hours" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = described_class.create_validation("http://example.com/test.csv")
    expect(validation.state).to eq("valid")
    mock_file("http://example.com/test.csv", 'csvs/errors.csv')
    Timecop.freeze(DateTime.now + 2.hours) do
      validation.check_validation
      expect(validation.state).to eq("invalid")
    end
    Timecop.return
  end

  it "should not requeue a validation for images if revalidate is set to false" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = described_class.create_validation("http://example.com/test.csv")
    expect_any_instance_of(described_class).not_to receive(:delay)
    described_class.fetch_validation(validation.id, "png", false)
  end

  it "should not requeue a validation for images if revalidate is set to false as a string" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = described_class.create_validation("http://example.com/test.csv")
    expect_any_instance_of(described_class).not_to receive(:delay)
    described_class.fetch_validation(validation.id, "png", "false")
  end

  it "should not revalidate for html if revalidate is set to false" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = described_class.create_validation("http://example.com/test.csv")
    expect_any_instance_of(described_class).not_to receive(:check_validation)
    described_class.fetch_validation(validation.id, "html", false)
  end

  it "should not revalidate for html if revalidate is set to false as a string" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = described_class.create_validation("http://example.com/test.csv")
    expect_any_instance_of(described_class).not_to receive(:check_validation)
    described_class.fetch_validation(validation.id, "html", "false")
  end

  it "should only create one validation per url" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    validation = described_class.create_validation("http://example.com/test.csv")
    expect(described_class.count).to eq(1)

    validation = described_class.create_validation("http://example.com/test.csv")
    expect(described_class.count).to eq(1)
  end

  it "parse options should be created with validation" do
    @file = mock_uploaded_file('csvs/valid.csv')
    validation = described_class.create_validation(@file)
    expect(validation.parse_options).not_to eq(nil)
  end

  it "should generate parse options for older validations" do
    @file = mock_uploaded_file('csvs/valid.csv')
    validation = described_class.create_validation(@file)
    validation.parse_options = nil
    validation.save
    expect(validation.parse_options).not_to eq(nil)
  end

  it "should clean up old validations without urls" do
    @file = mock_uploaded_file('csvs/valid.csv')

    5.times { described_class.create_validation(@file) }

    Timecop.freeze(25.hours.from_now)

    7.times { described_class.create_validation(@file) }

    described_class.clean_up(24)

    expect(described_class.count).to eq(7)

    Timecop.return
  end

  it "should not delete validations with urls" do
    @file = mock_uploaded_file('csvs/valid.csv')
    mock_file('http://example.com/test.csv', 'csvs/valid.csv')

    5.times { described_class.create_validation(@file) }
    2.times do |i|
      url = "http://example.com/test#{i}.csv"
      mock_file(url, 'csvs/valid.csv')
      described_class.create_validation(url)
    end

    Timecop.freeze(25.hours.from_now)

    described_class.clean_up(24)

    expect(described_class.count).to eq(2)

    Timecop.return
  end

end
