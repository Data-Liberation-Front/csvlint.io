require 'uri'

class ValidationController < ApplicationController

  def index
    if params[:uri]
      validator = Validation.where(:url => params[:uri]).first
      render status: 404 and return if validator.nil?
      redirect_to validation_path(validator, format: params[:format]), status: 303
    end
  end

  def create
    if validate_urls(params[:urls]) === false
      redirect_to root_path and return
    end    
        
    load_schema
    package = check_for_package
    
    io = params[:urls].first.presence || params[:file].presence
    if package
      redirect_to package_path(package)
    else
      if io.nil?
        redirect_to root_path and return 
      else    
        validation = Validation.create_validation(io, @schema_url, @schema)
        redirect_to validation_path(validation)
      end
    end
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
    
    def validate_urls(urls)    
      return true if params[:file].presence
      return false if urls.blank?
      urls.reject! { |url| url.blank? }
      
      urls.each do |url|
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
      unless params[:file].presence
        Package.create_package( params[:urls], params[:schema_url], @schema )
      end
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
  
end
