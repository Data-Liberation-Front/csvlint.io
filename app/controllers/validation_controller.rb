require 'uri'
require 'zip'

class ValidationController < ApplicationController
  before_filter :manage_urls, :only => :create

  def index
    if params[:uri]
      validator = Validation.where(:url => params[:uri]).first
      render status: 404 and return if validator.nil?
      redirect_to validation_path(validator, format: params[:format]), status: 303
    end
  end

  def create            
    load_schema
    check_zipfile
    package = check_for_package
    redirect_to package_path(package) and return if package
    
    io = params[:urls].first.presence || params[:files].first.presence
    
    redirect_to root_path and return if io.nil?
          
    validation = Validation.create_validation(io, @schema_url, @schema)
    redirect_to validation_path(validation)
  end

  def show
    @validation = Validation.fetch_validation(params[:id])
    @result = Marshal.load(@validation.result)
    @dialect = @result.dialect || Validation.standard_dialect
    # Responses
    respond_to do |wants|
      wants.html
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
  
  def list
    validations = Validation.where(:url.ne => nil).sort_by{ |v| v.created_at }.reverse!
    validations.uniq!{ |v| v.url }
    @validations = Kaminari.paginate_array(validations).page(params[:page])
  end
  
  private
    
    def manage_urls
      remove_blanks!
      unless params[:files].presence
        redirect_to root_path and return unless urls_valid?
      end
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
    
    def check_zipfile
      if params[:urls].presence && params[:urls].count > 0
        type = :urls
      else
        type = :files
      end
      files = []
      params[type].each do |source|
        if zipfile?(source) 
          open_zipfile(source, params[type], type)
        else
          files << source 
        end
      end
      params[type] = files
    end

    def zipfile?(source)
      if source.respond_to?(:tempfile)
        return source.content_type == "application/zip"
      else
        return File.extname(source) == ".zip"
      end
    end

    def open_zipfile(source, files, type)
      if type == :urls
        file = Tempfile.new(source.split("/").last)
        file.binmode
        file.write open(source).read
        file.rewind
      else
        file = source.path
      end
      Zip::File.open(file) do |zipfile|
        zipfile.each do |entry|
          next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
          files << read_zipped_file(entry)
        end
      end
    end

    def read_zipped_file(entry)
      filename = entry.name
      basename = File.basename(filename)
      tempfile = Tempfile.new(basename)
      tempfile.write(entry.get_input_stream.read)
      tempfile.rewind
      ActionDispatch::Http::UploadedFile.new(:filename => filename, :tempfile => tempfile)
    end
  
end
