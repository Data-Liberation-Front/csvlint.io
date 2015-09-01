require 'uri'
require 'zipfile'
require 'data_uri/open_uri'
require 'stored_csv'

class PackageController < ApplicationController
  before_filter :preprocess, :only => :create

  # preprocess performs necessary formatting of appended or hyperlinked files on the CSVlint frontend

  before_filter(:only => [:show]) { alternate_formats [:json] }

  def create
    urls = params[:urls].presence

    redirect_to root_path and return if urls.blank? && @files.nil?

    if params[:format] == "json"
      @package = Package.create
      @package.delay.create_package(@files || urls, @schema_url, @schema)
    else
      package = Package.create
      package.create_package(@files || urls, @schema_url, @schema)

      if package.validations.count == 1
        redirect_to validation_path(package.validations.first)
      else
        redirect_to package_path(package)
      end
    end
  end

  def show
    @package = Package.find( params[:id] )

    if @package.validations.count == 1 && params[:format] != "json"
      redirect_to validation_path(@package.validations.first)
    end

    @dataset = Marshal.load(@package.dataset) rescue nil
    @validations = @package.validations
  end

  private

    def preprocess
      remove_blanks!
      params[:files] = read_files(params[:files_data]) unless params[:files_data].blank?
      fetch_files unless params[:files].blank?
      unzip_urls unless params[:urls].blank?
      redirect_to root_path and return unless urls_valid? || params[:files].presence
      load_schema
    end

    def unzip_urls
      @files = []
      params[:urls].each do |url|
        if File.extname(url) == ".zip"
          @files << unzip(File.basename(url), open(url).read)
        end
      end
      @files.flatten!
      @files = nil if @files.count == 0
    end

    def fetch_files
      @files = []
      params[:files].each do |id|
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

    def urls_valid?
      return false if params[:urls].blank?
      params[:urls].each do |url|
        return false if url.blank?
        # Check it's valid
        begin
          url = URI.parse(url)
          return false unless ['http', 'https'].include?(url.scheme)
        rescue URI::InvalidURIError
          return false
        end
      end
      return true
    end

    def remove_blanks!
      params[:urls].reject! { |url| url.blank? } unless params[:urls].blank?
      params[:files].reject! { |data| data.blank? } unless params[:files].blank?
    end

    def load_schema
      # Check that schema checkbox is ticked
      return unless params[:schema] == "1"

      # Load schema
      if params[:schema_url].presence
        @schema = Csvlint::Schema.load_from_json_table(params[:schema_url])
        @schema_url = params[:schema_url]
      elsif params[:schema_data] || params[:schema_file]
        if params[:schema_data]
          data = read_data_url(params[:schema_data])[:body].read
        else
          data = params[:schema_file].tempfile.read
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
      @schema_url = params[:schema_url]
    end

    def check_for_package
      sources = params[:urls].presence || params[:files].presence
      Package.create_package( sources, params[:schema_url], @schema )
    end

    def read_data_url(data)
      file_array = data.split(";", 2)
      uri = URI::Data.new(file_array[1])
      {
        filename: file_array[0],
        body: open(uri)
      }
    end

    def read_files(data)
      files = []
      data = [data] if data.class == String
      # converts the base64 schema to an array for parsing below
      data.each do |data|
        file = read_data_url(data)
        stored_csv = StoredCSV.save(file[:body], File.basename(file[:filename]))
        files << stored_csv.id
      end
      files
    end

end
