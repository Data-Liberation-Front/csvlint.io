require "spec_helper"
require "package_processor"

describe PackageProcessor do

  before(:each) do
    @package = Package.create
  end

  it "creates a package from a url" do
    mock_file("http://example.com/test.csv", 'csvs/valid.csv')
    processor = PackageProcessor.new({
      urls: ['http://example.com/test.csv']
    }, @package.id)
    processor.process

    expect(@package.validations.count).to eq(1)
  end

  it "creates a package from a data url" do
    processor = PackageProcessor.new({
      files_data: create_data_uri('csvs/valid.csv')
    }, @package.id)
    processor.process

    expect(@package.validations.count).to eq(1)
  end

  it "creates a package from a chunked file" do
    processor = PackageProcessor.new({
      file_ids: [
        mock_upload('valid.csv')
      ]
    }, @package.id)
    processor.process

    expect(@package.validations.count).to eq(1)
  end

  it "creates a package from a vanilla file upload" do
    processor = PackageProcessor.new({
      files: [
        mock_uploaded_file('csvs/valid.csv')
      ]
    }, @package.id)
    processor.process

    expect(@package.validations.count).to eq(1)
  end

  it "creates a package from a zipped url" do
    mock_file("http://example.com/valid.zip", 'csvs/valid.zip')
    processor = PackageProcessor.new({
      urls: ['http://example.com/valid.zip']
    }, @package.id)
    processor.process

    expect(@package.validations.count).to eq(1)
  end

end
