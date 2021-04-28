require "spec_helper"
require "schema_processor"

describe SchemaProcessor do

  before(:each) do
    @schema = 'schemas/valid.json'
  end

  it "reads a schema from a URL" do
    schema_url = "http://example.org/schema.json"
    mock_file(schema_url, @schema, 'application/javascript')

    schema = described_class.new(url: schema_url).schema

    expect(schema.fields.count).to eq(3)
    expect(schema.fields[0].name).to eq("FirstName")
    expect(schema.fields[1].name).to eq("LastName")
    expect(schema.fields[2].name).to eq("Insult")
  end

  it "reads a schema from a data URI" do
    schema_data = create_data_uri(@schema, 'application/json')
    schema = described_class.new(data: schema_data).schema

    expect(schema.fields.count).to eq(3)
    expect(schema.fields[0].name).to eq("FirstName")
    expect(schema.fields[1].name).to eq("LastName")
    expect(schema.fields[2].name).to eq("Insult")
  end

  it "reads a schema from a file" do
    file = mock_uploaded_file(@schema, 'application/json')
    schema = described_class.new(file: file).schema

    expect(schema.fields.count).to eq(3)
    expect(schema.fields[0].name).to eq("FirstName")
    expect(schema.fields[1].name).to eq("LastName")
    expect(schema.fields[2].name).to eq("Insult")
  end

  context "with datapackage" do
    before(:each) do
      @file = mock_uploaded_file('datapackages/datapackage-with-schema.json', 'application/json')
      @schema = described_class.new(file: @file)
    end

    it "detects a datapackage" do
      expect(@schema.is_datapackage?).to eq(true)
    end

    it "reads a schema from a datapackage" do
      schema = @schema.schema

      expect(schema.fields.count).to eq(5)
      expect(schema.fields[0].name).to eq("Username")
      expect(schema.fields[1].name).to eq("Age")
      expect(schema.fields[2].name).to eq("Height")
      expect(schema.fields[3].name).to eq("Weight")
      expect(schema.fields[4].name).to eq("Password")
    end
  end

end
