require 'uri'

class ValidationController < ApplicationController
  slimmer_template :csvlint

  def index
  end

  def redirect
    if !params["url"].blank? 
      redirect_to validate_path(url: params["url"], schema_url: params[:schema_url])
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
      validate_csv(File.new(params[:file].tempfile), @schema)
      @file = File.new(params[:file].tempfile)
      respond_to do |wants|
        wants.html { render "validation/validate"  }
        wants.png { send_file File.join(Rails.root, 'app', 'views', 'validation', "#{@state}.png"), disposition: 'inline' }
        wants.svg { send_file File.join(Rails.root, 'app', 'views', 'validation', "#{@state}.svg"), disposition: 'inline' }
      end
    else
      redirect_to root_path and return 
    end
  end

  def validate
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
    validate_csv(@url.to_s, schema)
    # Responses
    respond_to do |wants|
      wants.html
      wants.png { send_file File.join(Rails.root, 'app', 'views', 'validation', "#{@state}.png"), disposition: 'inline' }
      wants.svg { send_file File.join(Rails.root, 'app', 'views', 'validation', "#{@state}.svg"), disposition: 'inline' }
    end

  end
  
  private
  
    def validate_csv(io, schema = nil)
      # Load schema if set
      unless params[:schema_url].blank?
        if schema.nil? || schema.fields.empty?
          @schema_error = Csvlint::ErrorMessage.new(
            type: :invalid_schema,
            category: :schema
          )
        end
      end
      # Validate
      @validator = Csvlint::Validator.new( io, nil, schema )
      @warnings = @validator.warnings
      @errors = @validator.errors
      @errors.prepend(@schema_error) if @schema_error
      @state = "valid"
      @state = "warnings" unless @warnings.empty?
      @state = "invalid" unless @errors.empty?
    end

end
