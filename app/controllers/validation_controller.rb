require 'uri'
require 'zipfile'

class ValidationController < ApplicationController
  before_filter :preprocess, :only => :create

  def index
    validations = Validation.where(:url.ne => nil).sort_by{ |v| v.created_at }.reverse!
    validations.uniq!{ |v| v.url }
    @validations = Kaminari.paginate_array(validations).page(params[:page]).per(7)
  end

  def create  
    io = params[:urls].first.presence || params[:files].first.presence
      
    redirect_to root_path and return if io.nil?
    
    if params[:format] == "json"
      @validation = Validation.create
      io = { :body => io.read, :filename => io.original_filename } if io.respond_to?(:tempfile)
      @validation.delay.validate(io, @schema_url, @schema)
    else
      io = params[:urls].first.presence
      
      validation = Validation.create
      validation.validate(io, @schema_url, @schema)
    
      redirect_to validation_path(validation)
    end
  end

  def show
    @validation = Validation.fetch_validation(params[:id], params[:format])
    
    raise ActionController::RoutingError.new('Not Found') if @validation.state.nil?
    
    @result = @validation.validator
    @dialect = @result.dialect || Validation.standard_dialect
    # Responses
    respond_to do |wants|
      wants.html
      wants.json
      wants.png { render_badge(@validation.state, "png") }
      wants.svg { render_badge(@validation.state, "svg") }
      wants.csv { send_data standardised_csv(@validation), type: "text/csv; charset=utf-8", disposition: "attachment" }
    end
  end
  
  def update
    dialect = build_dialect(params)
    v = Validation.find(params[:id])
    v.update_validation(dialect)
    redirect_to validation_path(v)
  end
  
  private
  
    def preprocess
      remove_blanks!
      params[:files] = read_files(params[:files_data]) unless params[:files_data].nil?
      redirect_to root_path and return unless urls_valid? || params[:files].presence
      load_schema
      Zipfile.check!(params)
      package = check_for_package
      redirect_to package_path(package) and return if package
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
    
    def render_badge(state, format)
      send_file File.join(Rails.root, 'app', 'views', 'validation', "#{state}.#{format}"), disposition: 'inline'
    end
  
    def standardised_csv(validation)
      data = Marshal.load(validation.result).data
      CSV.generate(standard_csv_options) do |csv|
        data.each do |row|
          csv << row if row
        end
      end
    end
    
    def read_files(data)
      files = []
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
