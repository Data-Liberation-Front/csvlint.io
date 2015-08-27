require 'spec_helper'

describe ChunksController, type: :controller do

  describe "GET 'show'" do

    it "returns 404 if chunk does not exist" do
      get 'show', resumableIdentifier: "error", resumableFilename: "error", resumableChunkNumber: "error"
      response.code.should == "404 "
    end

    it "returns 200 if chunk exists" do
      # folder = FileUtils.mkdir_p(File.join('/', 'tmp', 'csvs', source.split("/").last + Time.now.to_i.to_s))
      dir = "/tmp/spec_chunk_id/spec_chunk.part0"
      FileUtils.mkdir_p(dir)
      File.new(dir, "r")
      get 'show', resumableIdentifier: "spec_chunk_id", resumableFilename: "spec_chunk", resumableChunkNumber: "0"
      response.code.should == "200"
    end

  end

  describe "POST 'create'" do

    it "concatenate a single chunk onto the chunk stack" do
      mock_file = mock_uploaded_file("chunks/spec_chunk.part1", nil)
      # require 'pry'
      # binding.pry
      post 'create', resumableIdentifier: "spec_chunk_id", resumableFilename: "spec_chunk",
        resumableChunkNumber: "1", resumableChunkSize: "5", resumableCurrentChunkSize: "5", resumableTotalSize: "100",
        file: mock_file
      response.code.should == "200"
    end

    it "complete file" do
      mock_file = mock_uploaded_file("chunks/spec_chunk.part1", nil)
      resumable_file_name = "spec_chunk"
      # require 'pry'
      # binding.pry
      post 'create', resumableIdentifier: "spec_chunk_id", resumableFilename: resumable_file_name,
        resumableChunkNumber: "1", resumableChunkSize: "5", resumableCurrentChunkSize: "5", resumableTotalSize: "1",
        file: mock_file
      # dir = "/tmp/spec_chunk_id/spec_chunk"
      # response.should output("File saved to #{dir}").to_stdout
      response.code.should == "200"
    end

  end

end
