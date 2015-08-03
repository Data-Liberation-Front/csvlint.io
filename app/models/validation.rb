class Validation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :filename, type: String
  field :url, type: String
  field :state, type: String
  field :result, type: String
  field :csv_id, type: String
  field :expirable_created_at, type: Time

  index :created_at => 1
  index({expirable_created_at: 1}, {expire_after_seconds: 24.hours})
  # invoke the mongo time-to-live feature which will automatically expire entries
  # - this index is only enabled for a subset of validations, which are validations uploaded as file

  belongs_to :schema
  accepts_nested_attributes_for :schema

  belongs_to :package

  def self.validate(io, schema_url = nil, schema = nil, dialect = nil, expiry)
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
      :result => Marshal.dump(validator).force_encoding("UTF-8")
    }

    attributes[:expirable_created_at] = Time.now if expiry.eql?(true)
    # enable the expirable index, initialise it with current time

    attributes[:csv_id] = csv_id if csv_id.present?
    # do not override csv_id if already part of validation

    if schema_url.present?
      # Find matching schema if possible
      schema = Schema.where(url: schema_url).first
      attributes[:schema] = schema || { :url => schema_url }
    end
    # byebug
    attributes
  end

  def self.fetch_validation(id, format, revalidate = nil)
    # returns a mongo database record
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
    # this method instantate the Object then calls its validate method. Below conditional discriminates between URL CSV
    # and uploaded CSV. Uploaded CSVs = do not retain
    # this method invokes the validate method below rather than self.validate
    # returns validation object
    if io.class == String
      validation = Validation.find_or_initialize_by(url: io)
      expiry = false
    else
      validation = Validation.create
      expiry = true
    end
    validation.validate(io, schema_url, schema, expiry)
    # expiry is set to true or false based on inferring that uploaded file meets the do not retain criteria
    validation
  end

  def validate(io, schema_url = nil, schema = nil, expiry)
    validation = Validation.validate(io, schema_url, schema, nil, expiry)
    self.update_attributes(validation)
  end

  def update_validation(dialect = nil, expiry=nil)
    loaded_schema = schema ? Csvlint::Schema.load_from_json_table(schema.url) : nil
    validation = Validation.validate(self.url || self.csv, schema.try(:url), loaded_schema, dialect, expiry)
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

  def self.clean_up(hours)
    begin
      Validation.where(:created_at.lt => hours.hours.ago, :csv_id.ne => nil).each do |validation|
        Mongoid::GridFs.delete(validation.csv_id)
        validation.csv_id = nil
        validation.save
      end
    ensure
      Validation.delay(run_at: 24.hours.from_now).clean_up(24)
    end
  end

end
