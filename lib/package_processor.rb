require 'uri'
require 'zipfile'
require 'stored_csv'
require 'schema_processor'
require 'processor_helpers'

class PackageProcessor
  include ProcessorHelpers

  def initialize(params, package_id)
    @params = params
    @package_id = package_id
  end

  def process
    # TODO when the file_helper is used without JS it is sending params with both  :file_ids and :files, triggering join_chunks AND open_files
    read_files unless @params[:files_data].blank?
    # join_chunks unless @params[:file_ids].blank?
    if @params[:file_ids]
      join_chunks unless !@params[:file_ids].any?(&:present?)
    end
    # && !@params[:file_ids].any?(&:present?)
    # join_chunks if @params[:file_ids].any?
    # TODO - the above is always triggered, need to know why that is
    open_files unless @params[:files].blank?
    unzip_urls unless @params[:urls].blank?

    create_package
  end

  def package
    Package.find(@package_id)
  end

  def create_package
    if (@params[:schema_data].nil? && @params[:schema_file].nil? && @params[:schema_url].nil?)
      package.create_package(@files || @params[:urls])
    else
      schema = SchemaProcessor.new(url: @params[:schema_url], file: @params[:schema_file], data: @params[:schema_data])
      # TODO - fallback schema upload does not have schema or schema_data attributes
      # byebug
      package.create_package(@files || @params[:urls], schema.url, schema.schema)
      # TODO the problem might be happening here - if @files has too many variables
      # then sources.each do |source| block creates extra validations
      # and
    end
  end

  def join_chunks
    # byebug
    @files ||= []
    @params[:file_ids].each do |f|
      target_file = Tempfile.new(f)
      target_file.binmode
      chunks = Mongoid::GridFs::File.where("metadata.resumableFilename" => f).to_a
      chunks.sort_by! { |s| s.metadata["resumableChunkNumber"].to_i }

      chunks.each do |chunk|
        target_file.write(chunk.data)
        chunk.delete
      end

      target_file.rewind

      stored_csv = StoredCSV.save(target_file, f)
      @files << fetch_file(stored_csv.id)
    end
    @files.flatten!
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
      # Tempfile, String
      @files << fetch_file(stored_csv.id)
    end
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

end
