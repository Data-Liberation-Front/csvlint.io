require 'processor_helpers'

class SchemaProcessor
  include ProcessorHelpers

  attr_accessor :schema, :url

  def initialize(options = {})
    @schema = nil
    @url = options[:url]
    @data = options[:data]
    @file = options[:file]

    begin
      if @url.present?
        @schema = from_url
      elsif @data.present?
        @schema = from_data
      elsif @file.present?
        @schema = from_file
      end
    rescue JSON::ParserError
      # catch JSON parse error
      # this rescue requires further work, currently in place to catch malformed or bad json uploaded schemas
      @schema = Csvlint::Schema.new(nil, [], "malformed", "malformed")
    end
  end

  def from_url
    @json = JSON.parse open(@url).read
    process_file
  end

  def from_data
    @json = JSON.parse read_data_url(@data)[:body].read
    process_file
  end

  def from_file
    @json = JSON.parse @file.tempfile.read
    process_file
  end

  def is_datapackage?
    !@json['resources'].nil?
  end

  def process_file
    if is_datapackage?
      Csvlint::Schema.from_json_table( @url, @json['resources'].first['schema'] )
    else
      Csvlint::Schema.from_json_table( @url, @json )
    end
  end

end
