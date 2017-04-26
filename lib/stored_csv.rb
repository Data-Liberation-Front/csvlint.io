require 'fog_storage'

class StoredCSV

  def self.save(file, filename)
    FogStorage.new.create_file filename, file.read
  end

  def self.fetch filename
    FogStorage.new.find_file filename
  end

end
