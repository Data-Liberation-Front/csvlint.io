class Validation
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :filename, type: String
  field :url, type: String
  field :state, type: String
  field :result, type: String
  field :csv_id, type: String
  
  belongs_to :schema
  accepts_nested_attributes_for :schema
  
  def self.validate(io, schema_url = nil, schema = nil, dialect = nil)
    if io.respond_to?(:tempfile)
      filename = io.original_filename
      csv = File.new(io.tempfile)
      io = File.new(io.tempfile)
    end 
    # Validate
    validator = Csvlint::Validator.new( io, dialect, schema && schema.fields.empty? ? nil : schema )
    check_schema(validator, schema) unless schema_url.blank?
    state = "valid"
    state = "warnings" unless validator.warnings.empty?
    state = "invalid" unless validator.errors.empty?
    
    if io.class == String
      # It's a url!
      url = io
      filename = File.basename(URI.parse(url).path)
      csv = nil
    else
      # It's a file!
      url = nil
      validator.remove_instance_variable(:@source)
    end
    
    attributes = {
      :url => url,
      :filename => filename,
      :state => state,
      :result => Marshal.dump(validator).force_encoding("UTF-8"),
      :csv => csv
    }
        
    if schema_url.present?
      # Find matching schema if possible
      schema = Schema.where(url: schema_url).first
      attributes[:schema] = schema || { :url => schema_url }
    end
    
    attributes
  end 
  
  def self.create_validation(io, schema_url = nil, schema = nil)
    validation = validate(io, schema_url, schema)
    self.create(validation)
  end
  
  def self.fetch_validation(id)
    v = self.find(id)
    unless v.url.blank?
      begin
        RestClient.head(v.url, if_modified_since: v.updated_at.rfc2822 ) if v.updated_at
        validator = Marshal.load(v.result)
        v = v.update_validation (validator.dialect)
      rescue RestClient::NotModified
        nil
      end
    end
    v
  end
  
  def self.check_schema(validator, schema)
    if schema.nil? || schema.fields.empty?
      validator.errors.prepend(
        Csvlint::ErrorMessage.new(
          type: :invalid_schema,
          category: :schema
        )
      )
    end
  end
  def update_validation(dialect = nil)
    loaded_schema = schema ? Csvlint::Schema.load_from_json_table(schema.url) : nil
    validation = Validation.validate(self.url || self.csv, schema.try(:url), loaded_schema, dialect)    
    self.update_attributes(validation)
    self
  end
  
  def csv=(io)
    unless io.nil?
      stored_csv = Mongoid::GridFs.put(io)
      self.csv_id = stored_csv.id
    end
  end
  
  def csv
    unless self.csv_id.nil?
      stored_csv = Mongoid::GridFs.get(self.csv_id)
      Tempfile.new(stored_csv.data)
    end
  end

end
  