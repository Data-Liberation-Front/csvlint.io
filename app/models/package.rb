class Package
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :url, type: String
  field :dataset, type: String
  field :type, type: String
  
  has_many :validations
  
  def self.parse_package(dataset)
    attributes = {
      :url => dataset.access_url,
      :dataset => Marshal.dump(dataset),
      :validations => [],
      :type => "datapackage"
    }
    
    return attributes
  end
  
  def self.create_package(sources, schema_url = nil, schema = nil)
    return nil if sources.count == 0
        
    if sources.count == 1 && sources.first.class == String
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
  
  def self.check_datapackage(url)
    dataset = DataKitten::Dataset.new(access_url: url)
    return nil unless dataset.publishing_format == :datapackage
    
    package = create( parse_package(dataset) )
    
    dataset.distributions.each do |distribution|
      if distribution.format.extension == :csv
        schema_desc = distribution.schema
        schema = Csvlint::Schema.from_json_table(nil, schema_desc) unless schema_desc.nil?
        if distribution.access_url
          package.validations << Validation.create_validation(distribution.access_url, nil, schema)
        end
      end
    end
    package.save
    package
  end
  
  def self.set_type(sources)
    return "files" if sources.first.respond_to?(:tempfile)
    return "urls" if sources.first.class == String
  end
  
end