class Validation
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :filename, type: String
  field :url, type: String
  field :schema_url, type: String
  field :state, type: String
  field :result, type: String
  
  def self.validate(io, schema_url = nil, schema = nil)
    #Load schema if set
    unless schema_url.blank?
      if schema.nil? || schema.fields.empty?
        schema_error = Csvlint::ErrorMessage.new(
          type: :invalid_schema,
          category: :schema
        )
      end
    end
    if io.respond_to?(:tempfile)
      filename = io.original_filename
      io = File.new(io.tempfile)
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
    
    {
      :url => url,
      :schema_url => schema_url,
      :filename => filename,
      :state => state,
      :result => Marshal.dump(validator).force_encoding("UTF-8")
    }
  end 
  
  def self.create_validation(io, schema_url = nil, schema = nil)
    validation = validate(io, schema_url, schema)
    self.create(validation)
  end
  
  def self.fetch_validation(id)
    v = self.find(id)
    unless v.url.blank?
      begin
        open(v.url, "If-Modified-Since" => v.updated_at.rfc2822 )
        v = v.update_validation
      rescue OpenURI::HTTPError => e
        raise unless e.message.include?("304")
      end
    end
    v
  end
  
  def update_validation
    schema = Csvlint::Schema.load_from_json_table(self.schema_url) if self.schema_url
    validation = Validation.validate(self.url, self.schema_url, schema)
    self.update_attributes(validation)
    self
  end

end
  