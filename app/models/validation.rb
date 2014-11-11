class Validation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :filename, type: String
  field :url, type: String
  field :state, type: String
  field :result, type: String
  field :csv_id, type: String

  index :created_at => 1

  belongs_to :schema
  accepts_nested_attributes_for :schema

  belongs_to :package

  def self.validate(io, schema_url = nil, schema = nil, dialect = nil)
    if io.respond_to?(:tempfile)
      filename = io.original_filename
      csv = File.new(io.tempfile)
      io = File.new(io.tempfile)
    elsif io.class == Hash && !io[:body].nil?
      filename = io[:filename]
      csv_id = io[:csv_id]
      io = StringIO.new(io[:body])
    end
    # Validate
    validator = Csvlint::Validator.new( io, dialect, schema && schema.fields.empty? ? nil : schema )
    check_schema(validator, schema) unless schema_url.blank?
    check_dialect(validator, dialect) unless dialect.blank?
    state = "valid"
    state = "warnings" unless validator.warnings.empty?
    state = "invalid" unless validator.errors.empty?
    state = "not_found" unless validator.errors.select { |e| e.type == :not_found }.empty?

    if io.class == String
      # It's a url!
      url = io
      filename = File.basename(URI.parse(url).path)
      csv_id = nil
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
      :csv_id => csv_id
    }

    if schema_url.present?
      # Find matching schema if possible
      schema = Schema.where(url: schema_url).first
      attributes[:schema] = schema || { :url => schema_url }
    end

    attributes
  end

  def self.fetch_validation(id, format, revalidate = nil)
    v = self.find(id)
    unless revalidate === false
      if ["png", "svg"].include?(format)
        v.delay.check_validation
      else
        v.check_validation
      end
    end
    v
  end

  def self.check_schema(validator, schema)
    if schema.nil? || schema.fields.empty?
      validator.errors.prepend(
        Csvlint::ErrorMessage.new(:invalid_schema, :schema, nil, nil, nil, nil)
      )
    end
  end

  def self.check_dialect(validator, dialect)
    if dialect != standard_dialect
      validator.warnings.prepend(
        Csvlint::ErrorMessage.new(:non_standard_dialect, :dialect, nil, nil, nil, nil)
      )
    end
  end

  def self.standard_dialect
    {
      "header" => true,
      "delimiter" => ",",
      "skipInitialSpace" => true,
      "lineTerminator" => :auto,
      "quoteChar" => '"'
    }
  end

  def self.create_validation(io, schema_url = nil, schema = nil)
    if io.class == String
      validation = Validation.find_or_initialize_by(url: io)
    else
      validation = Validation.create
    end
    validation.validate(io, schema_url, schema)
    validation
  end

  def validate(io, schema_url = nil, schema = nil)
    validation = Validation.validate(io, schema_url, schema)
    self.update_attributes(validation)
  end

  def update_validation(dialect = nil)
    loaded_schema = schema ? Csvlint::Schema.load_from_json_table(schema.url) : nil
    validation = Validation.validate(self.url || self.csv, schema.try(:url), loaded_schema, dialect)
    self.update_attributes(validation)
    self
  end

  def csv
    unless self.csv_id.nil?
      stored_csv = Mongoid::GridFs.get(self.csv_id)
      file = Tempfile.new('csv')
      File.open(file, "w") do |f|
        f.write stored_csv.data
      end
      file
    end
  end

  def check_validation
    unless url.blank?
      begin
        RestClient.head(url, if_modified_since: updated_at.rfc2822 ) if updated_at
        update_validation(validator.dialect) if updated_at <= 2.hours.ago
      rescue RestClient::NotModified
        nil
      rescue
        update_attributes(state: "not_found")
      end
    end
  end

  def validator
    Marshal.load(self.result)
  end

  def badge

  end

end
