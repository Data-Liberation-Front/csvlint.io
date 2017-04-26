def load_fixture(filename)
  File.read(File.join(Rails.root, 'fixtures', filename))
end

def mock_file(url, file, content_type = "text/csv")
  stub_request(:get, "http://example.org/api/2/rest/dataset/#{url.split("/").last}").to_return(:status => 404, :body => "", :headers => {})
  stub_request(:get, "http://example.com/api/3/action/package_show?id=#{url.split("/").last}").to_return(:status => 404, :body => "", :headers => {})
  stub_request(:get, url).to_return(body: load_fixture(file), headers: {"Content-Type" => "#{content_type}; charset=utf-8; header=present"})
  stub_request(:head, url).to_return(:status => 200)
end

def mock_uploaded_file(file, content_type = "text/csv")
  upload_file = fixture_file_upload(File.join(Rails.root, 'fixtures', file), content_type)
  class << upload_file
    # The reader method is present in a real invocation,
    # but missing from the fixture object for some reason (Rails 3.1.1)
    attr_reader :tempfile
  end
  upload_file
end

def create_data_uri(file, content_type = "text/csv")
  contents = File.read File.join(Rails.root, 'fixtures', file)
  base64 = Base64.encode64(contents).gsub("\n",'')
  "#{file};data:#{content_type};base64,#{base64}"
end

def mock_upload(filename)
  identfier = rand(36**8).to_s(36)
  unique_filename = "#{identfier}#{filename}"
  @i = 0

  File.open(File.join(Rails.root, 'fixtures', 'csvs', filename)) do |file|
    chunksize = file.size / 5
    until file.eof?
      @i = @i+1
      StoredChunk.save(unique_filename, file.read(chunksize), @i)
    end
  end
  "#{unique_filename},#{@i}"
end
