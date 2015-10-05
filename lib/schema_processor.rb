require 'processor_helpers'

class SchemaProcessor
  include ProcessorHelpers

  attr_accessor :schema, :url

  def initialize(options = {})
    @schema = nil
    @url = options[:url]
    @data = options[:data]
    @file = options[:file]

    if @url.present?
      @schema = from_url
    elsif @data.present?
      @schema = from_data
    elsif @file.present?
      @schema = from_file
    end
  end

  def from_url
    Csvlint::Schema.load_from_json(@url)
  end

  def from_data
    json = read_data_url(@data)[:body].read
    process_file(json)
  end

  def from_file
    json = @file.tempfile.read
    process_file(json)
  end

  def process_file(json)
    begin
      json = JSON.parse(json)
      schema = Csvlint::Schema.from_json_table( nil, json )
    rescue JSON::ParserError
      # catch JSON parse error
      # this rescue requires further work, currently in place to catch malformed or bad json uploaded schemas
      schema = Csvlint::Schema.new(nil, [], "malformed", "malformed")
    end
    return schema
  end

end
