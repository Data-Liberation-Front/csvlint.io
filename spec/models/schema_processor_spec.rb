require "spec_helper"
require "schema_processor"

describe SchemaProcessor do

  before(:each) do
    @schema = 'schemas/valid.json'
  end

  it "reads a schema from a URL" do
    schema_url = "http://example.org/schema.json"
    mock_file(schema_url, @schema, 'application/javascript')

    schema = SchemaProcessor.new(url: schema_url).schema

    expect(schema.fields.count).to eq(3)
    expect(schema.fields[0].name).to eq("FirstName")
    expect(schema.fields[1].name).to eq("LastName")
    expect(schema.fields[2].name).to eq("Insult")
  end

  it "reads a schema from a data URI" do
    schema_data = create_data_uri(@schema, 'application/json')
    schema = SchemaProcessor.new(data: schema_data).schema

    expect(schema.fields.count).to eq(3)
    expect(schema.fields[0].name).to eq("FirstName")
    expect(schema.fields[1].name).to eq("LastName")
    expect(schema.fields[2].name).to eq("Insult")
  end

  it "reads a schema from a file" do
    file = mock_uploaded_file(@schema, 'application/json')
    schema = SchemaProcessor.new(file: file).schema

    expect(schema.fields.count).to eq(3)
    expect(schema.fields[0].name).to eq("FirstName")
    expect(schema.fields[1].name).to eq("LastName")
    expect(schema.fields[2].name).to eq("Insult")
  end

end
