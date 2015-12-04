require 'fog_storage'

class StoredCSV

  def self.save(file, filename)
    FogStorage.new.create_file file, filename
  end

  def self.fetch filename
    FogStorage.new.find_file filename
  end

end
