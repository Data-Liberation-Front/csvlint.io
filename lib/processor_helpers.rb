require 'data_uri/open_uri'

module ProcessorHelpers

  def read_data_url(data)
    file_array = data.split(";", 2)
    uri = URI::Data.new(file_array[1])
    {
      filename: file_array[0],
      body: open(uri)
    }
  end

end
