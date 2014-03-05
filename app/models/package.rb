class LocalDataset < DataKitten::Dataset
  extend DataKitten::PublishingFormats::Datapackage

  def origin
    :local
  end
  
  def publishing_format
    :datapackage
  end
end

class Package
  include Mongoid::Document
  include Mongoid::Timestamps

  field :url, type: String
  field :dataset, type: String
  field :type, type: String

  has_many :validations

  def self.parse_package(dataset)
    attributes = {
      :url => dataset.origin == :local ? nil : dataset.access_url,
      :dataset => Marshal.dump(dataset),
      :validations => [],
      :type => dataset.publishing_format
    }

    return attributes
  end

  def self.create_package(sources, schema_url = nil, schema = nil)
    return nil if sources.count == 0
        
    if sources.count == 1 && possible_package?(sources.first)
      check_datapackage(sources.first)
    elsif sources.count > 1
      package = create({ type: set_type(sources) })

      sources.each do |source|
        package.validations << Validation.create_validation(source, schema_url, schema)
      end

      package.save
      package
    end
  end
  
  def self.possible_package?(source)
    source.class == String || local_package?( source )
  end
  
  def self.local_package?(source)
    source.respond_to?(:tempfile) && source.original_filename =~ /datapackage\.json/
  end  
  
  def self.create_dataset(source)
    if source.respond_to?(:tempfile)
      dataset = LocalDataset.new(access_url: source.tempfile.path)
    else
      dataset = DataKitten::Dataset.new(access_url: source)
    end
    dataset
  end
  
  def self.check_datapackage(source)
    dataset = create_dataset(source)
    return nil unless [:ckan, :datapackage].include? dataset.publishing_format
    
    package = create( parse_package(dataset) )
    add_validations(package, dataset)

    package.save
    package
  end
  
  def self.add_validations(package, dataset)
    dataset.distributions.each do |distribution|
      if can_validate?(distribution)
        package.validations << Validation.create_validation(distribution.access_url, nil, create_schema(distribution) )
      end
    end
  end
  
  def self.can_validate?(distribution)
    return false unless distribution.format.extension == :csv
    return distribution.access_url && distribution.access_url =~ /^http(s?)/
  end
  
  def self.create_schema(distribution)
    unless distribution.schema.nil?
      schema = Csvlint::Schema.from_json_table(nil, distribution.schema) 
    end
    return schema
  end

  def self.set_type(sources)
    return "files" if sources.first.respond_to?(:tempfile)
    return "urls" if sources.first.class == String
  end

end
