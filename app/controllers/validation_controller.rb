require 'uri'

class ValidationController < ApplicationController
  slimmer_template :csvlint

  def index
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
    v = Validation.find(params[:id])
    @validator = Marshal.load(v.result)
    @warnings = @validator.warnings
    @errors = @validator.errors
    @url = v.url
    @schema_url = v.schema_url
    @state = v.state
    # Responses
    respond_to do |wants|
      wants.html
      wants.png { send_file File.join(Rails.root, 'app', 'views', 'validation', "#{@state}.png"), disposition: 'inline' }
      wants.svg { send_file File.join(Rails.root, 'app', 'views', 'validation', "#{@state}.svg"), disposition: 'inline' }
    end
  end
  
  def find_by_url
    validator = Validation.where(:url => params[:url]).first
    unless validator.nil?
      redirect_to validation_path(validator, format: params[:format])
    else
      raise ActionController::RoutingError.new('Not Found')
    end
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
