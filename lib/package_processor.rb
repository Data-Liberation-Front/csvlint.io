require 'uri'
require 'zipfile'
require 'stored_csv'
require 'schema_processor'
require 'processor_helpers'
require 'fog_storage'

class PackageProcessor
  include ProcessorHelpers

  def initialize(params, package_id)
    @params = params
    @package_id = package_id
  end

  def process
    read_files unless @params[:files_data].blank?
    fetch_uploaded_files unless @params[:file_ids].blank?
    open_files unless @params[:files].blank?
    unzip_urls unless @params[:urls].blank?

    create_package
  end

  def package
    Package.find(@package_id)
  end

  def create_package
    if schema_present?
      schema = SchemaProcessor.new(url: @params[:schema_url], file: @params[:schema_file], data: @params[:schema_data])
      package.create_package(@files || @params[:urls], schema.url, schema.schema)
    else
      package.create_package(@files || @params[:urls])
    end
  end

  def schema_present?
    !@params[:schema].nil? ||
    @params[:schema_file].present? && @params[:no_js].present? ||
    @params[:schema_url].present? && @params[:no_js].present?
  end

  def fetch_uploaded_files
    @files ||= []
    params[:file_ids].each do |f|
      @files.push StoredCSV.fetch(f)
    end
  end

  def fog
    FogStorage.new
  end

  def read_files
    @files = []
    data = @params[:files_data]
    data = [data] if data.class == String
    # converts the base64 schema to an array for parsing below
    data.each do |data|
      file = read_data_url(data)
      stored_csv = StoredCSV.save(file[:body], File.basename(file[:filename]))
      @files << stored_csv
    end
    @files.flatten!
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

  def open_files
    @files ||= []
    @params[:files].each do |file|
      stored_csv = StoredCSV.save(file.tempfile, file.original_filename)
      @files << stored_csv
    end
  end

  def unzip(filename, data)
    tempfile = Tempfile.new(filename)
    tempfile.binmode
    tempfile.write(data)
    tempfile.rewind
    Zipfile.unzip(tempfile, :file)
  end

end
