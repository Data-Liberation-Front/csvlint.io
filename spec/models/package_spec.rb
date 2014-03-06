require "spec_helper"

describe Package do
  
  include ActionDispatch::TestProcess
  
  before :each do       
   stub_request(:get, "http://example.org/api/3/action/package_show?id=non-csv-data-package.json").
     with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
     to_return(:status => 200, :body => "", :headers => {})
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
      package = Package.create_package(@urls)
      package.validations.count.should == 4
    end
    
    it "sets the right type" do
      package = Package.create_package(@urls)
      package.type.should == "urls"
    end
    
    it "creates multiple validations with a schema" do
      schema_url = "http://example.org/schema.json"
      mock_file(schema_url, 'schemas/valid.json', 'application/javascript')
      
      schema = Csvlint::Schema.load_from_json_table(schema_url) 
      package = Package.create_package(@urls, schema_url, schema)
      
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
      package = Package.create_package(@files)
      package.validations.count.should == 4
    end
    
    it "sets the right type" do
      package = Package.create_package(@files)
      package.type.should == "files"
    end
    
    it "creates multiple validations with a schema" do
      schema_url = "http://example.org/schema.json"
      mock_file(schema_url, 'schemas/valid.json', 'application/javascript')
      
      schema = Csvlint::Schema.load_from_json_table(schema_url) 
      package = Package.create_package(@files, schema_url, schema)
      
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
    
      package = Package.check_datapackage(url)
      dataset = DataKitten::Dataset.new(access_url: url)
          
      package.url.should == url
      package.dataset.should == Marshal.dump(dataset)
      package.validations.count.should == 1
    end
  
    it "creates multiple validations for a datapackage with multiple CSVs" do
      url = 'http://example.org/multiple-datapackage.json'
      mock_file(url, 'datapackages/multiple-datapackage.json', 'application/javascript')
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
      mock_file("http://example.org/valid2.csv", 'csvs/valid.csv')
    
      package = Package.check_datapackage(url)
    
      package.validations.count.should == 2
    end
  
    it "loads schema from a datapackage" do
      url = 'http://example.org/schema-datapackage.json'
      mock_file(url, 'datapackages/datapackage-with-schema.json', 'application/javascript')
      mock_file("http://example.org/all_constraints.csv", 'csvs/all_constraints.csv')
        
      package = Package.check_datapackage(url)
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
        url = 'http://example.org/non-csv-data-package.json'
        mock_file(url, 'datapackages/multiple-datapackage.json', 'application/javascript')
        mock_file("http://example.org/some-json.json", 'csvs/valid.csv')
        mock_file("http://example.org/valid.csv", 'csvs/valid.csv')

        package = Package.check_datapackage(url)
        package.should == nil
      end
    
      it "ignores non-CSV resources" do    
        url = 'http://example.org/mixed-datapackage.json'
        mock_file(url, 'datapackages/mixed-datapackage.json', 'application/javascript')
        mock_file("http://example.org/some-json.json", 'csvs/valid.csv')
        mock_file("http://example.org/valid.csv", 'csvs/valid.csv')

        package = Package.check_datapackage(url)
        package.validations.count.should == 1
      end
    
    end
  end
  
  context "with a local datapackage" do
    it "creates a validation for a datapackage with a single CSV" do
      files = [ mock_upload('datapackages/single-datapackage.json') ]
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
      
      package = Package.create_package(files)
      package.validations.count.should == 1

    end
    
    it "ignores local CSV files" do
      files = [ mock_upload('datapackages/local-and-remote-datapackage.json') ]
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
      
      package = Package.create_package(files)
      package.validations.count.should == 1

    end

  end  
  
  context "with a CKAN URL" do
    it "creates a validation for a CKAN package with a single CSV", :vcr do
      url = 'http://data.gov.uk/dataset/uk-open-access-non-vosa-sites'
    
      package = Package.check_datapackage(url)
      dataset = DataKitten::Dataset.new(access_url: url)
    
      package.url.should == url
      package.dataset.should == Marshal.dump(dataset)
      package.validations.count.should == 1
    end
  
    it "creates multiple validations for a datapackage with multiple CSVs", :vcr do
      url = 'http://data.gov.uk/dataset/uk-civil-service-high-earners'
    
      package = Package.check_datapackage(url)
    
      package.validations.count.should == 4
    end
    
    it "returns nil if there are no CSVs", :vcr do
      url = 'http://data.gov.uk/dataset/ratio-of-median-house-price-to-median-earnings'

      package = Package.check_datapackage(url)
      package.should == nil
    end
    
  end
  
  
end