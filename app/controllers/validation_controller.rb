require 'uri'

class ValidationController < ApplicationController
  slimmer_template :csvlint

  def index
  end

  def create
    if !params["url"].blank? 
      # Check we have a URL
      @url = params[:url]
      redirect_to root_path and return if @url.nil? && @file.nil?
      # Check it's valid
      @url = begin
        URI.parse(@url)
      rescue URI::InvalidURIError
        redirect_to root_path and return
      end
      # Check scheme
      redirect_to root_path and return unless ['http', 'https'].include?(@url.scheme)
      @schema_url = params[:schema_url]
      schema = Csvlint::Schema.load_from_json_table(@schema_url) 
      validation = validate_csv(@url.to_s, schema)
      redirect_to validation_path(validation)
    elsif !params["file"].blank? 
      @schema = nil
      if params[:schema_file]
        begin
          schema_json = JSON.parse( File.new( params[:schema_file].tempfile ).read() )
          @schema = Csvlint::Schema.from_json_table( nil, schema_json )
        rescue
          @schema = nil
        end
      end
      validation = validate_csv(File.new(params[:file].tempfile), @schema, params[:file].original_filename)
      @file = File.new(params[:file].tempfile)
      redirect_to validation_path(validation)
    else
      redirect_to root_path and return 
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
    @validations = Kaminari.paginate_array(Validation.where(:url.ne => nil).uniq{ |v| v.url }).page(params[:page])
  end
  
  private
  
    def validate_csv(io, schema = nil, filename = nil)
      # Load schema if set
      unless params[:schema_url].blank?
        if schema.nil? || schema.fields.empty?
          schema_error = Csvlint::ErrorMessage.new(
            type: :invalid_schema,
            category: :schema
          )
        end
      end
      # Validate
      validator = Csvlint::Validator.new( io, nil, schema )
      validator.errors.prepend(schema_error) if schema_error
      state = "valid"
      state = "warnings" unless validator.warnings.empty?
      state = "invalid" unless validator.errors.empty?
      
      if io.class == String
        # It's a url!
        url = io
        filename = File.basename(URI.parse(url).path)
      else
        # It's a file!
        url = nil
        validator.remove_instance_variable(:@source)
      end
            
      Validation.create(
        :url => url,
        :schema_url => @schema_url,
        :filename => filename,
        :state => state,
        :result => Marshal.dump(validator).force_encoding("UTF-8")
      )
    end

end
