require 'uri'
require 'zipfile'
require 'data_uri/open_uri'

class PackageController < ApplicationController
  before_filter :preprocess, :only => :create

  before_filter(:only => [:show]) { alternate_formats [:json] }

  def create
    io = params[:urls].presence || params[:files].presence

    if io.first.respond_to?(:tempfile)
      io = io.map! do |io|
        stored_csv = Mongoid::GridFs.put(StringIO.new(io.read))
        {
          :csv_id => stored_csv.id,
          :filename => io.original_filename
        }
      end
    end

    redirect_to root_path and return if io.nil?

    if params[:format] == "json"
      @package = Package.create
      @package.delay.create_package(io, @schema_url, @schema)
    else
      package = Package.create
      package.create_package(io, @schema_url, @schema)

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
      params[:schema_file] = read_files(params[:schema_data]).first unless params[:schema_data].blank?
      # both the above do not run as unless evals to true when a file is uploaded OR when a URL is uploaded
      redirect_to root_path and return unless urls_valid? || params[:files].presence

      load_schema
      Zipfile.check!(params)
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
      params[:files_data].reject! { |data| data.blank? } unless params[:files_data].blank?
    end

    def load_schema

      # Check that schema checkbox is ticked
      return unless params[:schema] == "1"
      # Load schema
      io = params[:schema_url].presence || params[:schema_file].presence
      if io.class == String
        @schema = Csvlint::Schema.load_from_json_table(io)
        @schema_url = params[:schema_url]
      else
        begin
          schema_json = JSON.parse( File.new( params[:schema_file].tempfile ).read() )
          @schema = Csvlint::Schema.from_json_table( nil, schema_json )

        rescue JSON::ParserError
          @schema = Csvlint::Schema.new(nil, [], "malformed", "malformed")
          # cludge - array has to be empty due to how these schemas are created in gem,
          # populating said array with strings will result in undefined method `name' for "name":String
        rescue
          @schema = nil
        end
        @schema_url = true
        # kludge solution, awaiting a logic change but which requires a refactor of schema_url across project
      end

      # Get schema URL from parameters
      # @schema_url = params[:schema_url]
    end

    def check_for_package
      sources = params[:urls].presence || params[:files].presence
      Package.create_package( sources, params[:schema_url], @schema )
    end

    def read_files(data)

      files = []
      data = [data] if data.class == String
      data.each do |data|
        file_array = data.split(";", 2)
        filename = file_array[0]
        uri = URI::Data.new(file_array[1])

        io = open(uri)
        basename = File.basename(filename)
        tempfile = Tempfile.new(basename)
        tempfile.binmode
        tempfile.write(io.read)
        tempfile.rewind
        file = ActionDispatch::Http::UploadedFile.new(:filename => filename,
                                                      :tempfile => tempfile
                                                      )
        file.content_type = io.content_type
        files << file
      end
      files
    end

end
