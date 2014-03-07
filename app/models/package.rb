require 'zip'

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

  def self.parse_package(dataset, validations)
    attributes = {
      :url => dataset.origin == :local ? nil : dataset.access_url,
      :dataset => Marshal.dump(dataset),
      :validations => validations,
      :type => dataset.publishing_format
    }

    return attributes
  end

  def self.create_package(sources, schema_url = nil, schema = nil)
    return nil if sources.count == 0
    
    sources = check_zipfile(sources)
        
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
    
    validations = create_validations(dataset)
    
    return nil if validations.count == 0
    
    package = create( parse_package(dataset, validations) )

    package.save
    package
  end
  
  def self.create_validations(dataset)
    validations = []
    dataset.distributions.each do |distribution|
      if can_validate?(distribution)
        validations << Validation.create_validation(distribution.access_url, nil, create_schema(distribution) )
      end
    end
    validations
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
    return "files" if sources.first.respond_to?(:tempfile) || sources.first.class == Tempfile
    return "urls" if sources.first.class == String
  end
  
  def self.check_zipfile(sources)
    files = []
    sources.each do |source| 
      if zipfile?(source)    
        open_zipfile(source, files)
      else
        files << source 
      end
    end
    files
  end
  
  def self.zipfile?(source)
    return source.content_type == "application/zip"
  end
  
  def self.open_zipfile(source, files)
    Zip::File.open(source.path) do |zipfile|
      zipfile.each do |entry|
        next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
        files << read_zipped_file(entry)
      end
    end
  end
  
  def self.read_zipped_file(entry)
    filename = entry.name
    basename = File.basename(filename)
    tempfile = Tempfile.new(basename)
    tempfile.write(entry.get_input_stream.read)
    tempfile.rewind
    ActionDispatch::Http::UploadedFile.new(:filename => filename, :tempfile => tempfile)
  end

end
