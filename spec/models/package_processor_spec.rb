require "spec_helper"
require "package_processor"

describe PackageProcessor do

  before(:each) do
    @package = Legacy::Package.create
    mock_client = double(Pusher::Channel)
    allow(Pusher).to receive(:[]) { mock_client }
    allow(mock_client).to receive(:trigger)
  end

  it "creates a package from a url" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    processor = described_class.new({
      urls: ['http://example.com/test.csv']
    }, @package.id)
    processor.process

    expect(@package.validations.count).to eq(1)
  end

  it "creates a package from a data url" do
    processor = described_class.new({
      files_data: create_data_uri('csvs/valid.csv')
    }, @package.id)
    processor.process

    expect(@package.validations.count).to eq(1)
  end

  it "creates a package from an uploaded file" do
    processor = described_class.new({
      file_ids: [
        mock_upload('valid.csv')
      ]
    }, @package.id)
    processor.process

    expect(@package.validations.count).to eq(1)
  end

  it "creates a package from a vanilla file upload" do
    processor = described_class.new({
      files: [
        mock_uploaded_file('csvs/valid.csv')
      ]
    }, @package.id)
    processor.process

    expect(@package.validations.count).to eq(1)
  end

  it "creates a package from a zipped url" do
    mock_file("http://example.com/valid.zip", 'csvs/valid.zip')
    processor = described_class.new({
      urls: ['http://example.com/valid.zip']
    }, @package.id)
    processor.process

    expect(@package.validations.count).to eq(1)
  end

  it "joins chunks in the correct order" do
    (1..10).to_a.shuffle.each do |i|
      StoredChunk.save('chunked_file', i.to_s, i)
    end

    processor = described_class.new({
      file_ids: [
        'chunked_file,10'
      ]
    }, @package.id)
    processor.fetch_uploaded_files

    file = FogStorage.new.find_file('chunked_file')

    expect(file.body).to eq("12345678910")
  end

end
