class Validation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :filename, type: String
  field :url, type: String
  field :state, type: String
  field :result, type: String
  field :csv_id, type: String
  field :parse_options, type: Hash
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
      # uncertain what state triggers the above
      # byebug
      filename = io.original_filename
      csv = File.new(io.tempfile)
      io = File.new(io.tempfile)
    elsif io.class == Hash && !io[:body].nil?
      # above not triggered by features, triggered when local file [schema or csv] uploaded
      filename = io[:filename]
      csv_id = io[:csv_id]
      io = StringIO.new(io[:body])

    end

    # Validate
    validator = Csvlint::Validator.new( io, (dialect || {}), schema && schema.fields.empty? ? nil : schema )
    # ternary evaluation above follows the following format::  condition ? if_true : if_false
    check_schema(validator, schema) unless schema.nil?
    # in prior versions this method only executed on schema_url.nil, a condition that caused some schema uploads to pass
    # when they should have failed
    check_dialect(validator, dialect) unless dialect.blank?
    # assign state, used in later evaluation by partials in validation > views
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
      validator.remove_instance_variable(:@source_url) if validator.instance_variable_defined?(:@source_url)
    end

    # Don't save the data
    validator.remove_instance_variable(:@data) rescue nil
    # Don't save the lambda either
    validator.remove_instance_variable(:@lambda) rescue nil

    # Headers are set as a Typhoeus::Response::Header, but this has a proc, so we cast as a hash
    # TODO: We really need to stop dumping the whole object here
    validator.instance_variable_set("@headers", {}.merge(validator.headers))

    attributes = {
      :url => url,
      :filename => filename,
      :state => state,
      :result => Marshal.dump(validator).force_encoding("UTF-8"),
      :parse_options => Validation.generate_options(validator.dialect)
    }

    attributes[:expirable_created_at] = Time.now if expiry.eql?(true)
    # enable the expirable index, initialise it with current time

    attributes[:csv_id] = csv_id if csv_id.present?
    # do not override csv_id if already part of validation

    if schema_url.present?
      # Find matching schema if possible and retrieve
      schema = Schema.where(url: schema_url).first
      attributes[:schema] = schema || { :url => schema_url }
    end
    # byebug
    attributes

  end  # end of validate method


  def self.fetch_validation(id, format, revalidate = nil)
    # returns a mongo database record
    v = self.find(id)

    unless revalidate.to_s == "false"
      if ["png", "svg"].include?(format)
        # suspect the above functions tied to the use of badges as hyperlinks to valid schemas & csvs
        v.delay.check_validation
      else
        v.check_validation
      end
    end
    v
  end

  def self.check_schema(validator, schema)

    # @param validator = CSVlint Validator Object
    # @param schema = schema file obtained at initialisation of the Validation object

    if schema.nil?
      validator.errors.prepend(
        Csvlint::ErrorMessage.new(:invalid_schema, :schema, nil, nil, nil, nil)
      )
    elsif schema.description.eql?("malformed")
      # this conditional is tied to a cludge evaluation in lines 93 - 97 of PackageController
      # and are earmarked for future change
      validator.errors.prepend(
          Csvlint::ErrorMessage.new(:malformed_schema, :schema, nil, nil, nil, nil)
      # "JSON schema provided has some structural errors"
      )
     elsif schema.fields.empty?
      # catch a rare case of an empty json upload, i.e. {} within a .JSON file
       validator.errors.prepend(
           Csvlint::ErrorMessage.new(:empty_schema, :schema, nil, nil, nil, nil)
       )
    end

  end

  def self.check_dialect(validator, dialect)
    # byebug
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
    # update_attributes is a method from Mongoid
  end

  def update_validation(dialect = nil, expiry=nil)
    loaded_schema = schema ? Csvlint::Schema.load_from_json(schema.url) : nil
    validation = Validation.validate(self.url || self.csv, schema.try(:url), loaded_schema, dialect, expiry)
    self.update_attributes(validation)
    # update mongoDB record
    self
  end

  def csv
    # method that retrieves stored entire CSV file from mongoDB
    if self.url
      csv = open(self.url).read
    elsif self.csv_id
      # above line means this method triggers only when user opts to revalidate their CSV with suggested prompts
      csv = Mongoid::GridFs.get(self.csv_id).data
    end

    if csv
      file = Tempfile.new('csv')
      File.open(file, "w") do |f|
        f.write csv.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
      end
      file
    end
  end

  def parse_options
    if self.read_attribute(:parse_options).nil?
      self.parse_options = Validation.generate_options(self.validator.dialect)
      save
    end
    self.read_attribute(:parse_options)
  end

  def check_validation
    # this method should only be called against URL listed validations i.e. 'added to list of recent validations'
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

  # Empty method? Intended functionality?
  def badge

  end

  def self.clean_up(hours)
    Mongoid::GridFs::File.where(:uploadDate.lt => hours.hours.ago).each {|x| Mongoid::GridFs.delete(x.id) }
    Validation.where(:created_at.lt => hours.hours.ago, :csv_id.ne => nil).each do |validation|
      Mongoid::GridFs.delete(validation.csv_id)
      validation.csv_id = nil
      validation.save
    end
  rescue => e
    Airbrake.notify(e) if ENV['CSVLINT_AIRBRAKE_KEY'] # Exit cleanly, but still notify airbrake
  ensure
    Validation.delay(run_at: 24.hours.from_now).clean_up(24)
  end

  def self.generate_options(dialect)
    dialect ||= {}
    {
      col_sep: dialect["delimiter"],
      row_sep: dialect["lineTerminator"],
      quote_char: dialect["quoteChar"],
    }
  end

end
