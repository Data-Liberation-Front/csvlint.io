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
    expect(package.validations.length).to eq(1)
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
      expect(package.validations.length).to eq(4)
    end

    it "sets the right type" do
      package = Package.new
      package = package.create_package(@urls)
      expect(package.type).to eq("urls")
    end

    it "creates multiple validations with a schema" do
      schema_url = "http://example.org/schema.json"
      mock_file(schema_url, 'schemas/valid.json', 'application/javascript')

      schema = Csvlint::Schema.load_from_json(schema_url)
      package = Package.new
      package = package.create_package(@urls, schema_url, schema)

      package.validations.each do |validation|
        result = Marshal.load validation.result
        expect(result.schema.fields[0].name).to eq("FirstName")
        expect(result.schema.fields[1].name).to eq("LastName")
        expect(result.schema.fields[2].name).to eq("Insult")
      end
    end
  end

  context "with multiple files" do
    before :each do
      @files = [
          mock_uploaded_file('csvs/valid.csv'),
          mock_uploaded_file('csvs/valid.csv'),
          mock_uploaded_file('csvs/valid.csv'),
          mock_uploaded_file('csvs/valid.csv')
        ]
    end

    it "creates multiple validations" do
      package = Package.new
      package = package.create_package(@files)
      expect(package.validations.length).to eq(4)
    end

    it "sets the right type" do
      package = Package.new
      package = package.create_package(@files)
      expect(package.type).to eq("files")
    end

    it "creates multiple validations with a schema" do
      schema_url = "http://example.org/schema.json"
      mock_file(schema_url, 'schemas/valid.json', 'application/javascript')

      schema = Csvlint::Schema.load_from_json(schema_url)
      package = Package.new
      package = package.create_package(@files, schema_url, schema)

      package.validations.each do |validation|
        result = Marshal.load validation.result
        expect(result.schema.fields[0].name).to eq("FirstName")
        expect(result.schema.fields[1].name).to eq("LastName")
        expect(result.schema.fields[2].name).to eq("Insult")
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

      expect(package.url).to eq(url)
      expect(package.validations.length).to eq(1)

      expect(package_dataset.access_url).to eq(dataset.access_url)
      expect(package_dataset.data_title).to eq(dataset.data_title)
      expect(package_dataset.description).to eq(dataset.description)
      expect(package_dataset.resources).to eq(dataset.resources)
    end

    it "creates multiple validations for a datapackage with multiple CSVs" do
      url = 'http://example.org/multiple-datapackage.json'
      mock_file(url, 'datapackages/multiple-datapackage.json', 'application/javascript')
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')
      mock_file("http://example.org/valid2.csv", 'csvs/valid.csv')

      package = Package.new
      package = package.create_package([url])

      expect(package.validations.length).to eq(2)
    end

    it "loads schema from a datapackage" do
      url = 'http://example.org/schema-datapackage.json'
      mock_file(url, 'datapackages/datapackage-with-schema.json', 'application/javascript')
      mock_file("http://example.org/all_constraints.csv", 'csvs/all_constraints.csv')

      package = Package.new
      package = package.create_package([url])
      result = Marshal.load package.validations.first.result

      fields = result.schema.fields

      expect(fields.count).to eq(5)
      expect(fields[0].name).to eq("Username")
      expect(fields[1].name).to eq("Age")
      expect(fields[2].name).to eq("Height")
      expect(fields[3].name).to eq("Weight")
      expect(fields[4].name).to eq("Password")
      expect(fields[0].constraints["required"]).to eq(true)
    end

    context "with non-CSV resources" do

      it "returns nil if there are no CSVs" do
        url = 'http://example.org/non-csv-datapackage.json'
        mock_file(url, 'datapackages/non-csv-datapackage.json', 'application/javascript')
        mock_file("http://example.org/some-json.json", 'datapackages/non-csv-datapackage.json')

        package = Package.new
        package = package.create_package([url])

        expect(package).to eq(nil)
      end

      it "ignores non-CSV resources" do
        url = 'http://example.org/mixed-datapackage.json'
        mock_file(url, 'datapackages/mixed-datapackage.json', 'application/javascript')
        mock_file("http://example.org/some-json.json", 'csvs/valid.csv')
        mock_file("http://example.org/valid.csv", 'csvs/valid.csv')

        package = Package.new
        package = package.create_package([url])

        expect(package.validations.length).to eq(1)
      end

    end
  end

  context "with a local datapackage" do
    it "creates a validation for a datapackage with a single CSV" do
      files = [ mock_uploaded_file('datapackages/single-datapackage.json') ]
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')

      package = Package.new
      package = package.create_package(files)
      expect(package.validations.length).to eq(1)

    end

    it "ignores local CSV files" do
      files = [ mock_uploaded_file('datapackages/local-and-remote-datapackage.json') ]
      mock_file("http://example.org/valid.csv", 'csvs/valid.csv')

      package = Package.new
      package = package.create_package(files)
      expect(package.validations.length).to eq(1)

    end

  end

  context "with a CKAN URL" do

    # Stub out more of the new CSVW auto detection requests
    # These only get hit in these tests, the rest are stubbed globally in spec_helper.rb
    before :each do
      stub_request(:get, /-metadata\.json/).
        to_return(:status => 404)
    end

    it "creates a validation for a CKAN package with a single CSV", :vcr do
      url = 'http://data.gov.uk/dataset/uk-open-access-non-vosa-sites'

      package = Package.new
      package = package.create_package([url])
      dataset = DataKitten::Dataset.new(access_url: url)
      package_dataset = Marshal.load(package.dataset)

      expect(package.url).to eq(url)
      expect(package.validations.length).to eq(1)

      expect(package_dataset.access_url).to eq(dataset.access_url)
      expect(package_dataset.data_title).to eq(dataset.data_title)
      expect(package_dataset.description).to eq(dataset.description)
      expect(package_dataset.resources).to eq(dataset.resources)
    end

    it "creates multiple validations for a datapackage with multiple CSVs", :vcr do
      url = 'http://data.gov.uk/dataset/uk-civil-service-high-earners'

      package = Package.new
      package = package.create_package([url])

      expect(package.validations.length).to eq(4)
    end

    it "returns nil if there are no CSVs", :vcr do
      url = 'http://data.gov.uk/dataset/ratio-of-median-house-price-to-median-earnings'

      package = Package.new
      package = package.create_package([url])
      expect(package).to eq(nil)
    end

  end


end
