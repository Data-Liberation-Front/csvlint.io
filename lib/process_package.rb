require 'uri'
require 'zipfile'
require 'data_uri/open_uri'
require 'stored_csv'

class ProcessPackage

  def initialize(params, package_id)
    @params = params
    @package_id = package_id
  end

  def process
    read_files unless @params[:files_data].blank?
    join_chunks unless @params[:file_ids].blank?
    fetch_files unless @params[:files].blank?
    unzip_urls unless @params[:urls].blank?
    load_schema
    package = Package.find(@package_id)
    package.create_package(@files || @params[:urls], @schema_url, @schema)
  end

  def join_chunks
    @params[:files] ||= []
    @params[:file_ids].each do |f|
      target_file = Tempfile.new(f)
      target_file.binmode
      chunks = Mongoid::GridFs::File.where("metadata.resumableFilename" => f)
      chunks.each do |chunk|
        chunk.data.each_line do |line|
          target_file.write(line)
        end
        chunk.delete
      end

      target_file.rewind

      stored_csv = StoredCSV.save(target_file, f)
      @params[:files] << stored_csv.id
    end
  end

  def unzip_urls
    @files = []
    @params[:urls].each do |url|
      if File.extname(url) == ".zip"
        @files << unzip(File.basename(url), open(url).read)
      end
    end
    @files.flatten!
    @files = nil if @files.count == 0
  end

  def fetch_files
    @files = []
    @params[:files].each do |id|
      @files << fetch_file(id)
    end
    @files.flatten!
  end

  def fetch_file(id)
    stored_csv = Mongoid::GridFs.get(id)
    filename = stored_csv.metadata[:filename]
    if File.extname(filename) == ".zip"
      unzip(filename, stored_csv.data)
    else
      {
        :csv_id => id,
        :filename => filename
      }
    end
  end

  def unzip(filename, data)
    tempfile = Tempfile.new(filename)
    tempfile.binmode
    tempfile.write(data)
    tempfile.rewind
    Zipfile.unzip(tempfile, :file)
  end

  def read_data_url(data)
    file_array = data.split(";", 2)
    uri = URI::Data.new(file_array[1])
    {
      filename: file_array[0],
      body: open(uri)
    }
  end

  def read_files
    @files = []
    data = @params[:files_data]
    data = [data] if data.class == String
    # converts the base64 schema to an array for parsing below
    data.each do |data|
      file = read_data_url(data)
      stored_csv = StoredCSV.save(file[:body], File.basename(file[:filename]))
      @files << fetch_file(stored_csv.id)
    end
    @files.flatten!
  end

  def load_schema
    # Check that schema checkbox is ticked
    return unless @params[:schema] == "1"

    # Load schema
    if @params[:schema_url].presence
      @schema = Csvlint::Schema.load_from_json_table(@params[:schema_url])
      @schema_url = @params[:schema_url]
    elsif @params[:schema_data] || @params[:schema_file]
      if @params[:schema_data]
        data = read_data_url(@params[:schema_data])[:body].read
      else
        data = @params[:schema_file].tempfile.read
      end

      begin
        json = JSON.parse(data)
        @schema = Csvlint::Schema.from_json_table( nil, json )
      rescue JSON::ParserError
        # catch JSON parse error
        # this rescue requires further work, currently in place to catch malformed or bad json uploaded schemas
        @schema = Csvlint::Schema.new(nil, [], "malformed", "malformed")
      end
    end
    # Get schema URL from parameters
    @schema_url = @params[:schema_url]
  end


end
