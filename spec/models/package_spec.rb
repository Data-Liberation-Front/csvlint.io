require "spec_helper"

describe Package, type: :model do
  
  include ActionDispatch::TestProcess
  
  before :each do       
   stub_request(:get, "http://example.org/api/3/action/package_show?id=non-csv-data-package.json").
     with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
     to_return(:status => 200, :body => "", :headers => {})
  end
  
  it "creates a single validation" do
    mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
    package = Package.new
    package = package.create_package(['http://example.org/valid.csv'])
    package.validations.length.should == 1
  end
  
  context "with multiple URLs" do
    before :each do
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
      mock_file("http://example.org/valid2.csv", 'csvs/valid.csv')
      mock_file("http://example.org/valid3.csv", 'csvs/valid.csv')
      mock_file("http://example.org/valid4.csv", 'csvs/valid.csv')
      
      @urls = [
          'http://example.org/valid.csv',
          'http://example.org/valid2.csv',
          'http://example.org/valid3.csv',
          'http://example.org/valid4.csv'
        ]
    end
    
    it "creates multiple validations" do
      package = Package.new
      package = package.create_package(@urls)
      package.validations.length.should == 4
    end
    
    it "sets the right type" do
      package = Package.new
      package = package.create_package(@urls)
      package.type.should == "urls"
    end
    
    it "creates multiple validations with a schema" do
      schema_url = "http://example.org/schema.json"
      mock_file(schema_url, 'schemas/valid.json', 'application/javascript')
      
      schema = Csvlint::Schema.load_from_json_table(schema_url) 
      package = Package.new
      package = package.create_package(@urls, schema_url, schema)
      
      package.validations.each do |validation|
        result = Marshal.load validation.result
        result.schema.fields[0].name.should == "FirstName"
        result.schema.fields[1].name.should == "LastName"
        result.schema.fields[2].name.should == "Insult"
      end
    end
  end
  
  context "with multiple files" do
    before :each do
      @files = [
          mock_upload('csvs/valid.csv'),
          mock_upload('csvs/valid.csv'),
          mock_upload('csvs/valid.csv'),
          mock_upload('csvs/valid.csv')
        ]
    end
    
    it "creates multiple validations" do
      package = Package.new
      package = package.create_package(@files)
      package.validations.length.should == 4
    end
    
    it "sets the right type" do
      package = Package.new
      package = package.create_package(@files)
      package.type.should == "files"
    end
    
    it "creates multiple validations with a schema" do
      schema_url = "http://example.org/schema.json"
      mock_file(schema_url, 'schemas/valid.json', 'application/javascript')
      
      schema = Csvlint::Schema.load_from_json_table(schema_url) 
      package = Package.new
      package = package.create_package(@files, schema_url, schema)
      
      package.validations.each do |validation|
        result = Marshal.load validation.result
        result.schema.fields[0].name.should == "FirstName"
        result.schema.fields[1].name.should == "LastName"
        result.schema.fields[2].name.should == "Insult"
      end
    end
    
  end
  
  context "with a datapackage" do
    it "creates a validation for a datapackage with a single CSV" do
      url = 'http://example.org/single-datapackage.json'
      mock_file(url, 'datapackages/single-datapackage.json', 'application/javascript')
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
      
      package = Package.new
      package = package.create_package([url])
      dataset = DataKitten::Dataset.new(access_url: url)
      package_dataset = Marshal.load(package.dataset)
                
      package.url.should == url
      package.validations.length.should == 1
      
      package_dataset.access_url.should == dataset.access_url
      package_dataset.data_title.should == dataset.data_title
      package_dataset.description.should == dataset.description
      package_dataset.resources.should == dataset.resources
    end
  
    it "creates multiple validations for a datapackage with multiple CSVs" do
      url = 'http://example.org/multiple-datapackage.json'
      mock_file(url, 'datapackages/multiple-datapackage.json', 'application/javascript')
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
      mock_file("http://example.org/valid2.csv", 'csvs/valid.csv')
      
      package = Package.new
      package = package.create_package([url])
    
      package.validations.length.should == 2
    end
  
    it "loads schema from a datapackage" do
      url = 'http://example.org/schema-datapackage.json'
      mock_file(url, 'datapackages/datapackage-with-schema.json', 'application/javascript')
      mock_file("http://example.org/all_constraints.csv", 'csvs/all_constraints.csv')
        
      package = Package.new
      package = package.create_package([url])
      result = Marshal.load package.validations.first.result
    
      fields = result.schema.fields
    
      fields.count.should == 5
      fields[0].name.should == "Username"
      fields[1].name.should == "Age"
      fields[2].name.should == "Height"
      fields[3].name.should == "Weight"
      fields[4].name.should == "Password"
      fields[0].constraints["required"].should == true
    end
  
    context "with non-CSV resources" do
    
      it "returns nil if there are no CSVs" do
        url = 'http://example.org/non-csv-datapackage.json'
        mock_file(url, 'datapackages/non-csv-datapackage.json', 'application/javascript')
        mock_file("http://example.org/some-json.json", 'datapackages/non-csv-datapackage.json')
        
        package = Package.new
        package = package.create_package([url])
                      
        package.should == nil
      end
    
      it "ignores non-CSV resources" do    
        url = 'http://example.org/mixed-datapackage.json'
        mock_file(url, 'datapackages/mixed-datapackage.json', 'application/javascript')
        mock_file("http://example.org/some-json.json", 'csvs/valid.csv')
        mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
        
        package = Package.new
        package = package.create_package([url])
                
        package.validations.length.should == 1
      end
    
    end
  end
  
  context "with a local datapackage" do
    it "creates a validation for a datapackage with a single CSV" do
      files = [ mock_upload('datapackages/single-datapackage.json') ]
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
      
      package = Package.new
      package = package.create_package(files)
      package.validations.length.should == 1

    end
    
    it "ignores local CSV files" do
      files = [ mock_upload('datapackages/local-and-remote-datapackage.json') ]
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
      
      package = Package.new
      package = package.create_package(files)
      package.validations.length.should == 1

    end

  end  
  
  context "with a CKAN URL" do
    it "creates a validation for a CKAN package with a single CSV", :vcr do
      url = 'http://data.gov.uk/dataset/uk-open-access-non-vosa-sites'
      
      package = Package.new
      package = package.create_package([url])
      dataset = DataKitten::Dataset.new(access_url: url)
      package_dataset = Marshal.load(package.dataset)
    
      package.url.should == url
      package.validations.length.should == 1
      
      package_dataset.access_url.should == dataset.access_url
      package_dataset.data_title.should == dataset.data_title
      package_dataset.description.should == dataset.description
      package_dataset.resources.should == dataset.resources
    end
  
    it "creates multiple validations for a datapackage with multiple CSVs", :vcr do
      url = 'http://data.gov.uk/dataset/uk-civil-service-high-earners'
            
      package = Package.new
      package = package.create_package([url])
    
      package.validations.length.should == 4
    end
    
    it "returns nil if there are no CSVs", :vcr do
      url = 'http://data.gov.uk/dataset/ratio-of-median-house-price-to-median-earnings'
      
      package = Package.new
      package = package.create_package([url])
      package.should == nil
    end
    
  end
  
  
end