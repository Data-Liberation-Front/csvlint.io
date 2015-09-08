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

  it "joins chunks in the correct order" do
    (0..10).to_a.shuffle.each do |i|
      tempfile = Tempfile.new(i.to_s)
      tempfile.binmode
      tempfile.write(i)
      tempfile.rewind
      stored_chunk = Mongoid::GridFs.put(tempfile)
      stored_chunk.metadata = { resumableFilename: 'chunked_file', resumableChunkNumber: i.to_s}
      stored_chunk.save
    end

    processor = PackageProcessor.new({
      file_ids: ['chunked_file']
      }, @package.id)
    processor.join_chunks

    file = processor.instance_variable_get("@files").first
    file = Mongoid::GridFs.get(file[:csv_id])

    expect(file.data).to eq("012345678910")
  end

end
