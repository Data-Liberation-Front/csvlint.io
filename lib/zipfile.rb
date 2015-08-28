require 'zip'

class Zipfile

  def self.unzip(source, type)
    file = File.open(source)

    files = []

    Zip::File.open(file) do |zipfile|
      zipfile.each do |entry|
        next if entry.name =~ /__MACOSX/ or entry.name =~ /\.DS_Store/
        file = entry.get_input_stream
        csv = StoredCSV.save(file, entry.name)
        files << {
          :csv_id => csv.id,
          :filename => csv.metadata[:filename]
        }
      end
    end
    files
  end

end
