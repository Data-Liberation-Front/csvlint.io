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
    if params[:schema] == "1"
      schema = params[:schema_url].presence || params[:schema_file].presence 
      schema = load_schema(schema)
      schema_url = params[:schema_url]
    end

    io = params[:url].presence || params[:file].presence
    
    if validate_url(params[:url]) === false || io.nil?
      redirect_to root_path and return 
    else    
      validation = Validation.create_validation(io, schema_url, schema)
      redirect_to validation_path(validation)
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
    
    def build_dialect(params)
      case params[:line_terminator]
      when "auto"
        line_terminator = line_terminator.to_sym
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
  
end
