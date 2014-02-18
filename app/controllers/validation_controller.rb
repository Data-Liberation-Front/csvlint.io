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
    schema = params[:schema_url].presence || params[:schema_file].presence 
    schema = load_schema(schema) if schema

    io = params[:url].presence || params[:file].presence
    
    if validate_url(params[:url]) === false || io.nil?
      redirect_to root_path and return 
    else    
      validation = Validation.create_validation(io, params[:schema_url], schema)
      redirect_to validation_path(validation)
    end
  end

  def show
    v = Validation.fetch_validation(params[:id])
    @validator = Marshal.load(v.result)
    @info_messages = @validator.info_messages
    @warnings = @validator.warnings
    @errors = @validator.errors
    @dialect = @validator.dialect
    @url = v.url
    @schema_url = v.schema.url if v.schema
    @state = v.state
    # Responses
    respond_to do |wants|
      wants.html
      wants.png { send_file File.join(Rails.root, 'app', 'views', 'validation', "#{@state}.png"), disposition: 'inline' }
      wants.svg { send_file File.join(Rails.root, 'app', 'views', 'validation', "#{@state}.svg"), disposition: 'inline' }
    end
  end
  
  def update
    line_terminator = params[:line_terminator]
    if line_terminator == "auto"
      line_terminator = line_terminator.to_sym
    end
    if line_terminator == "\\n"
      line_terminator = "\n"
    end
    if line_terminator == "\\r\\n"
      line_terminator = "\r\n"
    end
    dialect = {
      "header" => params[:header],
      "delimiter" => params[:delimiter],
      "skipInitialSpace" => params[:skip_initial_space],
      "lineTerminator" => line_terminator,
      "quoteChar" => params[:quote_char]
    }
    
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
    
    def validate_url(url)
      unless url.blank?
        # Check it's valid
        url = begin
          URI.parse(url)
        rescue URI::InvalidURIError
          return false
        end
        # Check scheme
        return false unless ['http', 'https'].include?(url.scheme)
      end
    end
    
    def load_schema(io)
      if io.class == String
        schema = Csvlint::Schema.load_from_json_table(io) 
      else
        begin
          schema_json = JSON.parse( File.new( params[:schema_file].tempfile ).read() )
          schema = Csvlint::Schema.from_json_table( nil, schema_json )
        rescue
          schema = nil
        end
      end
      schema
    end
  
end
