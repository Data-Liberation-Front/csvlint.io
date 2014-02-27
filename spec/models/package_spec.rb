require "spec_helper"

describe Package do
  
  it "creates a validation for a datapackage with a single CSV" do
    url = 'http://example.org/single-datapackage.json'
    mock_datapackage(url, 'datapackages/single-datapackage.json')
    mock_csv("http://example.org/valid.csv", 'csvs/valid.csv')
    
    package = Package.create_package(url)
    dataset = DataKitten::Dataset.new(access_url: url)
    
    package.url.should == url
    package.dataset.should == Marshal.dump(dataset)
    package.validations.count.should == 1
  end
  
  it "creates multiple validations for a datapackage with multiple CSVs" do
    url = 'http://example.org/multiple-datapackage.json'
    mock_datapackage(url, 'datapackages/multiple-datapackage.json')
    mock_csv("http://example.org/valid.csv", 'csvs/valid.csv')
    mock_csv("http://example.org/valid2.csv", 'csvs/valid.csv')
    
    package = Package.create_package(url)
    
    package.validations.count.should == 2
  end
  
  it "loads schema from a datapackage" do
    url = 'http://example.org/schema-datapackage.json'
    mock_datapackage(url, 'datapackages/datapackage-with-schema.json')
    mock_csv("http://example.org/all_constraints.csv", 'csvs/all_constraints.csv')
        
    package = Package.create_package(url)
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
      mock_datapackage(url, 'datapackages/multiple-datapackage.json')
      mock_csv("http://example.org/some-json.json", 'csvs/valid.csv')
      mock_csv("http://example.org/valid.csv", 'csvs/valid.csv')

      package = Package.create_package(url)
      package.should == nil
    end
    
    it "ignores non-CSV resources" do
      url = 'http://example.org/mixed-datapackage.json'
      mock_datapackage(url, 'datapackages/mixed-datapackage.json')
      mock_csv("http://example.org/some-json.json", 'csvs/valid.csv')
      mock_csv("http://example.org/valid.csv", 'csvs/valid.csv')

      package = Package.create_package(url)
      package.validations.count.should == 1
    end
    
  end
  
end