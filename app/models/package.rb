class Package
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :url, type: String
  field :dataset, type: String
  
  has_many :validations
  
  def self.parse_package(dataset)
    attributes = {
      :url => dataset.access_url,
      :dataset => Marshal.dump(dataset),
      :validations => []
    }
    
    return attributes
  end
  
  def self.create_package(urls, schema_url = nil, schema = nil)
    return nil if urls.count == 0
    
    if urls.count == 1
      check_datapackage(urls.first)
    else
      package = create
      
      urls.each do |url|
        package.validations << Validation.create_validation(url, schema_url, schema)
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
  
end