require 'uri'
require 'zipfile'
require 'stored_csv'
require 'schema_processor'
require 'processor_helpers'
require 'stored_chunk'
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

    @files.flatten! if @files

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
    @params[:file_ids].each do |f|
      info = f.split(',')
      file = StoredChunk.join(info[0], info[1])
      @files.push fetch_file(file.key)
    end
  end

  def read_files
    @files = []
    data = @params[:files_data]
    data = [data] if data.class == String
    # converts the base64 schema to an array for parsing below
    data.each do |data|
      file = read_data_url(data)
      @files << save_file(file[:body], File.basename(file[:filename]))
    end
  end

  def unzip_urls
    @files = []
    @params[:urls].each do |url|
      if File.extname(url) == ".zip"
        @files << unzip(File.basename(url), open(url).read)
      end
    end
    @files = nil if @files.count == 0
  end

  def open_files
    @files ||= []
    @params[:files].each do |file|
      @files << save_file(file.tempfile, file.original_filename)
    end
  end

  def save_file(file, filename)
    if File.extname(filename) == ".zip"
      unzip(filename, file.read)
    else
      StoredCSV.save(file, filename)
    end
  end

  def fetch_file(filename)
    if File.extname(filename) == ".zip"
      file = StoredCSV.fetch(filename)
      unzip(filename, file.body)
    else
      StoredCSV.fetch(filename)
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
