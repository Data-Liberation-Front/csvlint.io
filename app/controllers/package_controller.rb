require 'uri'
require 'zipfile'

class PackageController < ApplicationController
  before_filter :preprocess, :only => :create
  
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
    
    raise ActionController::RoutingError.new('Not Found') if @package.validations.count == 0
    
    if @package.validations.count == 1
      redirect_to validation_path(@package.validations.first)
    end
    
    @dataset = Marshal.load(@package.dataset) rescue nil
    @validations = Kaminari.paginate_array(@package.validations).page(params[:page])  
  end
  
  private
  
    def preprocess
      remove_blanks!
      params[:files] = read_files(params[:files_data]) unless params[:files_data].blank?
      params[:schema_file] = read_files(params[:schema_data]).first unless params[:schema_data].blank?
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
      else
        begin
          schema_json = JSON.parse( File.new( params[:schema_file].tempfile ).read() )
          @schema = Csvlint::Schema.from_json_table( nil, schema_json )
        rescue
          @schema = nil
        end
      end
      # Get schema URL from parameters
      @schema_url = params[:schema_url]      
    end
  
    def check_for_package
      sources = params[:urls].presence || params[:files].presence
      Package.create_package( sources, params[:schema_url], @schema )
    end
      
    def build_dialect(params)
      case params[:line_terminator]
      when "auto"
        line_terminator = :auto
      when "\\n"
        line_terminator = "\n"
      when "\\r\\n"
        line_terminator = "\r\n"
      end
    
      {
        "header" => params[:header],
        "delimiter" => params[:delimiter],
        "skipInitialSpace" => params[:skip_initial_space],
        "lineTerminator" => line_terminator,
        "quoteChar" => params[:quote_char]
      }
    end
    
    def read_files(data)
      files = []
      data = [data] if data.class == String
      data.each do |data|
        filename = data.split(";").first
        data_index = data.index('base64') + 7
        filedata = data.slice(data_index, data.length)
        basename = File.basename(filename)
        tempfile = Tempfile.new(basename)
        tempfile.write(Base64.decode64(filedata))
        tempfile.rewind
        files << ActionDispatch::Http::UploadedFile.new(:filename => filename, :tempfile => tempfile)
      end
      files
    end
    
end
